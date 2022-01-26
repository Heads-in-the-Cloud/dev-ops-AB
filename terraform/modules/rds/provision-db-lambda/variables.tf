variable "event_routes" {
  description = "A map from a meaningful operator shorthand to the target ARN and list of the event names that CloudWatch should forward to them."
  type = map(object({
    description = string
    event_names = list(string)
    target_arn  = string
  }))

  /*
  event_routes = {
    forward_to_kpi_tracker = {
      description = "Forward events to KPI tracker"
      event_names = [
        "UserSignedUp",
        "UserWatchedLessonVideo",
      ]
      target_arn = "arn:aws:events:ca-central-1:000000000000:event-bus/default"
    }
  }
  */
}
