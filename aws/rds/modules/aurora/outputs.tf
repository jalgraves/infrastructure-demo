output "cluster_arn" {
  description = "ARN of the Aurora cluster."
  value       = aws_rds_cluster.this.arn
}

output "cluster_identifier" {
  description = "Identifier of the Aurora cluster."
  value       = aws_rds_cluster.this.cluster_identifier
}

output "cluster_resource_id" {
  description = "AWS resource ID of the Aurora cluster."
  value       = aws_rds_cluster.this.cluster_resource_id
}

output "endpoint" {
  description = "Writer endpoint of the Aurora cluster."
  value       = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint of the Aurora cluster."
  value       = aws_rds_cluster.this.reader_endpoint
}

output "port" {
  description = "Database port of the Aurora cluster."
  value       = aws_rds_cluster.this.port
}

output "master_user_secret_arn" {
  description = "ARN of the managed master-user secret, or null when password management is disabled."
  value       = try(aws_rds_cluster.this.master_user_secret[0].secret_arn, null)
}

output "instance_identifiers" {
  description = "Identifiers of the Aurora cluster instances."
  value       = { for key, instance in aws_rds_cluster_instance.this : key => instance.identifier }
}
