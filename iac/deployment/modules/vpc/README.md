# s3-bucket

This Terraform module:

* Creates an AWS S3 bucket

## How to use

```terraform
module "some_bucket" {
  source = "./modules/s3-bucket/"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
  bucket_name    = "foo"
}
```
