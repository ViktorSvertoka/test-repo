resource "aws_security_group" "lb" {
  name        = "django-load-balancer"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.django.id

  tags = {
    Name = "django-load-balancer"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_lb" {
  security_group_id = aws_security_group.lb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_lb" {
  security_group_id = aws_security_group.lb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "app" {
  name        = "django-application"
  description = "Allow HTTP and SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.django.id

  tags = {
    Name = "django-application"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_app" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.lb.id
  from_port                    = 8000
  ip_protocol                  = "tcp"
  to_port                      = 8000
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_app" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
