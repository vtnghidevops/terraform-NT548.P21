#!/bin/bash

# Terraform test script to validate infrastructure

echo "===== TESTING TERRAFORM INFRASTRUCTURE ====="

echo "=== 1. Testing VPC Configuration (3 points) ==="
VPC_ID=$(terraform output -raw vpc_id)
echo "VPC ID: $VPC_ID"

VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids $VPC_ID --query "Vpcs[0].CidrBlock" --output text)
echo "VPC CIDR: $VPC_CIDR"

PUBLIC_SUBNET_ID=$(terraform output -raw public_subnet_id)
echo "Public Subnet ID: $PUBLIC_SUBNET_ID"

PUBLIC_SUBNET_INFO=$(aws ec2 describe-subnets --subnet-ids $PUBLIC_SUBNET_ID --query "Subnets[0].{CIDR:CidrBlock,Public:MapPublicIpOnLaunch,AZ:AvailabilityZone}" --output table)
echo -e "\nPublic Subnet Info:"
echo "$PUBLIC_SUBNET_INFO"

PRIVATE_SUBNET_ID=$(terraform output -raw private_subnet_id)
echo "Private Subnet ID: $PRIVATE_SUBNET_ID"

PRIVATE_SUBNET_INFO=$(aws ec2 describe-subnets --subnet-ids $PRIVATE_SUBNET_ID --query "Subnets[0].{CIDR:CidrBlock,Public:MapPublicIpOnLaunch,AZ:AvailabilityZone}" --output table)
echo -e "\nPrivate Subnet Info:"
echo "$PRIVATE_SUBNET_INFO"

echo -e "\n=== 2. Testing Route Tables (2 points) ==="
PUBLIC_RT_ID=$(terraform output -raw public_route_table_id)
echo "Public Route Table ID: $PUBLIC_RT_ID"

echo "Public Route Table Routes:"
aws ec2 describe-route-tables --route-table-ids $PUBLIC_RT_ID --query "RouteTables[0].Routes" --output table

echo "Public Route Table Associations:"
aws ec2 describe-route-tables --route-table-ids $PUBLIC_RT_ID --query "RouteTables[0].Associations" --output table

PRIVATE_RT_ID=$(terraform output -raw private_route_table_id)
echo "Private Route Table ID: $PRIVATE_RT_ID"

echo "Private Route Table Routes:"
aws ec2 describe-route-tables --route-table-ids $PRIVATE_RT_ID --query "RouteTables[0].Routes" --output table

echo "Private Route Table Associations:"
aws ec2 describe-route-tables --route-table-ids $PRIVATE_RT_ID --query "RouteTables[0].Associations" --output table

echo -e "\n=== 3. Testing NAT Gateway (1 point) ==="
NAT_ID=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query "NatGateways[0].NatGatewayId" --output text)
echo "NAT Gateway ID: $NAT_ID"

NAT_INFO=$(aws ec2 describe-nat-gateways --nat-gateway-ids $NAT_ID --query "NatGateways[0].{State:State,SubnetId:SubnetId,IP:NatGatewayAddresses[0].PublicIp}" --output table)
echo "NAT Gateway Info:"
echo "$NAT_INFO"

echo -e "\n=== 4. Testing EC2 Instances (2 points) ==="
PUBLIC_INSTANCE_ID=$(terraform output -raw public_instance_id)
echo "Public Instance ID: $PUBLIC_INSTANCE_ID"

PUBLIC_INSTANCE_INFO=$(aws ec2 describe-instances --instance-ids $PUBLIC_INSTANCE_ID --query "Reservations[0].Instances[0].{State:State.Name,Type:InstanceType,SubnetId:SubnetId,PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress}" --output table)
echo "Public Instance Info:"
echo "$PUBLIC_INSTANCE_INFO"

PRIVATE_INSTANCE_ID=$(terraform output -raw private_instance_id)
echo "Private Instance ID: $PRIVATE_INSTANCE_ID"

PRIVATE_INSTANCE_INFO=$(aws ec2 describe-instances --instance-ids $PRIVATE_INSTANCE_ID --query "Reservations[0].Instances[0].{State:State.Name,Type:InstanceType,SubnetId:SubnetId,PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress}" --output table)
echo "Private Instance Info:"
echo "$PRIVATE_INSTANCE_INFO"

echo -e "\n=== 5. Testing Security Groups (2 points) ==="
PUBLIC_SG_ID=$(terraform output -raw public_ec2_security_group_id)
echo "Public EC2 Security Group ID: $PUBLIC_SG_ID"

echo "Public Security Group Inbound Rules:"
aws ec2 describe-security-groups --group-ids $PUBLIC_SG_ID --query "SecurityGroups[0].IpPermissions" --output table

echo "Public Security Group Outbound Rules:"
aws ec2 describe-security-groups --group-ids $PUBLIC_SG_ID --query "SecurityGroups[0].IpPermissionsEgress" --output table

PRIVATE_SG_ID=$(terraform output -raw private_ec2_security_group_id)
echo "Private EC2 Security Group ID: $PRIVATE_SG_ID"

echo "Private Security Group Inbound Rules:"
aws ec2 describe-security-groups --group-ids $PRIVATE_SG_ID --query "SecurityGroups[0].IpPermissions" --output table

echo "Private Security Group Outbound Rules:"
aws ec2 describe-security-groups --group-ids $PRIVATE_SG_ID --query "SecurityGroups[0].IpPermissionsEgress" --output table

echo -e "\n=== 6. Connection Testing (Manual) ==="
PUBLIC_IP=$(terraform output -raw public_instance_public_ip)
PRIVATE_IP=$(aws ec2 describe-instances --instance-ids $PRIVATE_INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)

echo "To test SSH connection to public instance:"
echo "ssh -i tf-key.pem ec2-user@$PUBLIC_IP"

echo -e "\nTo test private instance connectivity:"
echo "1. Connect to public instance:"
echo "   ssh -i tf-key.pem ec2-user@$PUBLIC_IP"
echo "2. Transfer your key to public instance (from your local machine):"
echo "   scp -i tf-key.pem tf-key.pem ec2-user@$PUBLIC_IP:~/.ssh/"
echo "3. From public instance, connect to private instance:"
echo "   ssh -i ~/.ssh/tf-key.pem ec2-user@$PRIVATE_IP"
echo "4. Test internet connectivity from private instance:"
echo "   curl -m 5 http://checkip.amazonaws.com"

echo -e "\n===== TEST COMPLETE =====" 
