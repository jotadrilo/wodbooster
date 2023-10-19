resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    ProvisionedBy = var.provisioned_by
  }
}
