const { CognitoIdentityProviderClient, ResendConfirmationCodeCommand } = require("@aws-sdk/client-cognito-identity-provider");

const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
  console.log('Resend code request:', JSON.stringify(event, null, 2));
  
  try {
    const body = JSON.parse(event.body);
    const { email } = body;

    if (!email) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Email is required' }),
      };
    }

    // Resend confirmation code
    const resendCommand = new ResendConfirmationCodeCommand({
      ClientId: process.env.USER_POOL_CLIENT_ID,
      Username: email,
    });

    await cognitoClient.send(resendCommand);

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: 'Verification code resent successfully',
      }),
    };

  } catch (error) {
    console.error('Resend code error:', error);
    
    let statusCode = 500;
    let errorMessage = 'Internal server error';
    
    if (error.name === 'UserNotFoundException') {
      statusCode = 404;
      errorMessage = 'User not found';
    } else if (error.name === 'InvalidParameterException') {
      statusCode = 400;
      errorMessage = 'User is already confirmed';
    } else if (error.name === 'LimitExceededException') {
      statusCode = 429;
      errorMessage = 'Too many requests. Please try again later';
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