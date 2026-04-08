const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, UpdateCommand } = require("@aws-sdk/lib-dynamodb");
const { CognitoIdentityProviderClient, AdminUpdateUserAttributesCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { success, error, logRequest, logResponse, logger, parseBody, extractClaims } = require("../../shared/response");

const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));
const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
  logRequest('Update profile', event);
  const startTime = Date.now();
  
  try {
    const { email } = extractClaims(event);
    const body = parseBody(event);
    const { name } = body;

    if (!name || typeof name !== 'string') {
      return error(400, 'Name is required and must be a string');
    }

    const trimmedName = name.trim();
    if (trimmedName.length < 2 || trimmedName.length > 50) {
      return error(400, 'Name must be between 2 and 50 characters');
    }

    // Verify user exists
    const existingUser = await dynamoClient.send(new GetCommand({
      TableName: process.env.USERS_TABLE,
      Key: { email },
    }));
    
    if (!existingUser.Item) {
      return error(404, 'User not found');
    }

    // Update DynamoDB
    const updateResult = await dynamoClient.send(new UpdateCommand({
      TableName: process.env.USERS_TABLE,
      Key: { email },
      UpdateExpression: 'SET #name = :name, updatedAt = :updatedAt',
      ExpressionAttributeNames: { '#name': 'name' },
      ExpressionAttributeValues: {
        ':name': trimmedName,
        ':updatedAt': new Date().toISOString(),
      },
      ReturnValues: 'ALL_NEW',
    }));

    // Sync to Cognito (best-effort)
    try {
      await cognitoClient.send(new AdminUpdateUserAttributesCommand({
        UserPoolId: process.env.USER_POOL_ID,
        Username: email,
        UserAttributes: [{ Name: 'name', Value: trimmedName }],
      }));
    } catch (cognitoError) {
      logger.error('Failed to sync Cognito attributes', { error: cognitoError.name, message: cognitoError.message });
    }

    const updatedUser = updateResult.Attributes;

    const resp = success(200, {
      message: 'Profile updated successfully',
      user: {
        id: updatedUser.id,
        email: updatedUser.email,
        name: updatedUser.name,
        updatedAt: updatedUser.updatedAt,
      },
    });
    logResponse('Update profile', event, resp, startTime);
    return resp;

  } catch (err) {
    logger.error('Update profile failed', { error: err.name, message: err.message, stack: err.stack });
    const resp = err.statusCode ? error(err.statusCode, err.message) : error(500, 'Internal server error', err.message);
    logResponse('Update profile', event, resp, startTime);
    return resp;
  }
};