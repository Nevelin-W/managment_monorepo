const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, DeleteCommand } = require("@aws-sdk/lib-dynamodb");

const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

exports.handler = async (event) => {
  console.log('Delete subscription request:', JSON.stringify(event, null, 2));
  
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

    // First, verify the subscription exists and belongs to the user
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

    // Delete the subscription
    const deleteCommand = new DeleteCommand({
      TableName: process.env.SUBSCRIPTIONS_TABLE,
      Key: {
        id: subscriptionId,
        user_id: userId,
      },
    });

    await dynamoClient.send(deleteCommand);

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({ 
        message: 'Subscription deleted successfully',
        id: subscriptionId,
      }),
    };

  } catch (error) {
    console.error('Delete subscription error:', error);
    
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