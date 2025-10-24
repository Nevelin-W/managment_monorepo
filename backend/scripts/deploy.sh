#!/bin/bash

# Deployment script for Subscription Tracker backend
# Usage: ./scripts/deploy.sh dev|prod

set -e

ENVIRONMENT=$1
HOME_DIR=$(pwd)
LAMBDA_DIR="$HOME_DIR/backend/terraform/lambda_functions"


if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: ./managment_monorepo/backend/scripts/deploy.sh [dev|prod]"
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
NC='\033[0m' # No Color

# Step 1: Install Lambda dependencies
echo -e "${BLUE} Installing Lambda dependencies...${NC}"
cd $LAMBDA_DIR
npm install --omit=dev
cd ..

# Step 2: Create Lambda layer
echo -e "${BLUE} Creating Lambda layer...${NC}"
mkdir -p "$LAMBDA_DIR/layers/nodejs"
cp -r "$LAMBDA_DIR/node_modules" "$LAMBDA_DIR/layers/nodejs/"
cd "$LAMBDA_DIR/layers"
zip -r dependencies.zip nodejs

# # Step 3: Package each Lambda function
# echo -e "${BLUE}Packaging Lambda functions...${NC}"

LAMBDA_DIRS=(
  "auth/login"
  "auth/signup"
  "auth/me"
  "subscriptions/list"
  "subscriptions/create"
  "subscriptions/update"
  "subscriptions/delete"
  "email_processor"
)

for dir in "${LAMBDA_DIRS[@]}"; do
  echo "  Packaging $dir..."
  FUNCTION_DIR="$LAMBDA_DIR/$dir"
  cd "$LAMBDA_DIR/$dir"
  zip -r function.zip index.js
done

# # Step 4: Deploy infrastructure with Terraform
# echo -e "${BLUE}🏗️  Deploying infrastructure...${NC}"
# cd terraform/environments/$ENVIRONMENT

# terraform init
# terraform plan -var-file=variables.tfvars -out=tfplan
# terraform apply tfplan

# # Step 5: Get outputs
# echo -e "${GREEN}✅ Deployment complete!${NC}"
# echo -e "${BLUE}📊 Infrastructure outputs:${NC}"
# terraform output

# # Clean up
# rm tfplan

# echo -e "${GREEN}🎉 Deployment successful!${NC}"
# echo ""
# echo "API Endpoint: $(terraform output -raw api_endpoint)"
# echo "User Pool ID: $(terraform output -raw user_pool_id)"
# echo ""
# echo "Update your Flutter app with these values!"