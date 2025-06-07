# PowerShell script for testing AWS resources after Terraform deployment
# Run this script after terraform apply completes successfully

# Colors for output
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$White = "White"

Write-Host "=== STARTING AWS RESOURCE VERIFICATION ===" -ForegroundColor $Yellow

# Check terraform installation
try {
    terraform --version | Out-Null
} catch {
    Write-Host "Error: Terraform is not installed" -ForegroundColor $Red
    exit 1
}

# Check AWS CLI installation
try {
    aws --version | Out-Null
} catch {
    Write-Host "Error: AWS CLI is not installed" -ForegroundColor $Red
    exit 1
}

# Get information from Terraform output
Write-Host "`nRetrieving information from Terraform output..." -ForegroundColor $Yellow
try {
    terraform output | Out-Null
} catch {
    Write-Host "Error: Terraform state not found. Please run terraform apply first." -ForegroundColor $Red
    exit 1
}

# Get resource IDs
Write-Host "Retrieving resource information..." -ForegroundColor $Yellow
try {
    $VPC_ID = terraform output -raw vpc_id
} catch {
    $VPC_ID = "not_found"
}

try {
    $PUBLIC_SUBNET_ID = terraform output -raw public_subnet_id
} catch {
    $PUBLIC_SUBNET_ID = "not_found"
}

try {
    $PRIVATE_SUBNET_ID = terraform output -raw private_subnet_id
} catch {
    $PRIVATE_SUBNET_ID = "not_found"
}

try {
    $PUBLIC_INSTANCE_ID = terraform output -raw public_instance_id
} catch {
    $PUBLIC_INSTANCE_ID = "not_found"
}

try {
    $PRIVATE_INSTANCE_ID = terraform output -raw private_instance_id
} catch {
    $PRIVATE_INSTANCE_ID = "not_found"
}

try {
    $PUBLIC_IP = terraform output -raw public_instance_public_ip
} catch {
    $PUBLIC_IP = "not_found"
}

# Check VPC
Write-Host "`n=== CHECKING VPC ===" -ForegroundColor $Yellow
if ($VPC_ID -ne "not_found") {
    try {
        $vpc = aws ec2 describe-vpcs --vpc-ids $VPC_ID | ConvertFrom-Json
        Write-Host "✓ VPC exists: $VPC_ID" -ForegroundColor $Green
        
        # Check VPC details
        $VPC_CIDR = $vpc.Vpcs[0].CidrBlock
        Write-Host "  - VPC CIDR: $VPC_CIDR" -ForegroundColor $Green
    } catch {
        Write-Host "✗ VPC does not exist: $VPC_ID" -ForegroundColor $Red
    }
} else {
    Write-Host "✗ VPC ID not found in Terraform output" -ForegroundColor $Red
}

# Check Subnets
Write-Host "`n=== CHECKING SUBNETS ===" -ForegroundColor $Yellow
if ($PUBLIC_SUBNET_ID -ne "not_found") {
    try {
        $subnet = aws ec2 describe-subnets --subnet-ids $PUBLIC_SUBNET_ID | ConvertFrom-Json
        Write-Host "✓ Public Subnet exists: $PUBLIC_SUBNET_ID" -ForegroundColor $Green
        
        # Check Subnet details
        $SUBNET_CIDR = $subnet.Subnets[0].CidrBlock
        $SUBNET_AZ = $subnet.Subnets[0].AvailabilityZone
        Write-Host "  - Public Subnet CIDR: $SUBNET_CIDR" -ForegroundColor $Green
        Write-Host "  - Public Subnet AZ: $SUBNET_AZ" -ForegroundColor $Green
    } catch {
        Write-Host "✗ Public Subnet does not exist: $PUBLIC_SUBNET_ID" -ForegroundColor $Red
    }
} else {
    Write-Host "✗ Public Subnet ID not found in Terraform output" -ForegroundColor $Red
}

if ($PRIVATE_SUBNET_ID -ne "not_found") {
    try {
        $subnet = aws ec2 describe-subnets --subnet-ids $PRIVATE_SUBNET_ID | ConvertFrom-Json
        Write-Host "✓ Private Subnet exists: $PRIVATE_SUBNET_ID" -ForegroundColor $Green
        
        # Check Subnet details
        $SUBNET_CIDR = $subnet.Subnets[0].CidrBlock
        $SUBNET_AZ = $subnet.Subnets[0].AvailabilityZone
        Write-Host "  - Private Subnet CIDR: $SUBNET_CIDR" -ForegroundColor $Green
        Write-Host "  - Private Subnet AZ: $SUBNET_AZ" -ForegroundColor $Green
    } catch {
        Write-Host "✗ Private Subnet does not exist: $PRIVATE_SUBNET_ID" -ForegroundColor $Red
    }
} else {
    Write-Host "✗ Private Subnet ID not found in Terraform output" -ForegroundColor $Red
}

