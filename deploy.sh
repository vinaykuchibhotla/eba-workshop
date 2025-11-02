#!/bin/bash

# OrchardLite CMS - Workshop Deployment Script
# Simple one-click deployment for workshop participants

echo "🚀 OrchardLite CMS Workshop - Phase 1 Deployment"
echo "================================================"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Get current region
REGION=$(aws configure get region)
echo "📍 Deploying to region: $REGION"

# Get user's IP for security (optional - defaults to 0.0.0.0/0 if not provided)
echo "🔒 Getting your IP address for secure access..."
MY_IP=$(curl -s https://checkip.amazonaws.com)
if [ -n "$MY_IP" ]; then
    MY_IP_CIDR="$MY_IP/32"
    echo "   Your IP: $MY_IP_CIDR"
else
    MY_IP_CIDR="0.0.0.0/0"
    echo "   Using default: $MY_IP_CIDR (open access)"
fi

# Deploy the stack
STACK_NAME="orchardlite-workshop-$(date +%s)"
echo "📦 Creating CloudFormation stack: $STACK_NAME"

aws cloudformation create-stack \
    --stack-name "$STACK_NAME" \
    --template-body file://orchardlite-cms.yaml \
    --capabilities CAPABILITY_IAM \
    --parameters ParameterKey=MyIPAddress,ParameterValue="$MY_IP_CIDR" \
    --tags Key=Project,Value=OrchardLite Key=Environment,Value=Workshop Key=Phase,Value=Phase1

if [ $? -eq 0 ]; then
    echo "✅ Stack creation initiated successfully!"
    echo ""
    echo "⏳ Deployment in progress (this takes 5-8 minutes)..."
    echo "   Stack Name: $STACK_NAME"
    echo ""
    echo "🔍 Monitor progress:"
    echo "   aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].StackStatus'"
    echo ""
    echo "📱 Once complete, get your application URL:"
    echo "   aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].Outputs[?OutputKey==\`ApplicationURL\`].OutputValue' --output text"
    echo ""
    echo "🎯 What's being deployed:"
    echo "   • VPC with public subnets (Phase 1 - insecure by design)"
    echo "   • RDS MySQL database with sample data"
    echo "   • ECS Fargate application (.NET Framework 4.8 simulation)"
    echo "   • Application Load Balancer"
    echo "   • 100 sample content records for migration demo"
    echo ""
    echo "⚠️  Phase 1 Status: INSECURE (demonstrates current state before modernization)"
else
    echo "❌ Stack creation failed!"
    exit 1
fi