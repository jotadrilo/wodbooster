module "wb_bucket" {
  source = "./modules/s3-bucket/"

  bucket_name = "wodbooster-screenshots"
}

module "wb_network" {
  source = "./modules/network/"

  name_prefix       = "wodbooster"
  vpc_cidr_block    = "10.0.0.0/26"
  subnet_cidr_block = "10.0.0.0/28"
  assign_public_ip  = true
}

resource "aws_key_pair" "wb_kp" {
  key_name   = "wodbooster-kp"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAZA37Aw69xBtR06z4BT6nEx8XL+yklmFwmELPKS0l9JcwFh6JE2vbMKbw81Aum521eiqNi+4R1aJy+7oSFHmrXLDdO6I7DKXOzyO/cTK4ECBAgFPAvkOqunCM71+rDvyuOfoiKZy7bYcsqsuBRSiT7InIIlY0gi0f5jzP7yRuO4xiFogjVgJdXT08Iw72HzRRa5RBmU24sOSeLCb67A5tGXiIJ9RsFULl1Ekl9+uEET+GTZR7X27RvTNcbYctii9tstyPQbKYwRAInoOGFS8Q92nysw5De18cTfPCcM1UP5oogTGDkzzhjG8l9IzS+UZ5PcBSnxTBhUPl/bRhvnw/"
}

resource "aws_instance" "wb_ec2" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [module.wb_network.security_group_id]
  subnet_id              = module.wb_network.subnet_id
  key_name               = aws_key_pair.wb_kp.key_name

  tags = {
    ProvisionedBy = var.provisioned_by
  }
}
