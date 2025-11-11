resource "aws_security_group" "lab_sg_ssh_anywhere" {
  name   = "allow_ssh_from_anywhere"
  vpc_id = aws_vpc.lab_vpc.id
  tags = {
    Name = "lab_sg_ssh_anywhere"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_anywhere" {
  security_group_id = aws_security_group.lab_sg_ssh_anywhere.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_eg_anywhere" {
  security_group_id = aws_security_group.lab_sg_ssh_anywhere.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# ================================================================

resource "aws_security_group" "lab_sg_ssh_3000_vpc" {
  name   = "allow_ssh_3000_from_lab_vpc"
  vpc_id = aws_vpc.lab_vpc.id
  tags = {
    Name = "lab_sg_ssh_3000_vpc"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_vpc" {
  security_group_id = aws_security_group.lab_sg_ssh_3000_vpc.id

  cidr_ipv4   = aws_vpc.lab_vpc.cidr_block
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_3000_vpc" {
  security_group_id = aws_security_group.lab_sg_ssh_3000_vpc.id

  cidr_ipv4   = aws_vpc.lab_vpc.cidr_block
  from_port   = 3000
  ip_protocol = "tcp"
  to_port     = 3000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_eg_vpc" {
  security_group_id = aws_security_group.lab_sg_ssh_3000_vpc.id

  cidr_ipv4   = "0.0.0.0/0" // destiation
  ip_protocol = "-1"
}