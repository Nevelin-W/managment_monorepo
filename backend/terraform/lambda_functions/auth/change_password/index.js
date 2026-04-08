const { CognitoIdentityProviderClient, ChangePasswordCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { success, error, logRequest, logResponse, logger, parseBody, extractClaims } = require("../../shared/response");

const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
  logRequest('Change password request', event);
  const startTime = Date.now();
  
  try {
    const { email } = extractClaims(event);
    const body = parseBody(event);
    const { oldPassword, newPassword } = body;

    // Validate input
    if (!oldPassword || typeof oldPassword !== 'string') {
      return error(400, 'Current password is required');
    }
    if (!newPassword || typeof newPassword !== 'string') {
      return error(400, 'New password is required');
    }
    if (newPassword.length < 8) {
      return error(400, 'New password must be at least 8 characters long');
    }

    const hasUpperCase = /[A-Z]/.test(newPassword);
    const hasLowerCase = /[a-z]/.test(newPassword);
    const hasNumber = /[0-9]/.test(newPassword);
    const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(newPassword);

    if (!hasUpperCase || !hasLowerCase || !hasNumber || !hasSpecialChar) {
      return error(400, 'Password must contain uppercase, lowercase, number, and special character');
    }

    if (oldPassword === newPassword) {
      return error(400, 'New password must be different from current password');
    }

    // Extract access token from custom header or Authorization header
    const accessToken = event.headers?.['X-Access-Token'] 
      || event.headers?.['x-access-token']
      || (event.headers?.Authorization || event.headers?.authorization || '').replace(/^Bearer\s+/i, '');

    if (!accessToken) {
      return error(401, 'Access token is required');
    }

    // Change password using Cognito
    try {
      await cognitoClient.send(new ChangePasswordCommand({
        AccessToken: accessToken,
        PreviousPassword: oldPassword,
        ProposedPassword: newPassword,
      }));
      logger.info('Password changed successfully', { email });
    } catch (cognitoError) {
      logger.error('Cognito password change error', { error: cognitoError.name, message: cognitoError.message });
      
      const errorMap = {
        'NotAuthorizedException': [401, 'Current password is incorrect'],
        'InvalidPasswordException': [400, 'New password does not meet requirements'],
        'LimitExceededException': [429, 'Too many attempts. Please try again later'],
        'InvalidParameterException': [400, 'Invalid password format'],
        'UserNotFoundException': [404, 'User not found'],
        'PasswordResetRequiredException': [403, 'Password reset is required'],
      };
      
      const [status, msg] = errorMap[cognitoError.name] || [400, 'Failed to change password'];
      const resp = error(status, msg);
      logResponse('Change password', event, resp, startTime);
      return resp;
    }

    const resp = success(200, {
      message: 'Password changed successfully',
      success: true,
    });
    logResponse('Change password', event, resp, startTime);
    return resp;

  } catch (err) {
    logger.error('Change password failed', { error: err.name, message: err.message, stack: err.stack });
    const resp = err.statusCode ? error(err.statusCode, err.message) : error(500, 'Internal server error', err.message);
    logResponse('Change password', event, resp, startTime);
    return resp;
  }
};