resource "aws_vpc" "django" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  instance_tenancy = "default"

  tags = {
    Name = "django"
  }
}

resource "aws_subnet" "django_public" {
  count                                       = length(local.public_subnets)
  vpc_id                                      = aws_vpc.django.id
  cidr_block                                  = local.public_subnets[count.index].cidr_block
  availability_zone                           = local.public_subnets[count.index].availability_zone
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true
  private_dns_hostname_type_on_launch         = "ip-name"

  tags = {
    Name = "django-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "django_private" {
  count                                       = length(local.private_subnets)
  vpc_id                                      = aws_vpc.django.id
  cidr_block                                  = local.private_subnets[count.index].cidr_block
  availability_zone                           = local.private_subnets[count.index].availability_zone
  map_public_ip_on_launch                     = false
  enable_resource_name_dns_a_record_on_launch = false
  private_dns_hostname_type_on_launch         = "ip-name"

  tags = {
    Name = "django-private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "django_gw" {
  vpc_id = aws_vpc.django.id

  tags = {
    Name = "django-gw"
  }
}

resource "aws_route_table" "django_public" {
  vpc_id = aws_vpc.django.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.django_gw.id
  }

  tags = {
    Name = "django-public"
  }
}

resource "aws_route_table_association" "django_public" {
  count          = length(local.public_subnets)
  subnet_id      = aws_subnet.django_public[count.index].id
  route_table_id = aws_route_table.django_public.id
}
