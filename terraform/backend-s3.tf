# Backend S3 and DynamoDB can be pre-provisioned manually; here we keep local state by default
# Uncomment and adjust if you already have S3 bucket for remote state
# terraform {
#   backend "s3" {
#     bucket         = "<your-unique-tf-state-bucket>"
#     key            = "interview/terraform.tfstate"
#     region         = "eu-central-1"
#     dynamodb_table = "tf-locks"
#     encrypt        = true
#   }
# }


