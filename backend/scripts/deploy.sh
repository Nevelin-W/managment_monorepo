#!/bin/bash

# Deployment script for Subscription Tracker backend
# Usage: ./scripts/deploy.sh dev|prod

set -euo pipefail

ENVIRONMENT="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$(dirname "$SCRIPT_DIR")"
LAMBDA_DIR="$HOME_DIR/terraform/lambda_functions"

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: ./backend/scripts/deploy.sh [dev|prod]"
  exit 1
fi

if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; then
  echo "Environment must be 'dev' or 'prod'"
  exit 1
fi

echo "Deploying to $ENVIRONMENT environment..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Step 1: Install Lambda dependencies
echo -e "${BLUE}Installing Lambda dependencies...${NC}"
cd "$LAMBDA_DIR"
npm ci --omit=dev
cd ..

# Step 2: Create Lambda layer
echo -e "${BLUE}Creating Lambda layer...${NC}"
mkdir -p "$LAMBDA_DIR/layers/nodejs"
cp -r "$LAMBDA_DIR/node_modules" "$LAMBDA_DIR/layers/nodejs/"
cd "$LAMBDA_DIR/layers"
zip -r -q dependencies.zip nodejs

# Step 3: Package each Lambda function (including shared module)
echo -e "${BLUE}Packaging Lambda functions...${NC}"

LAMBDA_DIRS=(
  "auth/login"
  "auth/signup"
  "auth/me"
  "auth/confirm_signup"
  "auth/resend_code"
  "auth/update_profile"
  "auth/change_password"
  "subscriptions/list"
  "subscriptions/create"
  "subscriptions/update"
  "subscriptions/delete"
  "email_processor"
)

for dir in "${LAMBDA_DIRS[@]}"; do
  echo "  Packaging $dir..."
  FUNCTION_DIR="$LAMBDA_DIR/$dir"
  
  # Clean previous build
  rm -f "$FUNCTION_DIR/function.zip"
  
  # Create zip with the function code
  cd "$FUNCTION_DIR"
  zip -r -q function.zip index.js
  
  # Add shared module to the zip
  cd "$LAMBDA_DIR"
  zip -r -q "$FUNCTION_DIR/function.zip" shared/
done

echo -e "${GREEN}Packaging complete!${NC}"

# Step 4: Deploy infrastructure with Terraform
# echo -e "${BLUE}Deploying infrastructure...${NC}"
# cd "$HOME_DIR/terraform/environments/$ENVIRONMENT"
# terraform init
# terraform plan -out=tfplan
# terraform apply tfplan
# rm tfplan

# echo -e "${GREEN}Deployment complete!${NC}"
# echo "API Endpoint: $(terraform output -raw api_endpoint)"
# echo "User Pool ID: $(terraform output -raw user_pool_id)"