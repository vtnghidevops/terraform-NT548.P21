#!/bin/bash

# AWS Resource Testing Script after Terraform Deployment
# Run this script after terraform apply completes successfully

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== STARTING AWS RESOURCE VERIFICATION ===${NC}"

# Check terraform installation
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed${NC}"
    exit 1
fi

# Check AWS CLI installation
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed${NC}"
    exit 1
fi

# Get information from Terraform output
echo -e "\n${YELLOW}Retrieving information from Terraform output...${NC}"
if ! terraform output > /dev/null 2>&1; then
    echo -e "${RED}Error: Terraform state not found. Please run terraform apply first.${NC}"
    exit 1
fi

# Get resource IDs
echo -e "${YELLOW}Retrieving resource information...${NC}"
VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || echo "not_found")
PUBLIC_SUBNET_ID=$(terraform output -raw public_subnet_id 2>/dev/null || echo "not_found")
PRIVATE_SUBNET_ID=$(terraform output -raw private_subnet_id 2>/dev/null || echo "not_found")
PUBLIC_INSTANCE_ID=$(terraform output -raw public_instance_id 2>/dev/null || echo "not_found")
PRIVATE_INSTANCE_ID=$(terraform output -raw private_instance_id 2>/dev/null || echo "not_found")
PUBLIC_IP=$(terraform output -raw public_instance_public_ip 2>/dev/null || echo "not_found")

# Check VPC
echo -e "\n${YELLOW}=== CHECKING VPC ===${NC}"
if [ "$VPC_ID" != "not_found" ]; then
    if aws ec2 describe-vpcs --vpc-ids $VPC_ID > /dev/null 2>&1; then
        echo -e "${GREEN}✓ VPC exists: $VPC_ID${NC}"
        
        # Check VPC details
        VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids $VPC_ID --query 'Vpcs[0].CidrBlock' --output text)
        echo -e "${GREEN}  - VPC CIDR: $VPC_CIDR${NC}"
    else
        echo -e "${RED}✗ VPC does not exist: $VPC_ID${NC}"
    fi
else
    echo -e "${RED}✗ VPC ID not found in Terraform output${NC}"
fi

# Check Subnets
echo -e "\n${YELLOW}=== CHECKING SUBNETS ===${NC}"
if [ "$PUBLIC_SUBNET_ID" != "not_found" ]; then
    if aws ec2 describe-subnets --subnet-ids $PUBLIC_SUBNET_ID > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Public Subnet exists: $PUBLIC_SUBNET_ID${NC}"
        
        # Check Subnet details
        SUBNET_CIDR=$(aws ec2 describe-subnets --subnet-ids $PUBLIC_SUBNET_ID --query 'Subnets[0].CidrBlock' --output text)
        SUBNET_AZ=$(aws ec2 describe-subnets --subnet-ids $PUBLIC_SUBNET_ID --query 'Subnets[0].AvailabilityZone' --output text)
        echo -e "${GREEN}  - Public Subnet CIDR: $SUBNET_CIDR${NC}"
        echo -e "${GREEN}  - Public Subnet AZ: $SUBNET_AZ${NC}"
    else
        echo -e "${RED}✗ Public Subnet does not exist: $PUBLIC_SUBNET_ID${NC}"
    fi
else
    echo -e "${RED}✗ Public Subnet ID not found in Terraform output${NC}"
fi

if [ "$PRIVATE_SUBNET_ID" != "not_found" ]; then
    if aws ec2 describe-subnets --subnet-ids $PRIVATE_SUBNET_ID > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Private Subnet exists: $PRIVATE_SUBNET_ID${NC}"
        
        # Check Subnet details
        SUBNET_CIDR=$(aws ec2 describe-subnets --subnet-ids $PRIVATE_SUBNET_ID --query 'Subnets[0].CidrBlock' --output text)
        SUBNET_AZ=$(aws ec2 describe-subnets --subnet-ids $PRIVATE_SUBNET_ID --query 'Subnets[0].AvailabilityZone' --output text)
        echo -e "${GREEN}  - Private Subnet CIDR: $SUBNET_CIDR${NC}"
        echo -e "${GREEN}  - Private Subnet AZ: $SUBNET_AZ${NC}"
    else
        echo -e "${RED}✗ Private Subnet does not exist: $PRIVATE_SUBNET_ID${NC}"
    fi
else
    echo -e "${RED}✗ Private Subnet ID not found in Terraform output${NC}"
fi

