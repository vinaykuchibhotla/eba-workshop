# OrchardLite CMS - AWS Modernization Workshop Setup

## Overview

This repository contains a complete .NET Core 3.1 application and infrastructure setup for the AWS Modernization Workshop. The setup demonstrates a legacy application that will be modernized using AWS services.

## What Gets Deployed

The `orchardlite-dotnet-bootstrap.yaml` CloudFormation template automatically provisions:

### Infrastructure
- **VPC** with 2 public subnets across 2 availability zones
- **Internet Gateway** and routing
- **Security Groups** for ALB, ECS, and RDS
- **Application Load Balancer** for traffic distribution
- **RDS MySQL 8.0** database instance

### Application Platform
- **ECR Repository** for Docker images
- **CodeBuild Project** to build the .NET application
- **ECS Fargate Cluster** for container orchestration
- **ECS Service** running the .NET Core 3.1 application
- **CloudWatch Logs** for application logging

### Automation
- **Lambda Function** to trigger initial CodeBuild
- **Custom Resources** for automated deployment
- **Database initialization** on first application start

## Prerequisites

- AWS Account with appropriate permissions
- GitHub repository: `vinaykuchibhotla/eba-workshop`
- AWS CLI configured (optional, for manual deployment)

## Deployment Steps

### Option 1: AWS Console

1. **Log into AWS Console**
2. **Navigate to CloudFormation**
3. **Create Stack** → Upload template file: `orchardlite-dotnet-bootstrap.yaml`
4. **Configure Parameters:**
   - GitHubRepo: `https://github.com/vinaykuchibhotla/eba-workshop`
   - GitHubBranch: `main`
   - DBUsername: `orchardadmin` (or custom)
   - DBPassword: (set secure password)
   - AppDBUsername: `orchardapp` (or custom)
   - AppDBPassword: (set secure password)
   - MyIPAddress: Your IP in CIDR format (e.g., `1.2.3.4/32`)
5. **Create Stack** and wait for completion (15-20 minutes)

### Option 2: AWS CLI

```bash
aws cloudformation create-stack \
  --stack-name orchardlite-workshop \
  --template-body file://orchardlite-dotnet-bootstrap.yaml \
  --parameters \
    ParameterKey=DBPassword,ParameterValue=YourSecurePassword123! \
    ParameterKey=AppDBPassword,ParameterValue=YourAppPassword123! \
    ParameterKey=MyIPAddress,ParameterValue=YOUR_IP/32 \
  --capabilities CAPABILITY_IAM \
  --region us-east-1
```

### Option 3: Automated Account Vending

For workshop automation systems, include this template in your bootstrap scripts:

```bash
#!/bin/bash
aws cloudformation create-stack \
  --stack-name orchardlite-workshop \
  --template-body file://orchardlite-dotnet-bootstrap.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_IAM
```

## What Happens During Deployment

1. **Infrastructure Creation** (5 minutes)
   - VPC, subnets, security groups
   - RDS MySQL database
   - ALB and target groups

2. **Build Process** (10-15 minutes)
   - ECR repository created
   - CodeBuild triggered automatically
   - Docker image built from GitHub repo
   - Image pushed to ECR

3. **Application Deployment** (5 minutes)
   - ECS task definition created
   - ECS service launches container
   - Database initialized with sample data
   - Health checks pass
   - Application becomes available

## Accessing the Application

After deployment completes:

1. **Get the Application URL** from CloudFormation Outputs:
   - Output Key: `ApplicationURL`
   - Value: `http://orchardlite-alb-xxxxx.region.elb.amazonaws.com`

2. **Open in Browser:**
   - Navigate to the ALB DNS name
   - You should see the OrchardLite CMS homepage
   - Sample data (100 records) will be displayed

3. **Health Check:**
   - Endpoint: `http://ALB-DNS/health`
   - Returns JSON with application status

## Application Details

### Technology Stack
- **.NET Core 3.1** (legacy, end of life)
- **ASP.NET Core MVC**
- **MySQL 8.0** via MySql.Data connector
- **Bootstrap 5** for UI
- **Docker** containerization

### Database Schema
- **Database:** OrchardLiteDB
- **Table:** ContentItems (100 sample records)
- **Fields:** Id, Title, Summary, Body, ContentType, AuthorId, PublishedDate, ViewCount, IsPublished, CreatedDate

### Environment Variables
The application uses these environment variables (automatically configured):
- `DB_HOST` - RDS endpoint
- `DB_PORT` - 3306
- `DB_NAME` - OrchardLiteDB
- `DB_USER` - Application database user
- `DB_PASSWORD` - Application database password

