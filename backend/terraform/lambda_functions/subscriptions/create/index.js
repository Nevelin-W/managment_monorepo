const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");
const { randomUUID } = require('crypto');

const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

exports.handler = async (event) => {
  console.log('Create subscription request:', JSON.stringify(event, null, 2));
  
  try {
    const userId = event.requestContext.authorizer.claims.sub;
    
    if (!userId) {
      return {
        statusCode: 401,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Unauthorized' }),
      };
    }

    const body = JSON.parse(event.body);
    const { name, amount, billing_cycle, next_billing_date, category, description } = body;

    if (!name || !amount || !billing_cycle || !next_billing_date) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Missing required fields' }),
      };
    }

    const subscriptionId = randomUUID();
    const timestamp = new Date().toISOString();

    const subscription = {
      id: subscriptionId,
      user_id: userId,
      name,
      amount: parseFloat(amount),
      billing_cycle,
      next_billing_date,
      category: category || null,
      description: description || null,
      is_active: true,
      created_at: timestamp,
      updated_at: timestamp,
    };

    const putCommand = new PutCommand({
      TableName: process.env.SUBSCRIPTIONS_TABLE,
      Item: subscription,
    });

    await dynamoClient.send(putCommand);

    return {
      statusCode: 201,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify(subscription),
    };

  } catch (error) {
    console.error('Create subscription error:', error);
    
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