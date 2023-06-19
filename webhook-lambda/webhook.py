import telebot
import json
import boto3
import os
from botocore.exceptions import ClientError

region = os.environ.get('AWS_CLOUD_REGION')

def get_bot_token_from_secret_manager():

    secret_name = "Bot_token"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

    # Decrypts secret using the associated KMS key.
    bot_token = get_secret_value_response['SecretString']

    return bot_token



bot = telebot.TeleBot(get_bot_token_from_secret_manager())


def lambda_handler(event, context):
    
    callback_url = os.environ.get('CALLBACK_URL')
    webhook_info = bot.get_webhook_info()
    print(webhook_info)


    # Set webhook
    bot.set_webhook(url=callback_url)

        
    print("AFTER SET")
    callback_url = os.environ.get('CALLBACK_URL')
    webhook_info = bot.get_webhook_info()
    print(webhook_info)
    
    return {
        'statusCode': 200,
        'body': json.dumps('Current callback url: ' + str(callback_url))
    }
    
