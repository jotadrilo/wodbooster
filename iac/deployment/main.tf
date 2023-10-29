module "wb_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "wodbooster-screenshots"

  force_destroy = true

  tags = {
    ProvisionedBy = var.provisioned_by
  }
}

module "wb_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "wodbooster-vpc"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cidr            = "10.0.0.0/25"
  // 10.0.0.0/25 => 10.0.0.0 to 10.0.0.127
  //
  // We can split this range to create 6 subnets:
  // 10.0.0.0/28  => 10.0.0.0  - 10.0.0.15
  // 10.0.0.16/28 => 10.0.0.16 - 10.0.0.31
  // 10.0.0.32/28 => 10.0.0.32 - 10.0.0.47
  // 10.0.0.48/28 => 10.0.0.48 - 10.0.0.63
  // 10.0.0.64/28 => 10.0.0.64 - 10.0.0.79
  // 10.0.0.80/28 => 10.0.0.80 - 10.0.0.95
  private_subnets = ["10.0.0.0/28", "10.0.0.16/28", "10.0.0.32/28"]
  public_subnets  = ["10.0.0.48/28", "10.0.0.64/28", "10.0.0.80/28"]

  enable_nat_gateway      = true
  enable_vpn_gateway      = true
  map_public_ip_on_launch = true

  default_security_group_ingress = [
    {
      "rule_action": "allow",
      "protocol": "tcp",
      "from_port": 22,
      "to_port": 22
      "cidr_blocks": "0.0.0.0/0",
    },
  ]

  default_security_group_egress = [
    {
      "rule_action": "allow",
      "protocol": "tcp",
      "from_port": 443,
      "to_port": 443
      "cidr_blocks": "0.0.0.0/0",
    },
    {
      "rule_action": "allow",
      "protocol": "tcp",
      "from_port": 80,
      "to_port": 80
      "cidr_blocks": "0.0.0.0/0",
    },
  ]

  tags = {
    ProvisionedBy = var.provisioned_by
  }
}

resource "aws_key_pair" "wb_kp" {
  key_name   = "wodbooster-kp"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAZA37Aw69xBtR06z4BT6nEx8XL+yklmFwmELPKS0l9JcwFh6JE2vbMKbw81Aum521eiqNi+4R1aJy+7oSFHmrXLDdO6I7DKXOzyO/cTK4ECBAgFPAvkOqunCM71+rDvyuOfoiKZy7bYcsqsuBRSiT7InIIlY0gi0f5jzP7yRuO4xiFogjVgJdXT08Iw72HzRRa5RBmU24sOSeLCb67A5tGXiIJ9RsFULl1Ekl9+uEET+GTZR7X27RvTNcbYctii9tstyPQbKYwRAInoOGFS8Q92nysw5De18cTfPCcM1UP5oogTGDkzzhjG8l9IzS+UZ5PcBSnxTBhUPl/bRhvnw/"
}

resource "random_shuffle" "subnets" {
  input        = module.wb_vpc.public_subnets
  result_count = 1
}

resource "aws_instance" "wb_ec2" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [module.wb_vpc.default_security_group_id]
  subnet_id              = random_shuffle.subnets.result[0]
  key_name               = aws_key_pair.wb_kp.key_name

  tags = {
    ProvisionedBy = var.provisioned_by
  }
}
