# network

This Terraform module:

* Creates a VPC
* Creates a subnet
* Creates a security group

## How to use

```terraform
module "name" {
  source = "./modules/network/"

  # The smallest CIDR range is /28 (see https://aws.amazon.com/vpc/faqs/)
  #
  # To create a network with the smallest number of IPs we can:
  # * Create a VPC with CIDR range /26 to support up to 64 IPs in the range of 10.0.0.0 - 10.0.0.63
  # * Create a subnet with CIDR range /28 to support up to 11 (see note) IPs in the following ranges:
  #    10.0.0.0/28   (10.0.0.0  - 10.0.0.15)
  #    10.0.0.16/28  (10.0.0.16 - 10.0.0.31)
  #    10.0.0.32/28  (10.0.0.32 - 10.0.0.47)
  #    10.0.0.48/28  (10.0.0.48 - 10.0.0.63)
  #
  # NOTE: AWS reserves 5 IPs for the VPC internal use
  vpc_cidr_block = "10.0.0.0/26"
  subnet_cidr_block = "10.0.0.0/28"
}
```
