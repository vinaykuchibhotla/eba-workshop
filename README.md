# OrchardLite CMS - AWS Modernization Workshop

## 🚀 Quick Deploy (5 minutes)

### Prerequisites
- AWS CLI configured (`aws configure`)

### Deploy
```bash
./deploy.sh
```

### Get Application URL
```bash
aws cloudformation describe-stacks --stack-name orchardlite-workshop-* --query 'Stacks[0].Outputs[?OutputKey==`ApplicationURL`].OutputValue' --output text
```

## 📊 What You'll See

### Phase 1 - Current State (Insecure by Design)
- 🔴 **.NET Framework 4.8** - Legacy framework
- 🔴 **RDS MySQL (Public)** - Database in public subnet
- 🔴 **Public Subnets Only** - No network isolation
- 🔴 **Manual CloudFormation** - No CI/CD pipeline
- 🔴 **License Issues** - GPL/AGPL compliance problems

### After Modernization (Workshop Goal)
- 🟢 **.NET 8.0** - Modern framework
- 🟢 **Aurora MySQL (Serverless)** - Modern managed database
- 🟢 **Private Subnets + VPC Endpoints** - Secure network
- 🟢 **CI/CD Pipeline Active** - Full automation
- 🟢 **License Compliant** - Issues resolved

## 🔧 Workshop Flow
1. **Deploy Phase 1** - See current insecure state
2. **AWS Transform** - Modernize .NET Framework → .NET 8
3. **Database Migration** - RDS → Aurora using AWS DMS
4. **Network Security** - Public → Private subnets
5. **DevOps Pipeline** - Manual → CI/CD automation
6. **License Compliance** - Resolve GPL/AGPL issues

## 🎪 Live Status Detection
The application automatically detects and displays:
- Framework version changes
- Database migration progress
- Network security improvements
- Deployment pipeline status
- License compliance status

**The UI updates in real-time as you complete each modernization step!**

## 🧹 Cleanup
```bash
# Delete the stack when done
aws cloudformation delete-stack --stack-name orchardlite-workshop-*
```

## 🆘 Troubleshooting
- **Stack creation failed**: Check AWS CLI configuration and permissions
- **Application not accessible**: Wait 5-8 minutes for full deployment
- **Database connection issues**: RDS takes longest to initialize

---
**Ready to modernize? Run `./deploy.sh` and let's begin!** 🚀