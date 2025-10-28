const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, QueryCommand } = require("@aws-sdk/lib-dynamodb");

const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

exports.handler = async (event) => {
  console.log('Full event:', JSON.stringify(event, null, 2));
  console.log('Request context:', JSON.stringify(event.requestContext, null, 2));
  console.log('Authorizer:', JSON.stringify(event.requestContext?.authorizer, null, 2));
  
  try {
    // Check if authorizer context exists
    if (!event.requestContext?.authorizer) {
      console.error('No authorizer context found');
      return {
        statusCode: 401,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ 
          error: 'Unauthorized',
          detail: 'No authorizer context'
        }),
      };
    }

    // Extract user ID from Cognito authorizer claims
    const userId = event.requestContext.authorizer.claims?.sub;
    
    if (!userId) {
      console.error('No user ID in claims:', event.requestContext.authorizer.claims);
      return {
        statusCode: 401,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ 
          error: 'Unauthorized',
          detail: 'No user ID in token claims'
        }),
      };
    }

    console.log('Querying subscriptions for user:', userId);

    // Query subscriptions by user_id
    const queryCommand = new QueryCommand({
      TableName: process.env.SUBSCRIPTIONS_TABLE,
      IndexName: 'UserIndex',
      KeyConditionExpression: 'user_id = :userId',
      ExpressionAttributeValues: {
        ':userId': userId,
      },
    });

    const result = await dynamoClient.send(queryCommand);
    
    console.log(`Found ${result.Items?.length || 0} subscriptions`);

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify(result.Items || []),
    };

  } catch (error) {
    console.error('List subscriptions error:', error);
    console.error('Error stack:', error.stack);
    
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