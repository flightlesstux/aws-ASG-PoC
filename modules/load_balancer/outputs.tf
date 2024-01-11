output "alb_sg" {
  value = aws_security_group.alb_sg.id
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
