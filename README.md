# VTNghi DevOps Portfolio

<div align="center">
  <img src="https://github-readme-stats.vercel.app/api?username=vtnghidevops&show_icons=true&theme=radical" alt="VTNghi's GitHub Stats" />
</div>

## 📚 About This Repository

This repository contains infrastructure as code (IaC) for AWS cloud resources using Terraform. The project implements secure infrastructure deployment following best practices and security standards.

### 🔑 Key Features

- ✅ Secure Terraform state management with S3 and DynamoDB
- ✅ AWS resources with security best practices
- ✅ CI/CD pipeline for infrastructure deployment
- ✅ Modular and reusable Terraform code

## 🛠️ Infrastructure Components

### Bootstrap Module

The bootstrap module creates the foundation for Terraform state management:

- S3 bucket with encryption, versioning, and replication
- DynamoDB table with encryption for state locking
- KMS keys for encryption

### Main Infrastructure

- EC2 instances with security configurations
- VPC with proper network segmentation
- Security groups with least privilege access
- Database resources with encryption and backups

## 🚀 Getting Started

1. Clone this repository
2. Set up AWS credentials
3. Run bootstrap module first:
   ```bash
   cd terraform/bootstrap
   terraform init
   terraform apply
   ```
4. Deploy main infrastructure:
   ```bash
   cd ..
   terraform init
   terraform apply
   ```

## 🔒 Security Features

This infrastructure implements security best practices:

- KMS encryption for sensitive data
- Point-in-time recovery for databases
- Cross-region replication for disaster recovery
- Lifecycle policies for data management
- Access logging and monitoring
- No public access to sensitive resources

## 📊 Project Status

<div align="center">
  <img src="https://github-readme-stats.vercel.app/api/top-langs/?username=vtnghidevops&layout=compact&theme=radical" alt="Top Languages" />
</div>

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Connect with Me

<div align="center">
  <a href="https://github.com/vtnghidevops">
    <img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white" alt="GitHub" />
  </a>
  <a href="https://linkedin.com/in/vtnghidevops">
    <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn" />
  </a>
</div>
