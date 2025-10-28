const { S3Client, GetObjectCommand, PutObjectCommand } = require("@aws-sdk/client-s3");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, QueryCommand, UpdateCommand, PutCommand } = require("@aws-sdk/lib-dynamodb");
const { randomUUID } = require('crypto');

const s3Client = new S3Client({ region: process.env.AWS_REGION });
const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));

/**
 * Email Processor Lambda
 * This function:
 * 1. Checks for new subscription-related emails (via Gmail API or SES)
 * 2. Extracts relevant information (amount, date, merchant)
 * 3. Compares with existing subscriptions
 * 4. Logs price changes and triggers notifications
 */

exports.handler = async (event) => {
  console.log('Email processor triggered:', JSON.stringify(event, null, 2));
  
  try {
    // TODO: Implement Gmail API integration
    // For now, this is a placeholder that would:
    // 1. Poll Gmail API for new emails with filters
    // 2. Download email content and attachments
    // 3. Use AI (Claude/GPT) to extract subscription data
    // 4. Update subscription records
    
    console.log('Email processing would happen here');
    
    // Example: Process email content
    const emailData = await processEmailContent(event);
    
    if (emailData) {
      await updateSubscriptionData(emailData);
    }
    
    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Email processing completed' }),
    };

  } catch (error) {
    console.error('Email processor error:', error);
    
    return {
      statusCode: 500,
      body: JSON.stringify({ 
        error: 'Email processing failed',
        message: error.message 
      }),
    };
  }
};

async function processEmailContent(event) {
  // Placeholder for email parsing logic
  // In production, this would:
  // 1. Extract text from email body
  // 2. Call AI API (Claude/GPT) to extract structured data(idk man do i want ai?)
  // 3. Return parsed subscription info
  
  return null;
}

async function updateSubscriptionData(emailData) {
  // Placeholder for updating subscription records
  // In production, this would:
  // 1. Find matching subscription by merchant name
  // 2. Compare current price with new price
  // 3. If changed, log the change and send notification
  
  const { userId, merchant, amount, billingDate } = emailData;
  
  // Query existing subscriptions
  const queryCommand = new QueryCommand({
    TableName: process.env.SUBSCRIPTIONS_TABLE,
    IndexName: 'UserIndex',
    KeyConditionExpression: 'user_id = :userId',
    FilterExpression: 'contains(#name, :merchant)',
    ExpressionAttributeNames: {
      '#name': 'name',
    },
    ExpressionAttributeValues: {
      ':userId': userId,
      ':merchant': merchant,
    },
  });

  const result = await dynamoClient.send(queryCommand);
  
  if (result.Items && result.Items.length > 0) {
    const subscription = result.Items[0];
    
    // Check if price changed
    if (subscription.amount !== amount) {
      console.log(`Price change detected for ${merchant}: ${subscription.amount} -> ${amount}`);
      
      // Log the change
      await logPriceChange(subscription.id, subscription.amount, amount);
      
      // Update subscription
      const updateCommand = new UpdateCommand({
        TableName: process.env.SUBSCRIPTIONS_TABLE,
        Key: {
          id: subscription.id,
          user_id: userId,
        },
        UpdateExpression: 'SET amount = :newAmount, updated_at = :timestamp',
        ExpressionAttributeValues: {
          ':newAmount': amount,
          ':timestamp': new Date().toISOString(),
        },
      });
      
      await dynamoClient.send(updateCommand);
      
      // TODO: Send notification to user
    }
  }
}

async function logPriceChange(subscriptionId, oldPrice, newPrice) {
  const changeId = randomUUID();
  const timestamp = new Date().toISOString();
  
  const putCommand = new PutCommand({
    TableName: `${process.env.SUBSCRIPTIONS_TABLE}-changes`,
    Item: {
      id: changeId,
      subscription_id: subscriptionId,
      old_price: oldPrice,
      new_price: newPrice,
      detected_at: timestamp,
      ttl: Math.floor(Date.now() / 1000) + (90 * 24 * 60 * 60), // 90 days TTL
    },
  });
  
  await dynamoClient.send(putCommand);
}