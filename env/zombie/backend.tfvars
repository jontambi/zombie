
terraform {
  backend "s3" {
# Replace this with your bucket name!
    bucket         = "zmbk8s"
    key            = "terraform/state"
    region         = "us-east-1"
    # Replace this with your DynamoDB table name!
    #dynamodb_table = "dev-terraform-up-and-running-locks"
    encrypt        = true
  }
}
