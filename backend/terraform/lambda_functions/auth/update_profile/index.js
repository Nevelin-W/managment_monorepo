const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, UpdateCommand } = require("@aws-sdk/lib-dynamodb");
const { CognitoIdentityProviderClient, AdminUpdateUserAttributesCommand } = require("@aws-sdk/client-cognito-identity-provider");

const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));
const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
  console.log('Update profile request:', JSON.stringify(event, null, 2));
  
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
    const { name } = body;

    // Validate input
    if (!name || typeof name !== 'string') {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Name is required and must be a string' }),
      };
    }

    const trimmedName = name.trim();
    
    if (trimmedName.length < 2 || trimmedName.length > 50) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ 
          error: 'Name must be between 2 and 50 characters' 
        }),
      };
    }

    // Verify user exists in DynamoDB
    const getCommand = new GetCommand({
      TableName: process.env.USERS_TABLE,
      Key: { email },
    });

    const existingUser = await dynamoClient.send(getCommand);
    
    if (!existingUser.Item) {
      return {
        statusCode: 404,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'User not found' }),
      };
    }

    // Update DynamoDB
    const updateCommand = new UpdateCommand({
      TableName: process.env.USERS_TABLE,
      Key: { email },
      UpdateExpression: 'SET #name = :name, updated_at = :updated_at',
      ExpressionAttributeNames: {
        '#name': 'name',
      },
      ExpressionAttributeValues: {
        ':name': trimmedName,
        ':updated_at': new Date().toISOString(),
      },
      ReturnValues: 'ALL_NEW',
    });

    const updateResult = await dynamoClient.send(updateCommand);

    // Update Cognito user attributes (optional but recommended for consistency)
    try {
      const cognitoUpdateCommand = new AdminUpdateUserAttributesCommand({
        UserPoolId: process.env.USER_POOL_ID,
        Username: email,
        UserAttributes: [
          {
            Name: 'name',
            Value: trimmedName,
          },
        ],
      });

      await cognitoClient.send(cognitoUpdateCommand);
      console.log('Cognito attributes updated successfully');
    } catch (cognitoError) {
      console.error('Failed to update Cognito attributes:', cognitoError);
      // Don't fail the request if Cognito update fails
      // DynamoDB is the source of truth
    }

    const updatedUser = updateResult.Attributes;

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: 'Profile updated successfully',
        user: {
          id: updatedUser.id,
          email: updatedUser.email,
          name: updatedUser.name,
          updatedAt: updatedUser.updated_at,
        },
      }),
    };

  } catch (error) {
    console.error('Update profile error:', error);
    
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