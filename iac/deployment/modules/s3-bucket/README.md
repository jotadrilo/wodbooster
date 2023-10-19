# s3-bucket

This Terraform module:

* Creates an AWS S3 bucket

## How to use

```terraform
module "name" {
  source = "./modules/s3-bucket/"

  bucket_name    = "foo"
}
```
