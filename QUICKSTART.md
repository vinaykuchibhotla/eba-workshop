# Quick Start Guide

## For Workshop Administrators

### Deploy the Bootstrap Stack

```bash
# Set your parameters
export DB_PASSWORD="YourSecurePassword123!"
export APP_PASSWORD="YourAppPassword123!"
export MY_IP="YOUR_IP_ADDRESS/32"

# Deploy the stack
aws cloudformation create-stack \
  --stack-name orchardlite-workshop \
  --template-body file://orchardlite-dotnet-bootstrap.yaml \
  --parameters \
    ParameterKey=DBPassword,ParameterValue=$DB_PASSWORD \
    ParameterKey=AppDBPassword,ParameterValue=$APP_PASSWORD \
    ParameterKey=MyIPAddress,ParameterValue=$MY_IP \
  --capabilities CAPABILITY_IAM \
  --region us-east-1

# Wait for completion (15-20 minutes)
aws cloudformation wait stack-create-complete \
  --stack-name orchardlite-workshop \
  --region us-east-1

# Get the application URL
aws cloudformation describe-stacks \
  --stack-name orchardlite-workshop \
  --query 'Stacks[0].Outputs[?OutputKey==`ApplicationURL`].OutputValue' \
  --output text \
  --region us-east-1
```

### Verify Deployment

```bash
# Get the ALB URL
ALB_URL=$(aws cloudformation describe-stacks \
  --stack-name orchardlite-workshop \
  --query 'Stacks[0].Outputs[?OutputKey==`ApplicationURL`].OutputValue' \
  --output text \
  --region us-east-1)

# Test health endpoint
curl $ALB_URL/health

# Expected response:
# {"status":"OK","phase":"Phase 1 - Current State","dotnetVersion":".NET Core 3.1",...}
```

### For Automated Account Vending

Add to your bootstrap script:

```bash
#!/bin/bash
# Deploy OrchardLite workshop environment

aws cloudformation create-stack \
  --stack-name orchardlite-workshop \
  --template-body file://orchardlite-dotnet-bootstrap.yaml \
  --parameters \
    ParameterKey=GitHubRepo,ParameterValue=https://github.com/vinaykuchibhotla/eba-workshop \
    ParameterKey=GitHubBranch,ParameterValue=main \
    ParameterKey=DBPassword,ParameterValue=${GENERATED_DB_PASSWORD} \
    ParameterKey=AppDBPassword,ParameterValue=${GENERATED_APP_PASSWORD} \
    ParameterKey=MyIPAddress,ParameterValue=0.0.0.0/0 \
  --capabilities CAPABILITY_IAM \
  --region ${AWS_REGION}
```

## For Workshop Participants

### Access Your Environment

1. **Get your Application URL** from the workshop instructor or CloudFormation Outputs
2. **Open in browser:** `http://orchardlite-alb-xxxxx.region.elb.amazonaws.com`
3. **Verify the application is running** - you should see the OrchardLite CMS homepage

### Workshop Tasks

#### Task 1: AWS Transform Analysis

1. Navigate to **AWS Transform** console
2. Click **Create transformation project**
3. **Source:** GitHub repository `vinaykuchibhotla/eba-workshop`
4. **Path:** `/OrchardLiteApp`
5. Click **Analyze**
6. Review the modernization recommendations

#### Task 2: Review Current State

```bash
# Check application version
curl http://YOUR-ALB-URL/health | jq .

# Expected output shows .NET Core 3.1
```

#### Task 3: Database Migration (DMS)

Use the existing DMS templates:
- `/Platform/dms-endpoints-setup-eba.yaml`
- `/Database/db-dms-setup-eba.yaml`

Follow the guide: `/Database/DMS-TASK-START-GUIDE.md`

#### Task 4: CodePipeline Setup

Use the existing pipeline template:
- `/DevOps/create-pipeline-eba.yaml`

This will be configured after AWS Transform upgrades the code.

## Troubleshooting

### Stack Creation Fails

```bash
# Check stack events
aws cloudformation describe-stack-events \
  --stack-name orchardlite-workshop \
  --max-items 20 \
  --region us-east-1

# Check CodeBuild logs
aws logs tail /aws/codebuild/orchardlite-build --follow
```

### Application Not Accessible

```bash
# Check ECS service status
aws ecs describe-services \
  --cluster OrchardLite-Cluster \
  --services orchardlite-service \
  --region us-east-1

# Check ECS task logs
aws logs tail /ecs/orchardlite --follow
```

### Database Connection Issues

```bash
# Verify RDS is available
aws rds describe-db-instances \
  --db-instance-identifier orchardlite-mysql \
  --query 'DBInstances[0].DBInstanceStatus' \
  --region us-east-1

# Check security group rules
aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values=OrchardLite-Database-SG" \
  --region us-east-1
```

## Cleanup

```bash
# Delete the stack
aws cloudformation delete-stack \
  --stack-name orchardlite-workshop \
  --region us-east-1

# Wait for deletion
aws cloudformation wait stack-delete-complete \
  --stack-name orchardlite-workshop \
  --region us-east-1
```

## Cost Management

### Estimated Costs (us-east-1)

- **RDS db.t3.micro:** $0.017/hour
- **ECS Fargate (0.5 vCPU, 1GB):** $0.024/hour  
- **ALB:** $0.025/hour
- **Total:** ~$0.07/hour or ~$1.68/day

### Cost Optimization Tips

1. **Stop when not in use:** Delete stack between workshop sessions
2. **Use smaller instances:** Already using minimum sizes
3. **Limit data transfer:** Keep within free tier
4. **Set billing alerts:** Monitor unexpected charges

## Support

### Common Issues

**Issue:** CodeBuild times out
- **Solution:** Check GitHub repository is accessible, verify buildspec.yml exists

**Issue:** ECS tasks keep restarting
- **Solution:** Check database connectivity, review task logs in CloudWatch

**Issue:** Health checks failing
- **Solution:** Verify security groups allow traffic, check `/health` endpoint

### Getting Help

1. Check CloudFormation Events tab
2. Review CloudWatch Logs
3. Verify all prerequisites
4. Contact workshop support

## Quick Reference

### Important URLs

- **Application:** `http://YOUR-ALB-DNS`
- **Health Check:** `http://YOUR-ALB-DNS/health`
- **All Content:** `http://YOUR-ALB-DNS/all-content`

### Important ARNs (from Outputs)

- **ECR Repository:** Check `ECRRepositoryURI` output
- **ECS Cluster:** Check `ECSClusterName` output
- **Database Endpoint:** Check `DatabaseEndpoint` output
- **CodeBuild Project:** Check `CodeBuildProjectName` output

### Key Files

- **Application Code:** `/OrchardLiteApp/`
- **CloudFormation Template:** `orchardlite-dotnet-bootstrap.yaml`
- **Build Spec:** `buildspec.yml`
- **Documentation:** `WORKSHOP-SETUP.md`

---

**Ready to Start!** Deploy the stack and begin your modernization journey.
