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
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = var.assign_public_ip

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

  #  ingress {
  #    description = "TLS from VPC"
  #    from_port   = 443
  #    to_port     = 443
  #    protocol    = "tcp"
  #    cidr_blocks = [aws_vpc.this.cidr_block]
  #  }

  tags = {
    ProvisionedBy = var.provisioned_by
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "inbound_allow_ssh" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "outbound_allow_http" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "outbound_allow_https" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "security_group_arn" {
  value = aws_security_group.this.arn
}

