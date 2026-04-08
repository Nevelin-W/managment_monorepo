const { CognitoIdentityProviderClient, SignUpCommand, AdminConfirmSignUpCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");
const { randomUUID } = require('crypto');
const { success, error, logRequest, logResponse, logger, parseBody, isValidEmail } = require("../../shared/response");

const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });
const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

exports.handler = async (event) => {
  logRequest('Signup request', event);
  const startTime = Date.now();
  
  try {
    const body = parseBody(event);
    const { email, password, name } = body;

    if (!email || !password || !name) {
      return error(400, 'Email, password, and name are required');
    }

    if (!isValidEmail(email)) {
      return error(400, 'Invalid email format');
    }

    if (typeof name !== 'string' || name.trim().length < 2 || name.trim().length > 50) {
      return error(400, 'Name must be between 2 and 50 characters');
    }

    // Create user in Cognito
    const signUpResponse = await cognitoClient.send(new SignUpCommand({
      ClientId: process.env.USER_POOL_CLIENT_ID,
      Username: email,
      Password: password,
      UserAttributes: [
        { Name: 'email', Value: email },
        { Name: 'name', Value: name.trim() },
      ],
    }));
    
    // Auto-confirm user (for dev only)
    if (process.env.ENVIRONMENT === 'dev') {
      await cognitoClient.send(new AdminConfirmSignUpCommand({
        UserPoolId: process.env.USER_POOL_ID,
        Username: email,
      }));
    }

    // Create user record in DynamoDB
    const userId = randomUUID();
    const timestamp = new Date().toISOString();
    
    await dynamoClient.send(new PutCommand({
      TableName: process.env.USERS_TABLE,
      Item: {
        id: userId,
        email,
        name: name.trim(),
        cognitoSub: signUpResponse.UserSub,
        emailVerified: process.env.ENVIRONMENT === 'dev',
        createdAt: timestamp,
        updatedAt: timestamp,
      },
      ConditionExpression: 'attribute_not_exists(email)',
    }));

    const resp = success(201, {
      id: userId,
      email,
      name: name.trim(),
      message: 'User created successfully',
    });
    logResponse('Signup', event, resp, startTime);
    return resp;

  } catch (err) {
    logger.error('Signup failed', { error: err.name, message: err.message, stack: err.stack });
    
    if (err.name === 'UsernameExistsException') {
      const resp = error(409, 'User already exists');
      logResponse('Signup', event, resp, startTime);
      return resp;
    }
    if (err.name === 'InvalidPasswordException') {
      const resp = error(400, 'Password does not meet requirements');
      logResponse('Signup', event, resp, startTime);
      return resp;
    }
    if (err.name === 'ConditionalCheckFailedException') {
      const resp = error(409, 'User already exists');
      logResponse('Signup', event, resp, startTime);
      return resp;
    }
    
    const resp = error(500, 'Internal server error', err.message);
    logResponse('Signup', event, resp, startTime);
    return resp;
  }
};