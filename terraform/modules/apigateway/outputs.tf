output "api_endpoint" {
  description = "The HTTP API endpoint URL"
  value       = aws_apigatewayv2_api.recipes_api.api_endpoint
}

output "stage_url" {
  description = "The URL to invoke the API stage"
  value       = aws_apigatewayv2_stage.recipes_stage.invoke_url
} 