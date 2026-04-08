/**
 * Shared response helpers for Lambda functions.
 * Provides consistent CORS headers, structured JSON logging, and response formatting.
 */

const CORS_HEADERS = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': process.env.ALLOWED_ORIGIN || '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization,X-Access-Token,X-Amz-Date,X-Api-Key,X-Amz-Security-Token',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
};

/**
 * Structured JSON logger for CloudWatch Logs Insights.
 * Every log line is valid JSON so you can query with:
 *   fields @timestamp, level, route, statusCode, duration
 *   | filter level = "ERROR"
 *   | sort @timestamp desc
 */
const logger = {
  _base(level, message, data = {}) {
    const entry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      environment: process.env.ENVIRONMENT || 'unknown',
      functionName: process.env.AWS_LAMBDA_FUNCTION_NAME || 'unknown',
      ...data,
    };
    const line = JSON.stringify(entry);
    if (level === 'ERROR') {
      process.stderr.write(line + '\n');
    } else {
      process.stdout.write(line + '\n');
    }
  },
  info(message, data) { this._base('INFO', message, data); },
  warn(message, data) { this._base('WARN', message, data); },
  error(message, data) { this._base('ERROR', message, data); },
};

/**
 * Create a successful JSON response
 * @param {number} statusCode - HTTP status code
 * @param {object} body - Response body object
 * @returns {object} API Gateway response
 */
function success(statusCode, body) {
  return {
    statusCode,
    headers: CORS_HEADERS,
    body: JSON.stringify(body),
  };
}

/**
 * Create an error JSON response
 * @param {number} statusCode - HTTP status code
 * @param {string} error - Error message
 * @param {string} [message] - Optional detailed message (only included in non-prod)
 * @returns {object} API Gateway response
 */
function error(statusCode, errorMsg, message) {
  const body = { error: errorMsg };
  if (message && process.env.ENVIRONMENT !== 'prod') {
    body.message = message;
  }
  return {
    statusCode,
    headers: CORS_HEADERS,
    body: JSON.stringify(body),
  };
}

/**
 * Log an incoming request with safe metadata (no passwords/tokens).
 * Outputs structured JSON for CloudWatch Logs Insights queries.
 * @param {string} label - Log label (e.g. 'Login request')
 * @param {object} event - API Gateway event
 */
function logRequest(label, event) {
  const requestId = event.requestContext?.requestId;
  const userId = event.requestContext?.authorizer?.claims?.sub;
  logger.info(label, {
    requestId,
    route: `${event.httpMethod} ${event.path}`,
    sourceIp: event.requestContext?.identity?.sourceIp,
    userAgent: event.requestContext?.identity?.userAgent,
    userId: userId || undefined,
    pathParameters: event.pathParameters || undefined,
    queryStringParameters: event.queryStringParameters || undefined,
  });
}

/**
 * Log the response being returned.
 * Call this before returning to capture status code + duration in logs.
 * @param {string} label - Log label
 * @param {object} event - API Gateway event (for requestId)
 * @param {object} response - The API GW response object { statusCode, body }
 * @param {number} startTime - Date.now() from the start of the handler
 */
function logResponse(label, event, response, startTime) {
  const duration = Date.now() - startTime;
  const level = response.statusCode >= 500 ? 'error' : response.statusCode >= 400 ? 'warn' : 'info';
  logger[level](`${label} completed`, {
    requestId: event.requestContext?.requestId,
    route: `${event.httpMethod} ${event.path}`,
    statusCode: response.statusCode,
    duration,
  });
}

/**
 * Parse and validate JSON body from event
 * @param {object} event - API Gateway event
 * @returns {object} Parsed body
 * @throws {Error} If body is missing or invalid JSON
 */
function parseBody(event) {
  if (!event.body) {
    throw Object.assign(new Error('Request body is required'), { statusCode: 400 });
  }
  try {
    return JSON.parse(event.body);
  } catch {
    throw Object.assign(new Error('Invalid JSON in request body'), { statusCode: 400 });
  }
}

/**
 * Extract and validate user ID from Cognito authorizer claims
 * @param {object} event - API Gateway event
 * @returns {{ userId: string, email: string }} Extracted claims
 * @throws {Error} If claims are missing
 */
function extractClaims(event) {
  const claims = event.requestContext?.authorizer?.claims;
  if (!claims?.sub) {
    throw Object.assign(new Error('Unauthorized'), { statusCode: 401 });
  }
  return { userId: claims.sub, email: claims.email };
}

/**
 * Simple email format validation
 * @param {string} email
 * @returns {boolean}
 */
function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

module.exports = {
  CORS_HEADERS,
  logger,
  success,
  error,
  logRequest,
  logResponse,
  parseBody,
  extractClaims,
  isValidEmail,
};
