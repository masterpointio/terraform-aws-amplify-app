# outputs.tf

output "arn" {
  description = "The ARN of the main Amplify resource."
  value       = aws_amplify_app.this.arn
}

output "default_domain" {
  description = "The amplify domain (non-custom)."
  value       = aws_amplify_app.this.default_domain
}

output "domain_association_arn" {
  description = "The ARN of the domain association resource."
  value       = var.domain_name == "" ? null : join("", concat([""], aws_amplify_domain_association.this.*.arn))
}

output "custom_domains" {
  description = "List of custom domains that are associated with this resource (if any)."
  value       = var.domain_name == "" ? [] : [
    var.domain_name,
    "www.${var.domain_name}",
    "master.${var.domain_name}",
    "dev.${var.domain_name}",
  ]
}

output "master_webhook_arn" {
  value = aws_amplify_webhook.master.arn
}

output "master_webhook_url" {
  value = aws_amplify_webhook.master.url
}

output "develop_webhook_arn" {
  value = aws_amplify_webhook.develop.arn
}

output "develop_webhook_url" {
  value = aws_amplify_webhook.develop.url
}