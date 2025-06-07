# AWS Infrastructure with CloudFormation and CI/CD Pipeline

This codebase deploys AWS infrastructure using CloudFormation and sets up a CI/CD pipeline with AWS CodePipeline.

## Architecture

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                           AWS Cloud                                                                   │
│                                                                                                                                       │
│  ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐       │
│  │                                                           VPC                                                             │       │
│  │                                                                                                                           │       │
│  │  ┌────────────────────────────────────────────────┐              ┌────────────────────────────────────────────────┐      │       │
│  │  │            Public Subnet (10.0.1.0/24)         │              │            Private Subnet (10.0.2.0/24)         │      │       │
│  │  │                                                │              │                                                │      │       │
│  │  │                                                │              │                                                │      │       │
│  │  │    ┌────────────────┐       ┌───────────────┐  │              │    ┌────────────────┐                          │      │       │
│  │  │    │                │       │               │  │              │    │                │                          │      │       │
│  │  │    │ Public EC2     │       │ NAT Gateway   │  │              │    │ Private EC2    │                          │      │       │
│  │  │    │ Instance       │       │               │  │              │    │ Instance       │                          │      │       │
│  │  │    │                │       │               │  │              │    │                │                          │      │       │
│  │  │    └────────────────┘       └───────────────┘  │              │    └────────────────┘                          │      │       │
│  │  │                                 │              │              │                                                │      │       │
│  │  │                                 │              │              │                                                │      │       │
│  │  └─────────────────────────────────┼──────────────┘              └────────────────────────────────────────────────┘      │       │
│  │                                    │                                               ▲                                      │       │
│  │                                    │                                               │                                      │       │
│  │                                    ▼                                               │                                      │       │
│  │                           ┌─────────────────┐                           ┌──────────┴─────────┐                            │       │
│  │                           │ Internet        │                           │                    │                            │       │
│  │                           │ Gateway         │◄────────────────────────►│ Route Tables       │                            │       │
│  │                           │                 │                           │                    │                            │       │
│  │                           └─────────────────┘                           └────────────────────┘                            │       │
│  │                                    ▲                                                                                      │       │
│  └────────────────────────────────────┼──────────────────────────────────────────────────────────────────────────────────────┘       │
│                                        │                                                                                              │
│                                        │                                                                                              │
│                                        ▼                                                                                              │
│                                    Internet                                                                                           │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

## CI/CD Architecture with AWS CodePipeline

```
┌───────────────────────────────────────────┐      ┌───────────────────────────────────────────┐      ┌───────────────────────────────────────────┐
│                                           │      │                                           │      │                                           │
│                                           │      │                                           │      │                                           │
│               Source Stage                │─────►│               Build Stage                 │─────►│               Deploy Stage                │
│                                           │      │                                           │      │                                           │
│                                           │      │                                           │      │                                           │
└───────────────────────────────────────────┘      └───────────────────────────────────────────┘      └───────────────────────────────────────────┘
                   │                                                 │                                                 │
                   ▼                                                 ▼                                                 ▼
          ┌─────────────────┐                               ┌─────────────────┐                               ┌─────────────────┐
          │                 │                               │                 │                               │                 │
          │    GitHub       │                               │   AWS CodeBuild │                               │ CloudFormation  │
          │    Repository   │                               │                 │                               │                 │
          │                 │                               │  cfn-lint       │                               │                 │
          └─────────────────┘                               │  TaskCat        │                               └─────────────────┘
                                                            │                 │
                                                            └─────────────────┘
```

## CloudFormation Project Structure

```
cloudformation/
├── cloudformation.yaml  # Main CloudFormation template
├── pipeline.yaml        # CI/CD pipeline template
├── buildspec.yml        # CodeBuild configuration
├── parameters.json      # CloudFormation parameters
├── taskcat.yml          # TaskCat configuration
└── README.md            # Documentation
```

## CI/CD Integration

The project uses a complete CI/CD workflow:

1. CloudFormation code is stored on GitHub
2. AWS CodeBuild performs validation with cfn-lint and TaskCat
3. AWS CodePipeline automatically deploys the CloudFormation stack

## Deployment Steps

### 1. Deploy the Pipeline

First, deploy the pipeline to automate CloudFormation stack deployment:

```bash
aws cloudformation create-stack \
  --stack-name cloudformation-pipeline \
  --template-body file://cloudformation/pipeline.yaml \
  --parameters \
    ParameterKey=GitHubOwner,ParameterValue=YOUR_GITHUB_USERNAME \
    ParameterKey=GitHubRepo,ParameterValue=YOUR_REPO_NAME \
    ParameterKey=GitHubBranch,ParameterValue=main \
    ParameterKey=GitHubToken,ParameterValue=YOUR_GITHUB_TOKEN \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
```

### 2. Testing and Debugging

Use tools to validate the CloudFormation template:

```bash
# Install cfn-lint
pip install cfn-lint

# Check CloudFormation template
cfn-lint cloudformation/cloudformation.yaml

# Install TaskCat
pip install taskcat

# Run tests with TaskCat
cd cloudformation
taskcat test run
```

### 3. Monitor Deployment

After configuring the pipeline, any changes pushed to GitHub will trigger the CI/CD process. Check deployment status:

```bash
aws cloudformation describe-stacks --stack-name cloudformation-infrastructure
```

## Useful Commands

### Validate CloudFormation Template

```bash
aws cloudformation validate-template --template-body file://cloudformation/cloudformation.yaml
```

### View Stack Information

```bash
aws cloudformation describe-stacks --stack-name cloudformation-infrastructure
```

### Update Stack

```bash
aws cloudformation update-stack \
  --stack-name cloudformation-infrastructure \
  --template-body file://cloudformation/cloudformation.yaml \
  --parameters file://cloudformation/parameters.json \
  --capabilities CAPABILITY_IAM
```

### Delete Stack

```bash
aws cloudformation delete-stack --stack-name cloudformation-infrastructure
```

## Connecting to EC2 Instances

### Connect to Public EC2

```bash
ssh -i your-key.pem ec2-user@<public-ip>
```

### Connect to Private EC2 (via Public EC2)

First, copy your private key to the Public EC2:

```bash
scp -i your-key.pem your-key.pem ec2-user@<public-ip>:~/.ssh/
```

Then SSH into the Public EC2 and from there connect to the Private EC2:

```bash
ssh -i your-key.pem ec2-user@<public-ip>
chmod 400 ~/.ssh/your-key.pem
ssh -i ~/.ssh/your-key.pem ec2-user@<private-ip>
```
