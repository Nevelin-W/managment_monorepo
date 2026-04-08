const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, DeleteCommand } = require("@aws-sdk/lib-dynamodb");
const { success, error, logRequest, logResponse, logger, extractClaims } = require("../../shared/response");

const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

exports.handler = async (event) => {
  logRequest('Delete subscription', event);
  const startTime = Date.now();
  
  try {
    const { userId } = extractClaims(event);
    const subscriptionId = event.pathParameters?.id;
    
    if (!subscriptionId) {
      return error(400, 'Subscription ID is required');
    }

    // Verify the subscription exists and belongs to the user
    const existingItem = await dynamoClient.send(new GetCommand({
      TableName: process.env.SUBSCRIPTIONS_TABLE,
      Key: { id: subscriptionId, user_id: userId },
    }));
    
    if (!existingItem.Item) {
      return error(404, 'Subscription not found');
    }

    await dynamoClient.send(new DeleteCommand({
      TableName: process.env.SUBSCRIPTIONS_TABLE,
      Key: { id: subscriptionId, user_id: userId },
    }));

    const resp = success(200, { message: 'Subscription deleted successfully', id: subscriptionId });
    logResponse('Delete subscription', event, resp, startTime);
    return resp;

  } catch (err) {
    logger.error('Delete subscription failed', { error: err.name, message: err.message, stack: err.stack });
    const resp = err.statusCode ? error(err.statusCode, err.message) : error(500, 'Internal server error', err.message);
    logResponse('Delete subscription', event, resp, startTime);
    return resp;
  }
};