resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = "main"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]

  tags = {
    Name = "Subnet group for RDS"
  }
}

resource "aws_elasticache_subnet_group" "cache-sub-group" {
  name       = "elastic-cache-subgrp"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]

  tags = {
    Name = "Subnet group for elastic cache"
  }
}

resource "aws_db_instance" "rds-instance" {
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = var.dbname
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = var.dbuser
  password               = var.dbpass
  parameter_group_name   = "default.mysql5.7"
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet-group.name
  vpc_security_group_ids = [aws_security_group.backend-sg.id]
}

resource "aws_elasticache_cluster" "cache-cluster" {
  cluster_id           = "cache-cluster"
  engine               = "memcached"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.5"
  port                 = 11211
  security_group_ids   = [aws_security_group.backend-sg.id]
  subnet_group_name    = aws_elasticache_subnet_group.cache-sub-group.name

}

resource "aws_mq_broker" "rmq" {
  broker_name        = "rmq"
  engine_type        = "ActiveMQ"
  engine_version     = "5.15.9"
  host_instance_type = "mq.t2.micro"
  security_groups    = [aws_security_group.backend-sg.id]
  subnet_ids         = [module.vpc.private_subnets[0]]

  user {
    username = var.rmquser
    password = var.rmqpass
  }

}