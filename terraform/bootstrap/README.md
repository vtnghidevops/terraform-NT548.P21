# Terraform Backend Bootstrap

Thư mục này chứa cấu hình Terraform để tạo backend infrastructure (S3 bucket và DynamoDB table) trước khi chạy Terraform chính.

## Tại sao cần bootstrap?

Terraform cần S3 bucket và DynamoDB table để lưu trữ state và lock state, nhưng những tài nguyên này lại được định nghĩa trong cấu hình Terraform. Đây là vấn đề "chicken and egg". Giải pháp là tạo những tài nguyên này trước, trong một bước bootstrap riêng biệt.

## Cách sử dụng

Hãy thực hiện các bước sau trước khi chạy cấu hình Terraform chính:

```bash
# 1. Di chuyển vào thư mục bootstrap
cd bootstrap

# 2. Khởi tạo Terraform với local state
terraform init

# 3. Tạo backend infrastructure
terraform apply

# 4. Quay lại thư mục Terraform chính
cd ..

# 5. Bây giờ có thể khởi tạo Terraform chính với S3 backend
terraform init
```

## Cấu hình Pipeline

Trong pipeline CI/CD, hãy thực hiện các bước sau:

1. Chạy bootstrap Terraform trước:

   ```yaml
   - name: Setup Terraform Backend
     run: |
       cd terraform/bootstrap
       terraform init
       terraform apply -auto-approve
   ```

2. Sau đó mới chạy Terraform chính:
   ```yaml
   - name: Terraform Init
     run: |
       cd terraform
       terraform init
   ```

## Lưu ý quan trọng

- Chỉ cần chạy bootstrap một lần duy nhất. Sau khi S3 bucket và DynamoDB table đã được tạo, bạn không cần chạy lại bootstrap.
- Nếu bạn xóa S3 bucket hoặc DynamoDB table, bạn sẽ mất state của Terraform chính.
- Thư mục bootstrap sử dụng local state, không lưu trên S3.
