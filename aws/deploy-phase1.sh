#!/bin/bash

# OrchardLite CMS - Phase 1 Prestage Simple Deployment
# Reliable ECS + RDS MySQL setup without Lambda complexity

set -e

STACK_NAME="orchardlite-baseline"
REGION="us-west-1"
TEMPLATE_FILE="aws/cloudformation/phase1-stable.yaml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
print_status "🚀 OrchardLite CMS - Enterprise Baseline (Production Ready)"
print_status "Stack: $STACK_NAME | Region: $REGION"
echo ""

# Validate template
print_status "Validating CloudFormation template..."
if aws cloudformation validate-template --template-body file://$TEMPLATE_FILE --region $REGION > /dev/null 2>&1; then
    print_success "Template validation passed"
else
    print_error "Template validation failed"
    exit 1
fi

# Deploy stack
print_status "Deploying stack (this will take 8-12 minutes)..."
aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://$TEMPLATE_FILE \
    --capabilities CAPABILITY_IAM \
    --region $REGION

print_status "Waiting for stack creation to complete..."
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME --region $REGION

if [ $? -eq 0 ]; then
    print_success "✅ Stack deployment completed successfully!"
    
    # Get outputs
    APP_URL=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query 'Stacks[0].Outputs[?OutputKey==`ApplicationURL`].OutputValue' --output text)
    
    echo ""
    print_success "🌐 Application URL: $APP_URL"
    print_status "🎯 Enterprise Baseline Deployment Complete!"
    echo ""
    print_status "✅ What's been deployed:"
    print_status "   • ECS Fargate with .NET Framework 4.8 application"
    print_status "   • RDS MySQL 8.0 database"
    print_status "   • Application Load Balancer"
    print_status "   • VPC with proper networking"
    print_status "   • Sample data automatically created"
    echo ""
    print_success "🚀 Ready for Phase 2: Assessment & Planning"
else
    print_error "Stack deployment failed"
    exit 1
fi