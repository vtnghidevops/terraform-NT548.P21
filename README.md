# AWS Infrastructure with Terraform and CloudFormation

This project implements an AWS infrastructure using both Terraform and CloudFormation to showcase Infrastructure as Code (IaC) approaches. The architecture includes VPC, subnets, route tables, NAT Gateway, EC2 instances, and security groups.

## Architecture Overview

![Infrastructure Architecture](architecture-diagram.png)

The infrastructure consists of:

1. **VPC:**
   - VPC with CIDR block 10.0.0.0/16
   - Public Subnet (10.0.1.0/24) in us-east-1a
   - Private Subnet (10.0.2.0/24) in us-east-1b
   - Internet Gateway for public internet access
   - Default Security Group for the VPC

2. **Route Tables:**
   - Public Route Table: Routes internet traffic (0.0.0.0/0) through Internet Gateway
   - Private Route Table: Routes internet traffic (0.0.0.0/0) through NAT Gateway

3. **NAT Gateway:**
   - Located in the Public Subnet
   - Allows Private Subnet resources to access internet while maintaining security

4. **EC2 Instances:**
   - Public EC2 Instance in Public Subnet with public IP
   - Private EC2 Instance in Private Subnet (no public IP)
   - Both use Amazon Linux 2023 AMI on t2.micro instances

5. **Security Groups:**
   - Public EC2 Security Group: Allows SSH (port 22) from specific IP
   - Private EC2 Security Group: Allows connections only from Public EC2 instance

## Getting Started

### Clone Repository

Start by cloning the repository to your local machine:

```bash
git clone https://github.com/vtnghidevops/terraform-NT548.P21.git
cd terraform-NT548.P21
```

### Project Organization

The project is organized into two main implementation methods:
- **Terraform**: Files in the root directory
- **CloudFormation**: Files in the `cloudformation` directory

## Prerequisites

1. **AWS Account and CLI**
   - AWS account with appropriate permissions
   - AWS CLI installed and configured
   ```bash
   aws configure
   ```

2. **Terraform Installation**
   - Download and install from [terraform.io](https://www.terraform.io/downloads.html)
   - Verify installation:
   ```bash
   terraform --version
   ```

3. **SSH Key Pair**
   - Create a key pair for SSH access:
   ```bash
   aws ec2 create-key-pair --key-name tf-key --query 'KeyMaterial' --output text > tf-key.pem
   chmod 400 tf-key.pem
   ```

4. **AMI ID Configuration**
   - The default AMI ID (ami-0e83be366243f524a) is for Amazon Linux 2023 in us-east-1 region
   - If you're deploying in a different region, you must update the AMI ID
   - Find the correct AMI ID for your region:
   ```bash
   aws ec2 describe-images --owners amazon --filters "Name=name,Values=al2023-ami-2023*" --query "Images[*].[ImageId,Name]" --output table --region YOUR_REGION
   ```
   - Update the AMI ID in terraform.tfvars:
   ```
   ami_id = "ami-YOUR_CORRECT_AMI_ID"
   ```

## Deployment Instructions

### Terraform Deployment

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Update Variables:**
   Edit `terraform.tfvars` to set your desired values, especially:
   ```
   key_name = "your_key"
   allowed_ip = "YOUR_IP_ADDRESS/32"  # Your public IP for SSH access
   ```

3. **Preview Changes:**
   ```bash
   terraform plan
   ```

4. **Deploy Infrastructure:**
   ```bash
   terraform apply
   ```
   Confirm with `yes` when prompted.

5. **Access Resources:**
   After deployment, you can find the necessary information:
   ```bash
   terraform output
   ```

### CloudFormation Deployment

1. **Deploy Stack:**
   ```bash
   aws cloudformation create-stack \
     --stack-name cloudformation-lab1 \
     --template-body file://cloudformation.yaml \
     --parameters ParameterKey=KeyName,ParameterValue=tf-key \
                 ParameterKey=AllowedIP,ParameterValue=YOUR_IP_ADDRESS/32
   ```

2. **Monitor Stack Creation:**
   ```bash
   aws cloudformation describe-stacks --stack-name cloudformation-lab1
   ```

3. **Get Resource Information:**
   ```bash
   aws cloudformation describe-stack-resources --stack-name cloudformation-lab1
   ```

### Testing

1. **Access Public Instance:**
   ```bash
   ssh -i tf-key.pem ec2-user@<PUBLIC_IP>
   ```

2. **Test Public to Private Instance Access:**
   ```bash
   # From your local machine
   scp -i tf-key.pem tf-key.pem ec2-user@<PUBLIC_IP>:~/.ssh/
   
   # Then SSH to public instance
   ssh -i tf-key.pem ec2-user@<PUBLIC_IP>
   
   # From public instance, connect to private instance
   ssh -i ~/.ssh/tf-key.pem ec2-user@<PRIVATE_IP>
   ```

3. **Test Internet Connectivity from Private Instance:**
   After connecting to the private instance:
   ```bash
   curl http://checkip.amazonaws.com
   ```

### Terraform Clean Up
```bash
terraform destroy
```

### CloudFormation Clean Up
```bash
aws cloudformation delete-stack --stack-name cloudformation-lab1
```


