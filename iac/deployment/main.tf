module "wb_bucket" {
  source = "./modules/s3-bucket/"

  bucket_name    = "wodbooster-screenshots"
}

module "wb_network" {
  source = "./modules/network/"

  name_prefix = "wodbooster"
  vpc_cidr_block = "10.0.0.0/26"
  subnet_cidr_block = "10.0.0.0/28"
}

resource "aws_instance" "wb_ec2" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
#  vpc_security_group_ids = [aws_security_group.wb_sg.id]
  security_groups        = [module.wb_network.security_group_id]
  subnet_id              = module.wb_network.subnet_id

  tags = {
    ProvisionedBy = var.provisioned_by
  }
}
