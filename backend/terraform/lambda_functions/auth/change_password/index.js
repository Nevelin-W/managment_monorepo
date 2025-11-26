const { CognitoIdentityProviderClient, ChangePasswordCommand } = require("@aws-sdk/client-cognito-identity-provider");

const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
  console.log('Change password request:', JSON.stringify(event, null, 2));
  
  try {
    // Extract user info from Cognito authorizer context
    const claims = event.requestContext.authorizer.claims;
    const userId = claims.sub;
    const email = claims.email;
    
    if (!userId || !email) {
      return {
        statusCode: 401,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Unauthorized' }),
      };
    }

    // Parse request body
    const body = JSON.parse(event.body || '{}');
    const { oldPassword, newPassword } = body;

    // Validate input
    if (!oldPassword || typeof oldPassword !== 'string') {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Current password is required' }),
      };
    }

    if (!newPassword || typeof newPassword !== 'string') {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'New password is required' }),
      };
    }

    // Validate new password strength
    if (newPassword.length < 8) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ 
          error: 'New password must be at least 8 characters long' 
        }),
      };
    }

    // Check password requirements
    const hasUpperCase = /[A-Z]/.test(newPassword);
    const hasLowerCase = /[a-z]/.test(newPassword);
    const hasNumber = /[0-9]/.test(newPassword);
    const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(newPassword);

    if (!hasUpperCase || !hasLowerCase || !hasNumber || !hasSpecialChar) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ 
          error: 'Password must contain uppercase, lowercase, number, and special character' 
        }),
      };
    }

    // Prevent using the same password
    if (oldPassword === newPassword) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ 
          error: 'New password must be different from current password' 
        }),
      };
    }

    // Extract access token from Authorization header
    // The authorizer passes the token through
    const authHeader = event.headers?.Authorization || event.headers?.authorization;
    if (!authHeader) {
      return {
        statusCode: 401,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Missing authorization token' }),
      };
    }

    // Remove 'Bearer ' prefix if present
    const accessToken = authHeader.replace(/^Bearer\s+/i, '');

    console.log('Attempting password change for user:', email);

    // Change password using Cognito
    const command = new ChangePasswordCommand({
      AccessToken: accessToken,
      PreviousPassword: oldPassword,
      ProposedPassword: newPassword,
    });

    try {
      await cognitoClient.send(command);
      console.log('Password changed successfully for user:', email);
    } catch (cognitoError) {
      console.error('Cognito password change error:', cognitoError);
      
      // Handle specific Cognito errors
      let errorMessage = 'Failed to change password';
      
      if (cognitoError.name === 'NotAuthorizedException') {
        errorMessage = 'Current password is incorrect';
      } else if (cognitoError.name === 'InvalidPasswordException') {
        errorMessage = 'New password does not meet requirements';
      } else if (cognitoError.name === 'LimitExceededException') {
        errorMessage = 'Too many attempts. Please try again later';
      } else if (cognitoError.name === 'InvalidParameterException') {
        errorMessage = 'Invalid password format';
      }
      
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: errorMessage }),
      };
    }

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: 'Password changed successfully',
        success: true,
      }),
    };

  } catch (error) {
    console.error('Change password error:', error);
    
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({ 
        error: 'Internal server error',
        message: error.message 
      }),
    };
  }
};