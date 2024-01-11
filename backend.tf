# You need to configure your S3 bucket if your decide to keep your terraform states in the S3 bucket. Otherwise, disable the block for states will be located locally and be careful!

terraform {
  backend "s3" {
    bucket         = "ercan-tf-state"  # Replace with your S3 bucket name
    key            = "aws-ASG-PoC/terraform.tfstate"  # Replace with your state file path
    region         = "eu-central-1"  # Replace with your S3 bucket region
    # dynamodb_table = "my-lock-table"  # Replace with your DynamoDB table name for state locking -optional but recommended-
    encrypt        = true
  }
}

# You can use the config below to create resources with another terraform project
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "my-terraform-state-bucket"
#   acl    = "private"
# 
#   versioning {
#     enabled = true
#   }
# }
# 
# resource "aws_dynamodb_table" "terraform_locks" {
#   name           = "my-lock-table"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"
# 
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }
# 
