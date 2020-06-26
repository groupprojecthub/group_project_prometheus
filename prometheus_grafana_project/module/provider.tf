provider "aws" {
  version = "~> 2.66"
  region  = "${var.region}"
}

resource "aws_vpc" "project1" {
  cidr_block       = "${var.cidr_block}"
  instance_tenancy = "dedicated"

  tags = {
    Name = "project1"
  }
}

#creating Public subnets
resource "aws_subnet" "public1" {
  vpc_id                  = "${aws_vpc.project1.id}"
  cidr_block              = "${var.public_cidr_block1}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags = {
    Name = "public_subnet1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = "${aws_vpc.project1.id}"
  cidr_block              = "${var.public_cidr_block2}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}b"

  tags = {
    Name = "public_subnet2"
  }
}

resource "aws_subnet" "public3" {
  vpc_id                  = "${aws_vpc.project1.id}"
  cidr_block              = "${var.public_cidr_block3}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}c"

  tags = {
    Name = "public_subnet3"
  }
}

#creating private subnets
resource "aws_subnet" "private1" {
  vpc_id                  = "${aws_vpc.project1.id}"
  cidr_block              = "${var.private_cidr_block1}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags = {
    Name = "private_subnet1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id                  = "${aws_vpc.project1.id}"
  cidr_block              = "${var.private_cidr_block2}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}b"

  tags = {
    Name = "private_subnet2"
  }
}

resource "aws_subnet" "private3" {
  vpc_id                  = "${aws_vpc.project1.id}"
  cidr_block              = "${var.private_cidr_block3}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}c"

  tags = {
    Name = "private_subnet3"
  }
}
