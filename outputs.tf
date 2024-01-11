output "app_load_balancer_dns" {
  description = "The DNS name of the application load balancer"
  value       = module.load_balancer.alb_dns_name
}