# Check EC2 Instances
echo -e "\n${YELLOW}=== CHECKING EC2 INSTANCES ===${NC}"
if [ "$PUBLIC_INSTANCE_ID" != "not_found" ]; then
    if aws ec2 describe-instances --instance-ids $PUBLIC_INSTANCE_ID > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Public EC2 Instance exists: $PUBLIC_INSTANCE_ID${NC}"
        
        # Check instance status
        INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids $PUBLIC_INSTANCE_ID --query 'Reservations[0].Instances[0].State.Name' --output text)
        INSTANCE_TYPE=$(aws ec2 describe-instances --instance-ids $PUBLIC_INSTANCE_ID --query 'Reservations[0].Instances[0].InstanceType' --output text)
        INSTANCE_AZ=$(aws ec2 describe-instances --instance-ids $PUBLIC_INSTANCE_ID --query 'Reservations[0].Instances[0].Placement.AvailabilityZone' --output text)
        
        echo -e "${GREEN}  - Public EC2 State: $INSTANCE_STATE${NC}"
        echo -e "${GREEN}  - Public EC2 Type: $INSTANCE_TYPE${NC}"
        echo -e "${GREEN}  - Public EC2 AZ: $INSTANCE_AZ${NC}"
        
        if [ "$INSTANCE_STATE" == "running" ]; then
            echo -e "${GREEN}  - Public EC2 is running${NC}"
        else
            echo -e "${RED}  - Public EC2 is not in running state (current: $INSTANCE_STATE)${NC}"
        fi
    else
        echo -e "${RED}✗ Public EC2 Instance does not exist: $PUBLIC_INSTANCE_ID${NC}"
    fi
else
    echo -e "${RED}✗ Public EC2 Instance ID not found in Terraform output${NC}"
fi

if [ "$PRIVATE_INSTANCE_ID" != "not_found" ]; then
    if aws ec2 describe-instances --instance-ids $PRIVATE_INSTANCE_ID > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Private EC2 Instance exists: $PRIVATE_INSTANCE_ID${NC}"
        
        # Check instance status
        INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids $PRIVATE_INSTANCE_ID --query 'Reservations[0].Instances[0].State.Name' --output text)
        INSTANCE_TYPE=$(aws ec2 describe-instances --instance-ids $PRIVATE_INSTANCE_ID --query 'Reservations[0].Instances[0].InstanceType' --output text)
        INSTANCE_AZ=$(aws ec2 describe-instances --instance-ids $PRIVATE_INSTANCE_ID --query 'Reservations[0].Instances[0].Placement.AvailabilityZone' --output text)
        
        echo -e "${GREEN}  - Private EC2 State: $INSTANCE_STATE${NC}"
        echo -e "${GREEN}  - Private EC2 Type: $INSTANCE_TYPE${NC}"
        echo -e "${GREEN}  - Private EC2 AZ: $INSTANCE_AZ${NC}"
        
        if [ "$INSTANCE_STATE" == "running" ]; then
            echo -e "${GREEN}  - Private EC2 is running${NC}"
        else
            echo -e "${RED}  - Private EC2 is not in running state (current: $INSTANCE_STATE)${NC}"
        fi
    else
        echo -e "${RED}✗ Private EC2 Instance does not exist: $PRIVATE_INSTANCE_ID${NC}"
    fi
else
    echo -e "${RED}✗ Private EC2 Instance ID not found in Terraform output${NC}"
fi

# Check SSH connection to Public EC2
echo -e "\n${YELLOW}=== CHECKING SSH CONNECTION TO PUBLIC EC2 ===${NC}"
if [ "$PUBLIC_IP" != "not_found" ]; then
    echo -e "${GREEN}Public IP: $PUBLIC_IP${NC}"
    
    # Check if port 22 is open
    echo "Testing SSH connection (port 22)..."
    timeout 5 bash -c "</dev/tcp/$PUBLIC_IP/22" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ SSH port (22) is open and accessible${NC}"
        echo -e "${GREEN}  To connect via SSH: ssh -i your-key.pem ec2-user@$PUBLIC_IP${NC}"
    else
        echo -e "${RED}✗ Cannot connect to SSH port (22)${NC}"
        echo -e "${YELLOW}  Check if Security Group has opened port 22${NC}"
        echo -e "${YELLOW}  Check if key pair is correctly configured${NC}"
    fi
else
    echo -e "${RED}✗ Public IP not found in Terraform output${NC}"
fi

echo -e "\n${YELLOW}=== VERIFICATION COMPLETE ===${NC}"
echo -e "${GREEN}Summary:${NC}"
echo -e "VPC: ${VPC_ID}"
echo -e "Public Subnet: ${PUBLIC_SUBNET_ID}"
echo -e "Private Subnet: ${PRIVATE_SUBNET_ID}"
echo -e "Public EC2: ${PUBLIC_INSTANCE_ID}"
echo -e "Private EC2: ${PRIVATE_INSTANCE_ID}"
echo -e "Public IP: ${PUBLIC_IP}" 