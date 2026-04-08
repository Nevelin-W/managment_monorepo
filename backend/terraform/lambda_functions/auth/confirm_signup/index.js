const { 
  CognitoIdentityProviderClient, 
  ConfirmSignUpCommand, 
  AdminUpdateUserAttributesCommand,
  AdminGetUserCommand 
} = require("@aws-sdk/client-cognito-identity-provider");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, UpdateCommand, GetCommand } = require("@aws-sdk/lib-dynamodb");
const { success, error, logRequest, logResponse, logger, parseBody, isValidEmail } = require("../../shared/response");

const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });
const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

exports.handler = async (event) => {
  logRequest('Confirm email request', event);
  const startTime = Date.now();
  
  try {
    const body = parseBody(event);
    const { email, code } = body;

    if (!email || !code) {
      return error(400, 'Email and verification code are required');
    }

    if (!isValidEmail(email)) {
      return error(400, 'Invalid email format');
    }

    // Check if user is already confirmed
    let isAlreadyConfirmed = false;
    try {
      const userResponse = await cognitoClient.send(new AdminGetUserCommand({
        UserPoolId: process.env.USER_POOL_ID,
        Username: email,
      }));
      isAlreadyConfirmed = userResponse.UserStatus === 'CONFIRMED';
    } catch (checkError) {
      console.log('User status check:', checkError.name);
    }

    // Confirm the user if not already confirmed
    if (!isAlreadyConfirmed) {
      try {
        await cognitoClient.send(new ConfirmSignUpCommand({
          ClientId: process.env.USER_POOL_CLIENT_ID,
          Username: email,
          ConfirmationCode: code,
        }));
      } catch (confirmError) {
        if (confirmError.name !== 'NotAuthorizedException' && 
            confirmError.name !== 'AliasExistsException') {
          throw confirmError;
        }
      }
    }

    // Always set email_verified to true in Cognito
    await cognitoClient.send(new AdminUpdateUserAttributesCommand({
      UserPoolId: process.env.USER_POOL_ID,
      Username: email,
      UserAttributes: [{ Name: 'email_verified', Value: 'true' }],
    }));

    // Get user from DynamoDB (email is partition key)
    const getResult = await dynamoClient.send(new GetCommand({
      TableName: process.env.USERS_TABLE,
      Key: { email },
    }));
    
    if (!getResult.Item) {
      console.warn('User not found in DynamoDB, but Cognito verification succeeded');
      const resp = success(200, {
        message: 'Email verified successfully. You can now log in.',
        email,
        emailVerified: true,
      });
      logResponse('Confirm signup', event, resp, startTime);
      return resp;
    }

    // Update emailVerified in DynamoDB
    const updateResult = await dynamoClient.send(new UpdateCommand({
      TableName: process.env.USERS_TABLE,
      Key: { email },
      UpdateExpression: 'SET emailVerified = :verified, updatedAt = :updatedAt',
      ExpressionAttributeValues: {
        ':verified': true,
        ':updatedAt': new Date().toISOString(),
      },
      ReturnValues: 'ALL_NEW',
    }));

    const resp = success(200, {
      message: 'Email verified successfully. You can now log in.',
      user: {
        id: updateResult.Attributes.id,
        email: updateResult.Attributes.email,
        name: updateResult.Attributes.name,
        emailVerified: updateResult.Attributes.emailVerified,
      },
    });
    logResponse('Confirm signup', event, resp, startTime);
    return resp;

  } catch (err) {
    logger.error('Confirm signup failed', { error: err.name, message: err.message, stack: err.stack });
    
    const errorMap = {
      'CodeMismatchException': [400, 'Invalid verification code'],
      'ExpiredCodeException': [400, 'Verification code has expired. Please request a new code.'],
      'UserNotFoundException': [404, 'User not found'],
      'LimitExceededException': [429, 'Too many attempts. Please try again later.'],
    };
    
    const [status, msg] = errorMap[err.name] || [500, 'Internal server error'];
    const resp = error(status, msg, err.message);
    logResponse('Confirm signup', event, resp, startTime);
    return resp;
  }
};