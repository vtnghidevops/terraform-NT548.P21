# Deploying AWS Infrastructure with Terraform

This directory contains Terraform code to deploy AWS infrastructure including VPC, Subnets, EC2, and related components.

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

The deployed infrastructure includes:

- VPC with CIDR block 10.0.0.0/16
- Public and Private Subnets
- Internet Gateway for Public Subnet
- NAT Gateway for Private Subnet
- Route Tables for both subnets
- Security Groups for EC2 instances
- EC2 instances in both subnets

## Code Structure

```
terraform/
├── main.tf           # Main file, declaring provider and modules
├── variables.tf      # Variable definitions
├── outputs.tf        # Output declarations
├── terraform.tfvars  # Variable values
├── scripts/          # Testing scripts
│   ├── test_aws_resources.sh   # Resource testing script (Linux/macOS)
│   └── test_aws_resources.ps1  # Resource testing script (Windows)
└── modules/          # Modules
    ├── ec2/          # EC2 instances module
    ├── security/     # Security Groups module
    └── vpc/          # VPC and related components module
```

## Requirements

- Terraform v1.0+ installed
- AWS CLI installed and configured
- SSH key pair created in AWS (for EC2 connection)

## Usage

### 1. Configuration

Update the `terraform.tfvars` file with values appropriate for your environment:

```hcl
region             = "us-east-1"  # Change if needed
prefix             = "your-prefix"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
allowed_ip         = "YOUR_IP/32"  # Replace with your IP, or 0.0.0.0/0 to allow from anywhere
ami_id             = "ami-0e83be366243f524a"  # Change if needed
instance_type      = "t2.micro"
key_name           = "your-key-name"  # Replace with your key pair name
```

### 2. Initialization

```bash
terraform init
```

This command will download necessary providers and modules.

### 3. View deployment plan

```bash
terraform plan
```

Check what resources Terraform will create.

### 4. Deployment

```bash
terraform apply
```

Confirm deployment by typing `yes` when prompted.

### 5. Check output

```bash
terraform output
```

This command will display information like the public IP address of your EC2 instance.

### 6. Verify deployed AWS resources

Use the AWS resource testing script provided in the repository:

**Linux/macOS:**

```bash
chmod +x scripts/test_aws_resources.sh
./scripts/test_aws_resources.sh
```

**Windows:**

```powershell
.\scripts\test_aws_resources.ps1
```

The script will check all deployed AWS resources:

- Check VPC and CIDR information
- Check Public and Private Subnets
- Check EC2 instances and running status
- Check SSH connectivity to Public EC2

Test results will be displayed as passed (green) or failed (red) items.

## Automated Deployment with GitHub Actions

This project includes a CI/CD workflow using GitHub Actions to automate deployment.

### GitHub Actions Configuration

1. Fork or clone this repository to your GitHub
2. Add the following secrets to your GitHub repository:
   - `AWS_ACCESS_KEY_ID`: AWS access key
   - `AWS_SECRET_ACCESS_KEY`: AWS secret key

### CI/CD Workflow

The GitHub Actions workflow includes:

1. Checking Terraform code formatting
2. Validating Terraform configuration
3. Security scanning with Checkov
4. Automated deployment when pushing to the main branch

### Viewing logs and results

Access the "Actions" tab in your GitHub repository to view logs and results of the CI/CD workflow.

## Security Testing

To check compliance and security before deployment:

```bash
checkov -d .
```

## Connecting to EC2 instances

### Connecting to Public EC2

```bash
ssh -i your-key.pem ec2-user@<public-ip>
```

### Connecting to Private EC2 (via Public EC2)

First, copy your private key to Public EC2:

```bash
scp -i your-key.pem your-key.pem ec2-user@<public-ip>:~/.ssh/
```

Then SSH into Public EC2 and from there connect to Private EC2:

```bash
ssh -i your-key.pem ec2-user@<public-ip>
chmod 400 ~/.ssh/your-key.pem
ssh -i ~/.ssh/your-key.pem ec2-user@<private-ip>
```

## Cleaning Up Resources

To remove all created resources:

```bash
terraform destroy
```

Confirm by typing `yes` when prompted.
