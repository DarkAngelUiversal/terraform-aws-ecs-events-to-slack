resource "aws_sns_topic" "prod_chatbot" {
  name = "${var.name}-topic"
  tags = var.tags
}

resource "aws_sns_topic_policy" "prod_chatbot" {
  arn = aws_sns_topic.prod_chatbot.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.prod_chatbot.arn
      }
    ]
  })
}
