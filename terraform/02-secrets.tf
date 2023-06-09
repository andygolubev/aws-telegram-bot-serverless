resource "aws_secretsmanager_secret" "bot-token-secret" {
  name = "Telegram_Bot_Token"

  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id     = aws_secretsmanager_secret.bot-token-secret.id
  secret_string = var.bot_token
}