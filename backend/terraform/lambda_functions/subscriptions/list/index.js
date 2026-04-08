const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, QueryCommand } = require("@aws-sdk/lib-dynamodb");
const { success, error, logRequest, logResponse, logger, extractClaims } = require("../../shared/response");

const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

exports.handler = async (event) => {
  logRequest('List subscriptions', event);
  const startTime = Date.now();
  
  try {
    const { userId } = extractClaims(event);

    const result = await dynamoClient.send(new QueryCommand({
      TableName: process.env.SUBSCRIPTIONS_TABLE,
      IndexName: 'UserIndex',
      KeyConditionExpression: 'user_id = :userId',
      ExpressionAttributeValues: {
        ':userId': userId,
      },
    }));
    
    logger.info('Found subscriptions', { count: result.Items?.length || 0 });

    const resp = success(200, result.Items || []);
    logResponse('List subscriptions', event, resp, startTime);
    return resp;

  } catch (err) {
    logger.error('List subscriptions failed', { error: err.name, message: err.message, stack: err.stack });
    const resp = err.statusCode ? error(err.statusCode, err.message) : error(500, 'Internal server error', err.message);
    logResponse('List subscriptions', event, resp, startTime);
    return resp;
  }
};