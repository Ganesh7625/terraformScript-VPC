terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.69.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}

resource "aws_vpc" "DemoVPC" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Terraform-VPC"
  }
}

resource "aws_internet_gateway" "terraform-igw" {
  vpc_id = "${aws_vpc.DemoVPC.id}"

  tags = {
    Name = "terrsform-igw"
  }
}

resource "aws_subnet" "publicSubnet" {
  vpc_id = "${aws_vpc.DemoVPC.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "privateSubnet" {
  vpc_id = "${aws_vpc.DemoVPC.id}"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "PrivateSubnet"
  }
}

resource "aws_route_table" "PublicRoute" {
  vpc_id = "${aws_vpc.DemoVPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terraform-igw.id}"
  }
  tags = {
    Name = "Public RT"
  }
}

resource "aws_route_table" "PrivateRoute" {
  vpc_id = "${aws_vpc.DemoVPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.terraformNAT.id}"
  }

  tags = {
    Name = "Private RT"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.publicSubnet.id}"
  route_table_id = "${aws_route_table.PublicRoute.id}"
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.privateSubnet.id}"
  route_table_id = "${aws_route_table.PrivateRoute.id}"
}

resource "aws_eip" "ElaticIP"{
  depends_on = [aws_internet_gateway.terraform-igw]

  tags = {
    Name = "TerraformElasticIP"
  }
}

resource "aws_nat_gateway" "terraformNAT" {
  allocation_id = aws_eip.ElaticIP.id
  subnet_id = aws_subnet.publicSubnet.id

  tags = {
    Name = "Terraform NAT"
  }
}
