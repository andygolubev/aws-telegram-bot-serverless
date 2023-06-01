resource "aws_secretsmanager_secret" "bot-token-secret" {
   name = "Bot_token"
}
 
# Creating a AWS secret versions for database master account (Masteraccoundb)
 
resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id = aws_secretsmanager_secret.bot-token-secret.id
  secret_string = "" # TEMP TOKEN FOR DEBUGGING
}