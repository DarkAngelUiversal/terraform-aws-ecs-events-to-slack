resource "aws_sns_topic" "this" {
  #tfsec:ignore:aws-sns-topic-encryption-use-cmk
  count = var.sns_topic_arn == "" ? 1 : 0
  name  = var.aws_sns_topic_name
  tags  = var.tags

  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_policy" "this" {
  count = var.sns_topic_arn == "" ? 1 : 0
  arn   = aws_sns_topic.this[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.this[0].arn
      }
    ]
  })
}
