const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");
const { randomUUID } = require('crypto');
const { success, error, logRequest, logResponse, logger, parseBody, extractClaims } = require("../../shared/response");

const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

const VALID_BILLING_CYCLES = ['monthly', 'yearly', 'weekly'];

exports.handler = async (event) => {
  logRequest('Create subscription', event);
  const startTime = Date.now();
  
  try {
    const { userId } = extractClaims(event);
    const body = parseBody(event);
    const { name, amount, billing_cycle, next_billing_date, category, description } = body;

    if (!name || amount == null || !billing_cycle || !next_billing_date) {
      return error(400, 'Missing required fields: name, amount, billing_cycle, next_billing_date');
    }

    const parsedAmount = parseFloat(amount);
    if (isNaN(parsedAmount) || parsedAmount < 0) {
      return error(400, 'Amount must be a non-negative number');
    }

    if (!VALID_BILLING_CYCLES.includes(billing_cycle)) {
      return error(400, `Invalid billing_cycle. Must be one of: ${VALID_BILLING_CYCLES.join(', ')}`);
    }

    // Validate date format
    if (isNaN(Date.parse(next_billing_date))) {
      return error(400, 'Invalid next_billing_date format');
    }

    const subscriptionId = randomUUID();
    const timestamp = new Date().toISOString();

    const subscription = {
      id: subscriptionId,
      user_id: userId,
      name: name.trim(),
      amount: parsedAmount,
      billing_cycle,
      next_billing_date,
      category: category || null,
      description: description || null,
      is_active: true,
      created_at: timestamp,
      updated_at: timestamp,
    };

    await dynamoClient.send(new PutCommand({
      TableName: process.env.SUBSCRIPTIONS_TABLE,
      Item: subscription,
    }));

    const resp = success(201, subscription);
    logResponse('Create subscription', event, resp, startTime);
    return resp;

  } catch (err) {
    logger.error('Create subscription failed', { error: err.name, message: err.message, stack: err.stack });
    const resp = err.statusCode ? error(err.statusCode, err.message) : error(500, 'Internal server error', err.message);
    logResponse('Create subscription', event, resp, startTime);
    return resp;
  }
};