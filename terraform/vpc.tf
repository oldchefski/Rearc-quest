resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name  = "PrimaryVPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "PrimaryVPC-IGW"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "PrimaryVPC-RT"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.main_vpc.id
  route_table_id = aws_route_table.rt.id
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "quest_subnets" {
  count = length(data.aws_availability_zones.available.names)

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = element(var.subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "questnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}
