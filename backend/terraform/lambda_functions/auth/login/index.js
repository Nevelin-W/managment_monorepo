const { CognitoIdentityProviderClient, InitiateAuthCommand, AdminGetUserCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand } = require("@aws-sdk/lib-dynamodb");
const { success, error, logRequest, logResponse, logger, parseBody, isValidEmail } = require("../../shared/response");

const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });
const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

exports.handler = async (event) => {
  logRequest('Login request', event);
  const startTime = Date.now();
  
  try {
    const body = parseBody(event);
    const { email, password } = body;

    if (!email || !password) {
      return error(400, 'Email and password are required');
    }

    if (!isValidEmail(email)) {
      return error(400, 'Invalid email format');
    }

    // Check if user's email is verified in Cognito BEFORE authenticating
    try {
      const cognitoUser = await cognitoClient.send(new AdminGetUserCommand({
        UserPoolId: process.env.USER_POOL_ID,
        Username: email,
      }));
      
      if (cognitoUser.UserStatus !== 'CONFIRMED') {
        return error(403, 'Email not verified', 'Please verify your email before logging in.');
      }

      const emailVerifiedAttr = cognitoUser.UserAttributes.find(attr => attr.Name === 'email_verified');
      if (!emailVerifiedAttr || emailVerifiedAttr.Value !== 'true') {
        return error(403, 'Email not verified', 'Please verify your email before logging in.');
      }
    } catch (userCheckError) {
      if (userCheckError.name === 'UserNotFoundException') {
        return error(401, 'Incorrect email or password');
      }
      throw userCheckError;
    }

    // Authenticate with Cognito
    const authResponse = await cognitoClient.send(new InitiateAuthCommand({
      AuthFlow: 'USER_PASSWORD_AUTH',
      ClientId: process.env.USER_POOL_CLIENT_ID,
      AuthParameters: {
        USERNAME: email,
        PASSWORD: password,
      },
    }));
    
    if (!authResponse.AuthenticationResult) {
      return error(401, 'Authentication failed');
    }

    const { AccessToken, IdToken, RefreshToken } = authResponse.AuthenticationResult;

    // Get user from DynamoDB directly by hash key (email) — no GSI needed
    const result = await dynamoClient.send(new GetCommand({
      TableName: process.env.USERS_TABLE,
      Key: { email },
    }));
    
    if (!result.Item) {
      return error(404, 'User not found');
    }

    const user = result.Item;

    const resp = success(200, {
      id: user.id,
      email: user.email,
      name: user.name,
      emailVerified: user.emailVerified,
      token: AccessToken,
      idToken: IdToken,
      refreshToken: RefreshToken,
    });
    logResponse('Login', event, resp, startTime);
    return resp;

  } catch (err) {
    logger.error('Login failed', { error: err.name, message: err.message, stack: err.stack });
    
    if (err.name === 'NotAuthorizedException') {
      const resp = error(401, 'Incorrect email or password');
      logResponse('Login', event, resp, startTime);
      return resp;
    }
    if (err.name === 'UserNotConfirmedException') {
      const resp = error(403, 'Email not verified. Please check your inbox for the verification code.');
      logResponse('Login', event, resp, startTime);
      return resp;
    }
    if (err.name === 'UserNotFoundException') {
      const resp = error(401, 'Incorrect email or password');
      logResponse('Login', event, resp, startTime);
      return resp;
    }
    
    const resp = error(500, 'Internal server error', err.message);
    logResponse('Login', event, resp, startTime);
    return resp;
  }
};