output "instance_public_ip" {
  value       = aws_instance.devops_lab.public_ip
  description = "Public IP address of the DevOps lab instance"
}

output "instance_id" {
  value       = aws_instance.devops_lab.id
  description = "ID of the DevOps lab instance"
}

output "ssm_connect_command" {
  value       = "aws ssm start-session --target ${aws_instance.devops_lab.id}"
  description = "AWS CLI command to connect to the instance via SSM Session Manager"
}

output "ssm_port_forward_command" {
  value       = "aws ssm start-session --target ${aws_instance.devops_lab.id} --document-name AWS-StartPortForwardingSession --parameters '{\"portNumber\":[\"6443\"],\"localPortNumber\":[\"6443\"]}'"
  description = "AWS CLI command to port forward Kubernetes API (6443) to local machine via SSM"
}