## Workshop Tasks (Post-Deployment)

After the initial deployment, workshop participants will:

### Task 1: AWS Transform Analysis
1. Navigate to AWS Transform console
2. Point to GitHub repository
3. Analyze .NET Core 3.1 codebase
4. Review modernization recommendations

### Task 2: Code Modernization
1. AWS Transform upgrades code to .NET 8
2. Transform pushes upgraded code to repository
3. Review changes and improvements

### Task 3: CodePipeline Setup
1. Create CodePipeline (using existing CFT in `/DevOps`)
2. Configure GitHub source
3. Link to existing CodeBuild project
4. Deploy upgraded .NET 8 application

### Task 4: Database Migration (DMS)
1. Use existing DMS templates in `/Database`
2. Migrate from RDS MySQL to Aurora Serverless
3. Update application connection strings
4. Verify data integrity

### Task 5: Blue/Green Deployment
1. Create new target group for .NET 8 app
2. Deploy .NET 8 to new target group
3. Test both versions side-by-side
4. Swap ALB listener rules
5. Decommission .NET Core 3.1

## Troubleshooting

### Stack Creation Fails

**CodeBuild Timeout:**
- Check GitHub repository is accessible
- Verify buildspec.yml exists in repo root
- Check CodeBuild logs in CloudWatch

**RDS Creation Fails:**
- Verify subnet configuration
- Check security group rules
- Ensure password meets requirements

**ECS Service Won't Start:**
- Check ECR image was pushed successfully
- Verify database is accessible from ECS
- Review ECS task logs in CloudWatch

### Application Not Accessible

**ALB Health Checks Failing:**
- Verify `/health` endpoint responds
- Check security group allows traffic
- Ensure ECS tasks are running

**Database Connection Errors:**
- Verify RDS is in "Available" state
- Check security group allows port 3306
- Confirm environment variables are correct

### Build Failures

**Docker Build Fails:**
- Check Dockerfile syntax
- Verify .NET Core 3.1 SDK is available
- Review CodeBuild logs

**Image Push Fails:**
- Verify ECR repository exists
- Check IAM permissions for CodeBuild
- Ensure ECR login succeeded

## Cost Estimates

Approximate hourly costs (us-east-1):
- **RDS db.t3.micro:** $0.017/hour
- **ECS Fargate (0.5 vCPU, 1GB):** $0.024/hour
- **ALB:** $0.025/hour
- **NAT Gateway:** $0 (using public subnets)
- **Data Transfer:** Minimal for workshop
- **Total:** ~$0.07/hour or ~$1.68/day

## Cleanup

To avoid ongoing charges, delete the CloudFormation stack:

```bash
aws cloudformation delete-stack --stack-name orchardlite-workshop
```

Or via AWS Console:
1. Navigate to CloudFormation
2. Select the stack
3. Click "Delete"
4. Confirm deletion

**Note:** RDS database will be deleted (DeletionPolicy: Delete)

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                             │
└────────────────────────┬────────────────────────────────────┘
                         │
                    ┌────▼────┐
                    │   ALB   │
                    └────┬────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   ┌────▼────┐      ┌────▼────┐     ┌────▼────┐
   │ ECS Task│      │ ECS Task│     │   RDS   │
   │ (Fargate│      │ (Fargate│     │  MySQL  │
   │  .NET   │      │  .NET   │     │   8.0   │
   │ Core 3.1│      │ Core 3.1│     │         │
   └─────────┘      └─────────┘     └─────────┘
        │                │                │
        └────────────────┴────────────────┘
                         │
                    ┌────▼────┐
                    │   ECR   │
                    │  Image  │
                    └─────────┘
                         ▲
                         │
                    ┌────┴────┐
                    │CodeBuild│
                    │  Build  │
                    └─────────┘
                         ▲
                         │
                    ┌────┴────┐
                    │ GitHub  │
                    │  Repo   │
                    └─────────┘
```

## Support

For issues or questions:
1. Check CloudFormation Events tab for errors
2. Review CloudWatch Logs for application logs
3. Check CodeBuild logs for build failures
4. Verify all prerequisites are met

## Next Steps

After successful deployment:
1. ✅ Verify application is accessible
2. ✅ Review application logs in CloudWatch
3. ✅ Test database connectivity
4. ✅ Proceed with AWS Transform analysis
5. ✅ Continue with workshop tasks

---

**Workshop Ready!** Your .NET Core 3.1 application is now running and ready for modernization.
