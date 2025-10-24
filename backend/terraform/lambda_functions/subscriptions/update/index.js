const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, UpdateCommand } = require("@aws-sdk/lib-dynamodb");

const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

exports.handler = async (event) => {
  console.log('Update subscription request:', JSON.stringify(event, null, 2));
  
  try {
    const userId = event.requestContext.authorizer.claims.sub;
    const subscriptionId = event.pathParameters.id;
    
    if (!userId || !subscriptionId) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Missing required parameters' }),
      };
    }

    const body = JSON.parse(event.body);
    const { name, amount, billing_cycle, next_billing_date, category, description, is_active } = body;

    // First, verify the subscription belongs to the user
    const getCommand = new GetCommand({
      TableName: process.env.SUBSCRIPTIONS_TABLE,
      Key: {
        id: subscriptionId,
        user_id: userId,
      },
    });

    const existingItem = await dynamoClient.send(getCommand);
    
    if (!existingItem.Item) {
      return {
        statusCode: 404,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Subscription not found' }),
      };
    }

    // Build update expression dynamically
    const updateExpressions = [];
    const expressionAttributeNames = {};
    const expressionAttributeValues = {
      ':timestamp': new Date().toISOString(),
    };

    if (name !== undefined) {
      updateExpressions.push('#name = :name');
      expressionAttributeNames['#name'] = 'name';
      expressionAttributeValues[':name'] = name;
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

    // Always update the timestamp
    updateExpressions.push('updated_at = :timestamp');

    const updateCommand = new UpdateCommand({
      TableName: process.env.SUBSCRIPTIONS_TABLE,
      Key: {
        id: subscriptionId,
        user_id: userId,
      },
      UpdateExpression: `SET ${updateExpressions.join(', ')}`,
      ExpressionAttributeNames: Object.keys(expressionAttributeNames).length > 0 ? expressionAttributeNames : undefined,
      ExpressionAttributeValues: expressionAttributeValues,
      ReturnValues: 'ALL_NEW',
    });

    const result = await dynamoClient.send(updateCommand);

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify(result.Attributes),
    };

  } catch (error) {
    console.error('Update subscription error:', error);
    
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