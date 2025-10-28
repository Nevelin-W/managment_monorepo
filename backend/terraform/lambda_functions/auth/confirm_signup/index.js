const { CognitoIdentityProviderClient, ConfirmSignUpCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, UpdateCommand, QueryCommand } = require("@aws-sdk/lib-dynamodb");

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

    // Confirm user in Cognito
    const confirmCommand = new ConfirmSignUpCommand({
      ClientId: process.env.USER_POOL_CLIENT_ID,
      Username: email,
      ConfirmationCode: code,
    });

    await cognitoClient.send(confirmCommand);

    // Update user record in DynamoDB to mark email as verified
    // First, find the user by email
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

    // Update the user's emailVerified status
    const updateCommand = new UpdateCommand({
      TableName: process.env.USERS_TABLE,
      Key: { id: user.id },
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
        message: 'Email verified successfully',
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
      errorMessage = 'Verification code has expired';
    } else if (error.name === 'NotAuthorizedException') {
      statusCode = 400;
      errorMessage = 'User is already confirmed';
    } else if (error.name === 'UserNotFoundException') {
      statusCode = 404;
      errorMessage = 'User not found';
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