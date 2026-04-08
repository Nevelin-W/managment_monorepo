const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand } = require("@aws-sdk/lib-dynamodb");
const { success, error, logRequest, logResponse, logger, extractClaims } = require("../../shared/response");

const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

exports.handler = async (event) => {
  logRequest('Get current user', event);
  const startTime = Date.now();
  
  try {
    const { email } = extractClaims(event);

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
      createdAt: user.createdAt,
    });
    logResponse('Me', event, resp, startTime);
    return resp;

  } catch (err) {
    logger.error('Me failed', { error: err.name, message: err.message, stack: err.stack });
    const resp = err.statusCode ? error(err.statusCode, err.message) : error(500, 'Internal server error', err.message);
    logResponse('Me', event, resp, startTime);
    return resp;
  }
};