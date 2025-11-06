# Design Document

## Overview

This design modifies the existing DevOps CloudFormation template to remove all ALB-related resources. The template will focus solely on the CI/CD pipeline, ECS deployment, and target group creation. ALB integration will be handled by a separate template later.

## Architecture

### Current Architecture
- Creates new ALB, target group, listener, and security group
- ECS service directly connects to new ALB

### New Architecture  
- Remove all ALB-related resources completely
- Create only target group for modernized application
- ECS service deploys to target group (no ALB integration)
- Separate template will handle ALB integration later

## Components and Interfaces

### Resource Modifications

#### Removed Resources
- **ApplicationLoadBalancer** - Remove entirely
- **ALBSecurityGroup** - Remove entirely  
- **ALBListener** - Remove entirely

#### Modified Resources
- **ALBTargetGroup** - Keep as-is, will be used by future ALB integration
- **ECSSecurityGroup** - Remove ALB-related ingress rules, keep only outbound rules

#### Unchanged Resources
- **ECSCluster** - No changes
- **ECSTaskDefinition** - No changes  
- **CodeBuild Projects** - No changes
- **CodePipeline** - No changes
- **ECR Repository** - No changes

## Data Models

### Target Group Configuration
```yaml
TargetGroupConfig:
  Name: String
  Port: 8080
  Protocol: HTTP
  HealthCheckPath: /health
  VPCId: String
  TargetType: ip
```

### ECS Security Group Configuration
```yaml
ECSSecurityGroupConfig:
  EgressRules:
    - Port: 443
      Protocol: TCP
      Destination: 0.0.0.0/0 (HTTPS outbound for AWS services)
    - Port: 3306
      Protocol: TCP  
      Destination: 10.0.0.0/16 (MySQL access to Aurora database)
```

## Error Handling

### Resource Dependencies
- Ensure target group creation before ECS service
- Target group must be in correct VPC
- ECS security group must allow outbound connectivity

## Testing Strategy

### Integration Testing  
- Deploy template without ALB resources
- Verify ECS service registration with target group
- Validate ECS security group allows required outbound connectivity
- Test application deployment and health checks

## Implementation Changes

### Template Modifications
1. **Remove Resources**: ApplicationLoadBalancer, ALBSecurityGroup, ALBListener  
2. **Update ECS Security Group**: Remove ALB ingress rules, keep only outbound rules
3. **Update Outputs**: Remove all ALB-related outputs
4. **Remove Parameters**: Remove ALB-related subnet parameters

### Deployment Workflow
1. Deploy modified template (no ALB integration)
2. Target group created (standalone, not connected to ALB)
3. ECS service deploys .NET 8 application to target group
4. Separate template will handle ALB integration later