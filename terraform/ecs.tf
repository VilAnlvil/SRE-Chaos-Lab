# 🎯 El Orquestador (Cluster)
resource "aws_ecs_cluster" "sre_cluster" {
  name = "sre-chaos-cluster"
}

# 📝 Grupo de Logs (Observabilidad Centralizada)
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/ecs/sre-chaos-api"
  retention_in_days = 7
}

# 🔐 Seguridad (Firewall para la API)
resource "aws_security_group" "api_sg" {
  name   = "sre-api-sg"
  vpc_id = aws_vpc.sre_vpc.id

  # Permitir puerto 8000 para entrar a la API
  ingress {
    from_port   = 8000
    to_port     = 8000
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

# 📜 Definición de la Tarea (Task Definition)
resource "aws_ecs_task_definition" "api_task" {
  family                   = "sre-chaos-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "sre-api-container"
    image     = "${aws_ecr_repository.sre_repo.repository_url}:latest"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 8000
      hostPort      = 8000
    }]
    
    # 🕵️ Observabilidad: Enviar logs a CloudWatch
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.api_logs.name
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }

    # 🩺 Self-healing: ECS reiniciará el contenedor si este comando falla
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60 # Aumentado de 10 a 60 para dar tiempo a la app a arrancar
    }
  }])
}

# 🛡️ El Servicio
resource "aws_ecs_service" "api_service" {
  name            = "sre-chaos-service"
  cluster         = aws_ecs_cluster.sre_cluster.id
  task_definition = aws_ecs_task_definition.api_task.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.pub_a.id, aws_subnet.pub_b.id] # Multi-AZ activado
    security_groups  = [aws_security_group.api_sg.id]
    assign_public_ip = true
  }
}

# 🎭 Permisos Estándar (IAM Role)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role-sre"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
