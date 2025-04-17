resource "aws_sns_topic" "this" {
  count = var.sns_topic_arn == "" ? [0] : [1]
  name  = var.aws_sns_topic_name
  tags  = var.tags
}

resource "aws_sns_topic_policy" "this" {
  count = var.sns_topic_arn == "" ? [0] : [1]
  arn   = aws_sns_topic.this.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.this.arn
      }
    ]
  })
}
