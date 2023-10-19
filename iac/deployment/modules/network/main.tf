resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block

  tags = {
    ProvisionedBy = var.provisioned_by
  }
}

output "vpc_id" {
  value = aws_vpc.this.id
}

resource "aws_subnet" "this" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.subnet_cidr_block

  tags = {
    ProvisionedBy = var.provisioned_by
  }
}

output "subnet_id" {
  value = aws_subnet.this.id
}

resource "aws_security_group" "this" {
  name_prefix = "${var.name_prefix}-"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    ProvisionedBy = var.provisioned_by
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "security_group_arn" {
  value = aws_security_group.this.arn
}

