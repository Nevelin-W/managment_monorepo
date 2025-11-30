const { 
  CognitoIdentityProviderClient, 
  ConfirmSignUpCommand, 
  AdminUpdateUserAttributesCommand,
  AdminGetUserCommand 
} = require("@aws-sdk/client-cognito-identity-provider");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, UpdateCommand, GetCommand } = require("@aws-sdk/lib-dynamodb");

const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });
const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

exports.handler = async (event) => {
  console.log('Confirm email request:', JSON.stringify(event, null, 2));
  
  try {
    const body = JSON.parse(event.body);
    const { email, code } = body;

    if (!email || !code) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Email and verification code are required' }),
      };
    }

    // Check if user is already confirmed
    let isAlreadyConfirmed = false;
    try {
      const getUserCommand = new AdminGetUserCommand({
        UserPoolId: process.env.USER_POOL_ID,
        Username: email,
      });
      const userResponse = await cognitoClient.send(getUserCommand);
      isAlreadyConfirmed = userResponse.UserStatus === 'CONFIRMED';
    } catch (error) {
      console.log('User status check error:', error.name);
    }

    // Try to confirm the user (only if not already confirmed)
    if (!isAlreadyConfirmed) {
      try {
        const confirmCommand = new ConfirmSignUpCommand({
          ClientId: process.env.USER_POOL_CLIENT_ID,
          Username: email,
          ConfirmationCode: code,
        });
        await cognitoClient.send(confirmCommand);
      } catch (confirmError) {
        // If user is already confirmed, this is okay - we'll just set email_verified
        if (confirmError.name !== 'NotAuthorizedException' && 
            confirmError.name !== 'AliasExistsException') {
          throw confirmError;
        }
        console.log('User already confirmed, proceeding to set email_verified');
      }
    }

    // CRITICAL: Always set email_verified to true in Cognito
    const updateAttributesCommand = new AdminUpdateUserAttributesCommand({
      UserPoolId: process.env.USER_POOL_ID,
      Username: email,
      UserAttributes: [
        {
          Name: 'email_verified',
          Value: 'true',
        },
      ],
    });

    await cognitoClient.send(updateAttributesCommand);
    console.log('email_verified set to true in Cognito');

    // Get user from DynamoDB using email directly (no GSI needed since email is partition key)
    const getCommand = new GetCommand({
      TableName: process.env.USERS_TABLE,
      Key: { email: email },
    });

    const getResult = await dynamoClient.send(getCommand);
    
    if (!getResult.Item) {
      console.warn('User not found in DynamoDB, but Cognito verification succeeded');
      return {
        statusCode: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({
          message: 'Email verified successfully. You can now log in.',
          email: email,
          emailVerified: true,
        }),
      };
    }

    // Update the user's emailVerified status in DynamoDB
    const updateCommand = new UpdateCommand({
      TableName: process.env.USERS_TABLE,
      Key: { email: email },  // Use email as partition key
      UpdateExpression: 'SET emailVerified = :verified, updatedAt = :updatedAt',
      ExpressionAttributeValues: {
        ':verified': true,
        ':updatedAt': new Date().toISOString(),
      },
      ReturnValues: 'ALL_NEW',
    });

    const updateResult = await dynamoClient.send(updateCommand);

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: 'Email verified successfully. You can now log in.',
        user: {
          id: updateResult.Attributes.id,
          email: updateResult.Attributes.email,
          name: updateResult.Attributes.name,
          emailVerified: updateResult.Attributes.emailVerified,
        },
      }),
    };

  } catch (error) {
    console.error('Confirm email error:', error);
    
    let statusCode = 500;
    let errorMessage = 'Internal server error';
    
    if (error.name === 'CodeMismatchException') {
      statusCode = 400;
      errorMessage = 'Invalid verification code';
    } else if (error.name === 'ExpiredCodeException') {
      statusCode = 400;
      errorMessage = 'Verification code has expired. Please request a new code.';
    } else if (error.name === 'UserNotFoundException') {
      statusCode = 404;
      errorMessage = 'User not found';
    } else if (error.name === 'LimitExceededException') {
      statusCode = 429;
      errorMessage = 'Too many attempts. Please try again later.';
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