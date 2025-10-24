const { CognitoIdentityProviderClient, SignUpCommand, AdminConfirmSignUpCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");
const { randomUUID } = require('crypto');

const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });
const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

exports.handler = async (event) => {
  console.log('Signup request:', JSON.stringify(event, null, 2));
  
  try {
    const body = JSON.parse(event.body);
    const { email, password, name } = body;

    if (!email || !password || !name) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Email, password, and name are required' }),
      };
    }

    // Create user in Cognito
    const signUpCommand = new SignUpCommand({
      ClientId: process.env.USER_POOL_CLIENT_ID,
      Username: email,
      Password: password,
      UserAttributes: [
        { Name: 'email', Value: email },
        { Name: 'name', Value: name },
      ],
    });

    const signUpResponse = await cognitoClient.send(signUpCommand);
    
    // Auto-confirm user (for dev - remove in production)
    if (process.env.ENVIRONMENT === 'dev') {
      const confirmCommand = new AdminConfirmSignUpCommand({
        UserPoolId: process.env.USER_POOL_ID,
        Username: email,
      });
      await cognitoClient.send(confirmCommand);
    }

    // Create user record in DynamoDB
    const userId = randomUUID();
    const timestamp = new Date().toISOString();
    
    const putCommand = new PutCommand({
      TableName: process.env.USERS_TABLE,
      Item: {
        id: userId,
        email,
        name,
        cognitoSub: signUpResponse.UserSub,
        createdAt: timestamp,
        updatedAt: timestamp,
      },
    });

    await dynamoClient.send(putCommand);

    return {
      statusCode: 201,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        id: userId,
        email,
        name,
        message: 'User created successfully',
      }),
    };

  } catch (error) {
    console.error('Signup error:', error);
    
    let statusCode = 500;
    let errorMessage = 'Internal server error';
    
    if (error.name === 'UsernameExistsException') {
      statusCode = 409;
      errorMessage = 'User already exists';
    } else if (error.name === 'InvalidPasswordException') {
      statusCode = 400;
      errorMessage = 'Password does not meet requirements';
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