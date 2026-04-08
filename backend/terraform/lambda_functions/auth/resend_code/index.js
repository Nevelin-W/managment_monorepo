const { CognitoIdentityProviderClient, ResendConfirmationCodeCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { success, error, logRequest, logResponse, logger, parseBody, isValidEmail } = require("../../shared/response");

const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
  logRequest('Resend code request', event);
  const startTime = Date.now();
  
  try {
    const body = parseBody(event);
    const { email } = body;

    if (!email) {
      return error(400, 'Email is required');
    }

    if (!isValidEmail(email)) {
      return error(400, 'Invalid email format');
    }

    await cognitoClient.send(new ResendConfirmationCodeCommand({
      ClientId: process.env.USER_POOL_CLIENT_ID,
      Username: email,
    }));

    const resp = success(200, {
      message: 'Verification code resent successfully',
    });
    logResponse('Resend code', event, resp, startTime);
    return resp;

  } catch (err) {
    logger.error('Resend code failed', { error: err.name, message: err.message, stack: err.stack });
    
    if (err.name === 'UserNotFoundException') {
      const resp = error(404, 'User not found');
      logResponse('Resend code', event, resp, startTime);
      return resp;
    }
    if (err.name === 'InvalidParameterException') {
      const resp = error(400, 'User is already confirmed');
      logResponse('Resend code', event, resp, startTime);
      return resp;
    }
    if (err.name === 'LimitExceededException') {
      const resp = error(429, 'Too many requests. Please try again later');
      logResponse('Resend code', event, resp, startTime);
      return resp;
    }
    const resp = err.statusCode ? error(err.statusCode, err.message) : error(500, 'Internal server error', err.message);
    logResponse('Resend code', event, resp, startTime);
    return resp;
  }
};