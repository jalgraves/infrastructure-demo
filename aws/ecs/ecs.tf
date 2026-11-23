# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+

resource "aws_ecs_cluster" "this" {
  for_each = {
    for cluster_name, cluster in local.configs.clusters : cluster_name => cluster
  }
  name = each.key
  tags = each.value.tags
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "EcsTaskExecution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "secrets_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.secrets_policy.arn
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  for_each = {
    for item in flatten([
      for cluster_name, cluster in local.configs.clusters : [
        for service_name, service in cluster.services : {
          cluster_name = cluster_name
          service_name = service_name
          vpc_id       = service.vpc_id
        }
      ]
    ])
    : "${item.cluster_name}:${item.service_name}" => item
  }
  name        = "services.internal"
  description = "Private namespace for ECS microservices"
  vpc         = each.value.vpc_id
}

resource "aws_ecs_task_definition" "task" {
  for_each = {
    for item in flatten([
      for cluster_name, cluster in local.configs.clusters : [
        for service_name, service in cluster.services : {
          cluster_name             = cluster_name
          service_name             = service_name
          family                   = service.family
          image                    = service.image
          port                     = service.port
          secrets                  = service.secrets
          cpu                      = service.cpu
          memory                   = service.memory
          network_mode             = service.network_mode
          requires_compatibilities = service.requires_compatibilities
        }
      ]
    ])
    : "${item.cluster_name}:${item.service_name}" => item
  }

  family                   = each.value.family
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  network_mode             = each.value.network_mode
  requires_compatibilities = each.value.requires_compatibilities
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = each.value.service_name
      image = each.value.image
      portMappings = [{
        containerPort = each.value.port
        hostPort      = each.value.port
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${each.key}"
          awslogs-region        = local.configs.region
          awslogs-stream-prefix = "ecs"
        }
      }
      secrets = try(each.value.secrets, [])
    }
  ])
}

resource "aws_service_discovery_service" "svc" {
  for_each = {
    for item in flatten([
      for cluster_name, cluster in local.configs.clusters : [
        for service_name, service in cluster.services : {
          cluster_name = cluster_name
          service_name = service_name
        }
      ]
    ])
    : "${item.cluster_name}:${item.service_name}" => item
  }

  name         = each.value.service_name
  namespace_id = aws_service_discovery_private_dns_namespace.this["${each.value.cluster_name}:${each.value.service_name}"].id

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this["${each.value.cluster_name}:${each.value.service_name}"].id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "WEIGHTED"
  }
}

resource "aws_ecs_service" "svc" {
  for_each = {
    for item in flatten([
      for cluster_name, cluster in local.configs.clusters : [
        for service_name, service in cluster.services : {
          cluster_name      = cluster_name
          service_name      = service_name
          port              = service.port
          cpu               = service.cpu
          memory            = service.memory
          desired_count     = service.desired_count
          capacity_provider = service.capacity_provider
          public            = service.public
          subnets           = service.subnets
        }
      ]
    ])
    : "${item.cluster_name}:${item.service_name}" => item
  }
  name                 = each.value.service_name
  cluster              = aws_ecs_cluster.this[each.value.cluster_name].id
  task_definition      = aws_ecs_task_definition.task[each.value.service_name].arn
  desired_count        = each.value.desired_count
  force_new_deployment = true

  capacity_provider_strategy {
    capacity_provider = each.value.capacity_provider
    weight            = 1
  }

  network_configuration {
    subnets          = each.value.subnets
    security_groups  = [aws_security_group.endpoints.id]
    assign_public_ip = true
  }

  dynamic "load_balancer" {
    for_each = each.value.public ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.this[each.key].arn
      container_name   = each.key
      container_port   = each.value.port
    }
  }

  service_registries {
    registry_arn = aws_service_discovery_service.svc[each.key].arn
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  for_each = {
    for cluster_name, cluster in local.configs.clusters : cluster_name => cluster
  }
  cluster_name = aws_ecs_cluster.this[each.key].name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}
