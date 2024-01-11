resource "aws_vpc" "main" {
  cidr_block           = var.config.vpc.cidr
  enable_dns_support   = var.config.vpc.enable_dns_support
  enable_dns_hostnames = var.config.vpc.enable_dns_hostnames

  tags = merge(
      {
        "Name" = lower("${var.config.resources.name}-vpc")
      },
      var.config.resources.tags
    )
}
 
resource "aws_subnet" "public" {
  count                   = length(var.config.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.config.public_subnets[count.index].cidr
  availability_zone       = var.config.public_subnets[count.index].availability_zone
  map_public_ip_on_launch = true

  tags = merge(
      {
        "Name" = lower("${var.config.resources.name}-public-subnet-${count.index}")
      },
      var.config.resources.tags
    )
}

resource "aws_subnet" "private" {
  count             = length(var.config.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.config.private_subnets[count.index].cidr
  availability_zone = var.config.private_subnets[count.index].availability_zone

  tags = merge(
      {
        "Name" = lower("${var.config.resources.name}-private-subnet-${count.index}")
      },
      var.config.resources.tags
    )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
      {
        "Name" = lower("${var.config.resources.name}-igw")
      },
      var.config.resources.tags
    )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  lifecycle {
    create_before_destroy = false
  }

  tags = merge(
      {
        "Name" = lower("${var.config.resources.name}-public-routetable")
      },
      var.config.resources.tags
    )
}

resource "aws_route_table_association" "public" {
  count          = length(var.config.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  lifecycle {
    create_before_destroy = false
  }

  tags = merge(
      {
        "Name" = lower("${var.config.resources.name}-private-routetable")
      },
      var.config.resources.tags
    )
}

resource "aws_route_table_association" "private" {
  count          = length(var.config.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


# NAT Gateway
resource "aws_eip" "nat" {
  count = var.config.nat_gateway.create_eip ? 1 : 0
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
      {
        "Name" = lower("${var.config.resources.name}-NATgw")
      },
      var.config.resources.tags
    )
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id  # Assuming the first public subnet for NAT Gateway
  depends_on    = [aws_eip.nat]

  tags = merge(
      {
        "Name" = lower("${var.config.resources.name}-NATgw")
      },
      var.config.resources.tags
    )
}
