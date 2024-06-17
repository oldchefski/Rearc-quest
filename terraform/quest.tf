resource "aws_security_group" "quest_secgrp" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "quest_lb" {
  name                = "quest-lb"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.quest_secgrp.id]
  subnets             = aws_subnet.quest_subnets[*].id
}

resource "aws_lb_target_group" "quest_trgt_grp" {
  name        = "quest-lb-target-group"
  target_type = "ip"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
}

resource "aws_lb_listener" "quest_listener" {
  load_balancer_arn = aws_lb.quest_lb.arn
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.quest_trgt_grp.arn
  }
}

resource "aws_ecs_cluster" "quest_cluster" {
  name = "quest-cluster"
}

resource "aws_ecs_task_definition" "quest_task" {
  family                    = "quest"
  execution_role_arn        = "arn:aws:iam::670620370144:role/ecsTaskExecutionRole"
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  cpu                       = "256"
  memory                    = "512"

  container_definitions = <<DEFINITION
[
  {
    "name": "rearc-quest",
    "image": "670620370144.dkr.ecr.us-east-2.amazonaws.com/quest:latest",
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "quest_service" {
  name              = "quest"
  cluster           = aws_ecs_cluster.quest_cluster.id
  task_definition   = aws_ecs_task_definition.quest_task.arn
  desired_count     = 1
  launch_type       = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.quest_subnets[*].id
    security_groups  = [aws_security_group.quest_secgrp.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn  = aws_lb_target_group.quest_trgt_grp.arn
    container_name    = "rearc-quest"
    container_port    = 3000
  }
}