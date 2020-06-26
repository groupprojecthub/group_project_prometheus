resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.project1.id}"

  tags = {
    Name = "project1_IG"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.project1.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "RT_public"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.public1.id}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.public2.id}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_route_table_association" "c" {
  subnet_id      = "${aws_subnet.public3.id}"
  route_table_id = "${aws_route_table.r.id}"
}

# resource "aws_eip" "nat" {
#   vpc  = true
# }
# resource "aws_nat_gateway" "gw" {
#   allocation_id = "${aws_eip.nat.id}"
#   subnet_id     = "${aws_subnet.public1.id}"
# }


# resource "aws_route_table" "r2" {
#   vpc_id = "${aws_vpc.project1.id}"
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = "${aws_nat_gateway.gw.id}"
#   }
#   tags = {
#     Name = "RT_private"
#   }
# }


# resource "aws_route_table_association_private" "a" {
#   subnet_id      = "${aws_subnet.private1.id}"
#   route_table_id = "${aws_route_table.r2.id}"
# }


# resource "aws_route_table_association_private" "b" {
#   subnet_id      = "${aws_subnet.private2.id}"
#   route_table_id = "${aws_route_table.r2.id}"
# }


# resource "aws_route_table_association_private" "c" {
#   subnet_id      = "${aws_subnet.private3.id}"
#   route_table_id = "${aws_route_table.r2.id}"
# }

