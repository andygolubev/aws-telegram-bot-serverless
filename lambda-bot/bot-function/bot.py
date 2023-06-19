import telebot
import json
import boto3
import os
from botocore.exceptions import ClientError

import logging

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

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
        raise e

    # Decrypts secret using the associated KMS key.
    bot_token = get_secret_value_response['SecretString']

    return bot_token



bot = telebot.TeleBot(get_bot_token_from_secret_manager())


# Handle '/start' and '/help'
@bot.message_handler(commands=['help', 'start'])
def send_welcome(message):
    print("start")
    print(message)
    print("end")
    bot.reply_to(message, "Hi!!!!!!!!!!!!")
    #bot.stop_bot()
    


# Handle all other messages with content_type 'text' (content_types defaults to ['text'])
@bot.message_handler(func=lambda message: True, content_types=['text'])
def echo_message(message):
    print("start bot message handler")
    print(message)
    print("end bot message handler")
    bot.reply_to(message, f"Answer to: {message.text}")
    #bot.send_message(chat_id=message.chat.id,  text="-----")
    # bot.stop_polling()

    


def lambda_handler(event, context):
    print("event:")
    logger.debug("event:")
    print(event)
    print("event body:")
    print(event['body'])
    print("context:")
    print(context)
    

    # return {
    #     'statusCode': 200,
    #     'body': json.dumps('all good')
    # }


    update = telebot.types.Update.de_json(event['body'])
    print("This is bot update structure:")
    print(update)
    bot.reply_to(update.message, f"Answer to: {update.message.text}")
    # bot.process_new_updates([update])
    
    return {
        'statusCode': 200,
        'body': json.dumps('Processed message id: ' + str(update.message.message_id))
    }
    

