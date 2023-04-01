resource "aws_db_instance" "database" {
  identifier           = "db-mysql-grupo-l"
  allocated_storage    = 20
  db_name              = "db"
  engine               = "mysql"
  engine_version       = "8.0.32"
  instance_class       = "db.t3.micro"
  username             = "root"
  password             = "123123aa"
  publicly_accessible  = true
  multi_az             = false
  skip_final_snapshot  = true
  vpc_security_group_ids = [
    aws_security_group.database.id
  ]
}

resource "aws_security_group" "database" {
  name        = "database-mariadb"
  description = "Allow inbound traffic from the internet"

  ingress {
    description      = "Allow inbound traffic from the internet"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress  {  #Outbound all allow
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

output "db_endpoint" {
  value = aws_db_instance.database.endpoint
}
