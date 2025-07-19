resource "aws_security_group" "rds" {
  name        = "django-database"
  description = "Allow inbound traffic to PostgreSQL"
  vpc_id      = aws_vpc.django.id

  tags = {
    Name = "django-database"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_rds" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

resource "aws_db_subnet_group" "private" {
  name        = "django-private-subnet-group"
  description = "Private subnet group for django project"
  subnet_ids  = [for subnet in aws_subnet.django_private : subnet.id]

  tags = {
    Name = "django-private-subnet-group"
  }
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_instance" "django" {
  identifier                   = "django"
  engine                       = "postgres"
  engine_version               = "17.2"
  instance_class               = "db.t3.micro"
  allocated_storage            = 20
  storage_type                 = "gp2"
  db_subnet_group_name         = aws_db_subnet_group.private.name
  vpc_security_group_ids       = [aws_security_group.rds.id]
  multi_az                     = false
  publicly_accessible          = false
  storage_encrypted            = true
  performance_insights_enabled = true
  username                     = "django"
  password                     = random_password.db_password.result
  db_name                      = "django"
  skip_final_snapshot          = true
  deletion_protection          = false
  apply_immediately            = true
}

output "rds_endpoint" {
  value = aws_db_instance.django.endpoint
}

output "rds_db_name" {
  value = aws_db_instance.django.db_name
}

output "rds_username" {
  value = aws_db_instance.django.username
}

output "rds_password" {
  value     = random_password.db_password.result
  sensitive = true
}
