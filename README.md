# AWS Infrastructure as Code with Terraform and CloudFormation

This project deploys AWS infrastructure using two Infrastructure as Code (IaC) approaches:

1. **Terraform**: Deploy AWS VPC, EC2, and related components
2. **CloudFormation**: Deploy the same infrastructure with automated CI/CD pipeline

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

## Project Structure

```
.
├── terraform/              # Terraform source code
│   ├── main.tf             # Main file
│   ├── variables.tf        # Variable definitions
│   ├── outputs.tf          # Output definitions
│   ├── terraform.tfvars    # Variable values
│   ├── scripts/            # Testing scripts
│   │   ├── test_aws_resources.sh   # Resource testing script (Linux/macOS)
│   │   └── test_aws_resources.ps1  # Resource testing script (Windows)
│   └── modules/            # Terraform modules
│       ├── ec2/            # EC2 module
│       ├── security/       # Security Groups module
│       └── vpc/            # VPC module
├── cloudformation/         # CloudFormation source code
│   ├── cloudformation.yaml # CloudFormation template
│   ├── pipeline.yaml       # CodePipeline configuration
│   ├── buildspec.yml       # AWS CodeBuild configuration
│   ├── parameters.json     # CloudFormation parameters
│   ├── taskcat.yml         # TaskCat configuration
│   └── README.md           # CloudFormation guide
└── .github/                # GitHub CI/CD
    └── workflows/
        └── terraform.yml   # GitHub Actions workflow
```

## Architecture Overview

The infrastructure includes:

- VPC with public and private subnets
- Internet Gateway and NAT Gateway for internet connectivity
- Route Tables for both subnets
- Security Groups for EC2 instances
- EC2 instances in both public and private subnets

## Environment Requirements

- AWS account with permissions to deploy infrastructure
- AWS CLI installed and configured
- Terraform CLI (version 1.0+)
- Git
- GitHub account (for CI/CD)

## Environment Setup Guide

### 1. Install AWS CLI

**Windows:**

```
curl "https://awscli.amazonaws.com/AWSCLIV2.msi" -o "AWSCLIV2.msi"
msiexec /i AWSCLIV2.msi
```

**macOS:**

```
brew install awscli
```

**Linux:**

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Configure AWS CLI:

```
aws configure
```

### 2. Install Terraform

**Windows:** Download and install from [terraform.io](https://www.terraform.io/downloads.html)

**macOS:**

```
brew install terraform
```

**Linux:**

```
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### 3. Install Testing and Validation Tools

**cfn-lint and TaskCat (for CloudFormation):**

```
pip install cfn-lint taskcat
```

**Checkov (for Terraform):**

```
pip install checkov
```

## Deploying with Terraform

See details in [terraform/README.md](./terraform/README.md)

## Deploying with CloudFormation

See details in [cloudformation/README.md](./cloudformation/README.md)

## Verifying Deployment Results

### Terraform

After deployment, check:

```
terraform output
```

Use the AWS resource testing script:

**Linux/macOS:**

```bash
cd terraform
chmod +x scripts/test_aws_resources.sh
./scripts/test_aws_resources.sh
```

**Windows:**

```powershell
cd terraform
.\scripts\test_aws_resources.ps1
```

The script will check all deployed AWS resources:

- VPC and Subnets
- EC2 instances and their status
- SSH connectivity to public EC2

Connect to public EC2 via SSH:

```
ssh -i your-key.pem ec2-user@<public-ip>
```

### CloudFormation

Check stack information:

```
aws cloudformation describe-stacks --stack-name cloudformation-infrastructure
```

Check CodePipeline status:

```
aws codepipeline get-pipeline-state --name <pipeline-name>
```

## Cleaning Up Resources

### Terraform

```
terraform destroy
```

### CloudFormation

```
aws cloudformation delete-stack --stack-name cloudformation-infrastructure
aws cloudformation delete-stack --stack-name cloudformation-pipeline
```
