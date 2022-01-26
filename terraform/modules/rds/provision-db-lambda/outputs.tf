output "event_rule_name" {
  value = { for route_shorthand, route_details in var.event_routes :
    route_shorthand => aws_cloudwatch_event_rule.captures[route_shorthand].name
  }
}

output "event_rule_arn" {
  value = { for route_shorthand, route_details in var.event_routes :
    route_shorthand => aws_cloudwatch_event_rule.captures[route_shorthand].arn
  }
}
