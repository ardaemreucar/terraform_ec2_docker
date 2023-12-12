output "associate_public_ip_address" {
  description = "our main servers public ip"
  value       = aws_instance.web.public_ip
}
output "aws_ami_id" {
  value = data.aws_ami.ubuntu.id
}