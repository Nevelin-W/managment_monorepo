const { CognitoIdentityProviderClient, InitiateAuthCommand, AdminGetUserCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, QueryCommand } = require("@aws-sdk/lib-dynamodb");

const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });
const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

exports.handler = async (event) => {
  console.log('Login request:', JSON.stringify(event, null, 2));
  
  try {
    const body = JSON.parse(event.body);
    const { email, password } = body;

    if (!email || !password) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Email and password are required' }),
      };
    }

    // First check if user's email is verified in Cognito BEFORE authenticating
    try {
      const adminGetUserCommand = new AdminGetUserCommand({
        UserPoolId: process.env.USER_POOL_ID,
        Username: email,
      });

      const cognitoUser = await cognitoClient.send(adminGetUserCommand);
      
      // Check user status
      if (cognitoUser.UserStatus !== 'CONFIRMED') {
        return {
          statusCode: 403,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
          body: JSON.stringify({ 
            error: 'Email not verified',
            message: 'Please verify your email before logging in. Check your inbox for the verification code.'
          }),
        };
      }

      // Double-check email_verified attribute
      const emailVerifiedAttr = cognitoUser.UserAttributes.find(attr => attr.Name === 'email_verified');
      const isEmailVerified = emailVerifiedAttr && emailVerifiedAttr.Value === 'true';

      if (!isEmailVerified) {
        return {
          statusCode: 403,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
          body: JSON.stringify({ 
            error: 'Email not verified',
            message: 'Please verify your email before logging in. Check your inbox for the verification code.'
          }),
        };
      }
    } catch (userCheckError) {
      if (userCheckError.name === 'UserNotFoundException') {
        return {
          statusCode: 401,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
          body: JSON.stringify({ error: 'Incorrect email or password' }),
        };
      }
      throw userCheckError;
    }

    // Authenticate with Cognito (only if email is verified)
    const authCommand = new InitiateAuthCommand({
      AuthFlow: 'USER_PASSWORD_AUTH',
      ClientId: process.env.USER_POOL_CLIENT_ID,
      AuthParameters: {
        USERNAME: email,
        PASSWORD: password,
      },
    });

    const authResponse = await cognitoClient.send(authCommand);
    
    if (!authResponse.AuthenticationResult) {
      return {
        statusCode: 401,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Authentication failed' }),
      };
    }

    const { AccessToken, IdToken, RefreshToken } = authResponse.AuthenticationResult;

    // Get user details from DynamoDB using email-index
    const queryCommand = new QueryCommand({
      TableName: process.env.USERS_TABLE,
      IndexName: 'email-index',
      KeyConditionExpression: 'email = :email',
      ExpressionAttributeValues: {
        ':email': email,
      },
    });

    const queryResult = await dynamoClient.send(queryCommand);
    
    if (!queryResult.Items || queryResult.Items.length === 0) {
      return {
        statusCode: 404,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'User not found' }),
      };
    }

    const user = queryResult.Items[0];

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        id: user.id,
        email: user.email,
        name: user.name,
        emailVerified: user.emailVerified,
        token: AccessToken,
        idToken: IdToken,
        refreshToken: RefreshToken,
      }),
    };

  } catch (error) {
    console.error('Login error:', error);
    
    let statusCode = 500;
    let errorMessage = 'Internal server error';
    
    if (error.name === 'NotAuthorizedException') {
      statusCode = 401;
      errorMessage = 'Incorrect email or password';
    } else if (error.name === 'UserNotConfirmedException') {
      statusCode = 403;
      errorMessage = 'Email not verified. Please check your inbox for the verification code.';
    } else if (error.name === 'UserNotFoundException') {
      statusCode = 401;
      errorMessage = 'Incorrect email or password';
    }
    
    return {
      statusCode,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({ 
        error: errorMessage,
        message: error.message 
      }),
    };
  }
};