resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "lab_vpc"
  }
}

resource "aws_subnet" "lab_public_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "lab_public_subnet"
  }
}

resource "aws_subnet" "lab_private_subnet" {
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "lab_private_subnet"
  }
}

resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "lab_igw"
  }
}

resource "aws_route_table" "lab_public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }

  tags = {
    Name = "lab_public_rt"
  }
}

resource "aws_route_table" "lab_private_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = aws_vpc.lab_vpc.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.lab_nat_gw.id
  }

  tags = {
    Name = "lab_private_rt"
  }
}

resource "aws_route_table_association" "lab_public_rt_ac" {
  subnet_id      = aws_subnet.lab_public_subnet.id
  route_table_id = aws_route_table.lab_public_rt.id
}

resource "aws_route_table_association" "lab_private_rt_ac" {
  subnet_id      = aws_subnet.lab_private_subnet.id
  route_table_id = aws_route_table.lab_private_rt.id
}

resource "aws_eip" "lab_nat_eip" {
  domain = "vpc"
  tags = {
    Name = "lab_nat_eip"
  }
}

resource "aws_nat_gateway" "lab_nat_gw" {
  allocation_id = aws_eip.lab_nat_eip.id
  subnet_id     = aws_subnet.lab_public_subnet.id
  tags = {
    Name = "lab_nat_gw"
  }
}