# Check EC2 Instances
Write-Host "`n=== CHECKING EC2 INSTANCES ===" -ForegroundColor $Yellow
if ($PUBLIC_INSTANCE_ID -ne "not_found") {
    try {
        $instance = aws ec2 describe-instances --instance-ids $PUBLIC_INSTANCE_ID | ConvertFrom-Json
        Write-Host "✓ Public EC2 Instance exists: $PUBLIC_INSTANCE_ID" -ForegroundColor $Green
        
        # Check instance status
        $INSTANCE_STATE = $instance.Reservations[0].Instances[0].State.Name
        $INSTANCE_TYPE = $instance.Reservations[0].Instances[0].InstanceType
        $INSTANCE_AZ = $instance.Reservations[0].Instances[0].Placement.AvailabilityZone
        
        Write-Host "  - Public EC2 State: $INSTANCE_STATE" -ForegroundColor $Green
        Write-Host "  - Public EC2 Type: $INSTANCE_TYPE" -ForegroundColor $Green
        Write-Host "  - Public EC2 AZ: $INSTANCE_AZ" -ForegroundColor $Green
        
        if ($INSTANCE_STATE -eq "running") {
            Write-Host "  - Public EC2 is running" -ForegroundColor $Green
        } else {
            Write-Host "  - Public EC2 is not in running state (current: $INSTANCE_STATE)" -ForegroundColor $Red
        }
    } catch {
        Write-Host "✗ Public EC2 Instance does not exist: $PUBLIC_INSTANCE_ID" -ForegroundColor $Red
    }
} else {
    Write-Host "✗ Public EC2 Instance ID not found in Terraform output" -ForegroundColor $Red
}

if ($PRIVATE_INSTANCE_ID -ne "not_found") {
    try {
        $instance = aws ec2 describe-instances --instance-ids $PRIVATE_INSTANCE_ID | ConvertFrom-Json
        Write-Host "✓ Private EC2 Instance exists: $PRIVATE_INSTANCE_ID" -ForegroundColor $Green
        
        # Check instance status
        $INSTANCE_STATE = $instance.Reservations[0].Instances[0].State.Name
        $INSTANCE_TYPE = $instance.Reservations[0].Instances[0].InstanceType
        $INSTANCE_AZ = $instance.Reservations[0].Instances[0].Placement.AvailabilityZone
        
        Write-Host "  - Private EC2 State: $INSTANCE_STATE" -ForegroundColor $Green
        Write-Host "  - Private EC2 Type: $INSTANCE_TYPE" -ForegroundColor $Green
        Write-Host "  - Private EC2 AZ: $INSTANCE_AZ" -ForegroundColor $Green
        
        if ($INSTANCE_STATE -eq "running") {
            Write-Host "  - Private EC2 is running" -ForegroundColor $Green
        } else {
            Write-Host "  - Private EC2 is not in running state (current: $INSTANCE_STATE)" -ForegroundColor $Red
        }
    } catch {
        Write-Host "✗ Private EC2 Instance does not exist: $PRIVATE_INSTANCE_ID" -ForegroundColor $Red
    }
} else {
    Write-Host "✗ Private EC2 Instance ID not found in Terraform output" -ForegroundColor $Red
}

# Check SSH connection to Public EC2
Write-Host "`n=== CHECKING SSH CONNECTION TO PUBLIC EC2 ===" -ForegroundColor $Yellow
if ($PUBLIC_IP -ne "not_found") {
    Write-Host "Public IP: $PUBLIC_IP" -ForegroundColor $Green
    
    # Check if port 22 is open
    Write-Host "Testing SSH connection (port 22)..."
    $testConnection = Test-NetConnection -ComputerName $PUBLIC_IP -Port 22 -InformationLevel Quiet -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    
    if ($testConnection) {
        Write-Host "✓ SSH port (22) is open and accessible" -ForegroundColor $Green
        Write-Host "  To connect via SSH: ssh -i your-key.pem ec2-user@$PUBLIC_IP" -ForegroundColor $Green
    } else {
        Write-Host "✗ Cannot connect to SSH port (22)" -ForegroundColor $Red
        Write-Host "  Check if Security Group has opened port 22" -ForegroundColor $Yellow
        Write-Host "  Check if key pair is correctly configured" -ForegroundColor $Yellow
    }
} else {
    Write-Host "✗ Public IP not found in Terraform output" -ForegroundColor $Red
}

Write-Host "`n=== VERIFICATION COMPLETE ===" -ForegroundColor $Yellow
Write-Host "Summary:" -ForegroundColor $Green
Write-Host "VPC: $VPC_ID"
Write-Host "Public Subnet: $PUBLIC_SUBNET_ID"
Write-Host "Private Subnet: $PRIVATE_SUBNET_ID"
Write-Host "Public EC2: $PUBLIC_INSTANCE_ID"
Write-Host "Private EC2: $PRIVATE_INSTANCE_ID"
Write-Host "Public IP: $PUBLIC_IP" 