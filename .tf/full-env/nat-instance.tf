resource "aws_security_group" "nat" {
  name        = "django-nat-gateway"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.django.id

  tags = {
    Name = "django-nat-gateway"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_nat" {
  security_group_id = aws_security_group.nat.id
  cidr_ipv4         = aws_vpc.django.cidr_block
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_to_nat" {
  security_group_id = aws_security_group.nat.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_nat" {
  security_group_id = aws_security_group.nat.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "nat_instance" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.django_public[0].id
  associate_public_ip_address = true
  key_name                    = local.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.nat.id]
  source_dest_check           = false
  user_data                   = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y iptables-services
    echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/02-ip-forwarding.conf
    sysctl -p /etc/sysctl.d/02-ip-forwarding.conf
    iptables -t nat -A POSTROUTING -s ${aws_vpc.django.cidr_block} -j MASQUERADE
    iptables -P FORWARD ACCEPT
    service iptables save
    systemctl enable iptables.service
    systemctl restart iptables.service
EOF

  tags = {
    Name = "NAT Instance"
  }
}

resource "aws_route_table" "django_private" {
  vpc_id = aws_vpc.django.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_instance.primary_network_interface_id
  }

  tags = {
    Name = "django-private"
  }
}

resource "aws_route_table_association" "django_private" {
  count          = length(local.private_subnets)
  subnet_id      = aws_subnet.django_private[count.index].id
  route_table_id = aws_route_table.django_private.id
}

output "nat_instance_ip" {
  value = aws_instance.nat_instance.public_ip
}
