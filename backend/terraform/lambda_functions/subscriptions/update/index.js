const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, UpdateCommand } = require("@aws-sdk/lib-dynamodb");
const { success, error, logRequest, logResponse, logger, parseBody, extractClaims } = require("../../shared/response");

const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

const VALID_BILLING_CYCLES = ['monthly', 'yearly', 'weekly'];

exports.handler = async (event) => {
  logRequest('Update subscription', event);
  const startTime = Date.now();
  
  try {
    const { userId } = extractClaims(event);
    const subscriptionId = event.pathParameters?.id;
    
    if (!subscriptionId) {
      return error(400, 'Subscription ID is required');
    }

    const body = parseBody(event);
    const { name, amount, billing_cycle, next_billing_date, category, description, is_active } = body;

    // Validate amount if provided
    if (amount !== undefined) {
      const parsedAmount = parseFloat(amount);
      if (isNaN(parsedAmount) || parsedAmount < 0) {
        return error(400, 'Amount must be a non-negative number');
      }
    }

    // Validate billing cycle if provided
    if (billing_cycle !== undefined && !VALID_BILLING_CYCLES.includes(billing_cycle)) {
      return error(400, `Invalid billing_cycle. Must be one of: ${VALID_BILLING_CYCLES.join(', ')}`);
    }

    // Verify the subscription belongs to the user
    const existingItem = await dynamoClient.send(new GetCommand({
      TableName: process.env.SUBSCRIPTIONS_TABLE,
      Key: { id: subscriptionId, user_id: userId },
    }));
    
    if (!existingItem.Item) {
      return error(404, 'Subscription not found');
    }

    // Build update expression dynamically
    const updateExpressions = ['updated_at = :timestamp'];
    const expressionAttributeNames = {};
    const expressionAttributeValues = {
      ':timestamp': new Date().toISOString(),
    };

    if (name !== undefined) {
      updateExpressions.push('#name = :name');
      expressionAttributeNames['#name'] = 'name';
      expressionAttributeValues[':name'] = name.trim();
    }
    if (amount !== undefined) {
      updateExpressions.push('amount = :amount');
      expressionAttributeValues[':amount'] = parseFloat(amount);
    }
    if (billing_cycle !== undefined) {
      updateExpressions.push('billing_cycle = :billingCycle');
      expressionAttributeValues[':billingCycle'] = billing_cycle;
    }
    if (next_billing_date !== undefined) {
      updateExpressions.push('next_billing_date = :nextBillingDate');
      expressionAttributeValues[':nextBillingDate'] = next_billing_date;
    }
    if (category !== undefined) {
      updateExpressions.push('category = :category');
      expressionAttributeValues[':category'] = category;
    }
    if (description !== undefined) {
      updateExpressions.push('description = :description');
      expressionAttributeValues[':description'] = description;
    }
    if (is_active !== undefined) {
      updateExpressions.push('is_active = :isActive');
      expressionAttributeValues[':isActive'] = is_active;
    }

    const result = await dynamoClient.send(new UpdateCommand({
      TableName: process.env.SUBSCRIPTIONS_TABLE,
      Key: { id: subscriptionId, user_id: userId },
      UpdateExpression: `SET ${updateExpressions.join(', ')}`,
      ExpressionAttributeNames: Object.keys(expressionAttributeNames).length > 0 ? expressionAttributeNames : undefined,
      ExpressionAttributeValues: expressionAttributeValues,
      ReturnValues: 'ALL_NEW',
    }));

    const resp = success(200, result.Attributes);
    logResponse('Update subscription', event, resp, startTime);
    return resp;

  } catch (err) {
    logger.error('Update subscription failed', { error: err.name, message: err.message, stack: err.stack });
    const resp = err.statusCode ? error(err.statusCode, err.message) : error(500, 'Internal server error', err.message);
    logResponse('Update subscription', event, resp, startTime);
    return resp;
  }
};