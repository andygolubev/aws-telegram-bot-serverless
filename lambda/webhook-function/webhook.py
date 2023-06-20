import telebot
import json
import boto3
import os
from botocore.exceptions import ClientError

import logging
logger = logging.getLogger()
logger.setLevel(os.environ.get('LOGGING_LEVEL'))



def get_bot_token_from_secret_manager():

    secret_name = os.environ.get('TOKEN_VAR_NAME')
    
    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name = 'secretsmanager',
        region_name = os.environ.get('AWS_CLOUD_REGION')
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        raise e

    # Decrypts secret using the associated KMS key.
    bot_token = get_secret_value_response['SecretString']

    return bot_token


def lambda_handler(event, context):

    logger.debug(f"APP:: event: {event}")
    logger.debug(f"APP:: context: {context}")

    bot = telebot.TeleBot(get_bot_token_from_secret_manager())
    
    callback_url = os.environ.get('CALLBACK_URL')
    webhook_info = bot.get_webhook_info()
    logger.debug(f"APP:: webhook info before setting: {webhook_info}")

    logger.debug(f"APP:: set webhook for url: {callback_url}")
    bot.set_webhook(url=callback_url)

    webhook_info = bot.get_webhook_info()
    logger.info(f"APP:: webhook info after setting: {webhook_info}")
    
    return {
        'statusCode': 200,
        'body': json.dumps('Current callback url: ' + str(callback_url))
    }
    


