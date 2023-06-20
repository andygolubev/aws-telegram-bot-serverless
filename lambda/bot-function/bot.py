import telebot
import json
import boto3
import os
from botocore.exceptions import ClientError
from io import BytesIO

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
    logger.debug(f"APP:: event: {event}")
    logger.debug(f"APP:: event body: {event['body']}")
    logger.debug(f"APP:: context: {context}")

    update = telebot.types.Update.de_json(event['body'])

    logger.debug(f"APP:: This is bot update structure: {update}")
    logger.debug(f"APP:: Message type: {update.message.content_type}")

    match update.message.content_type:
        case 'text':
            bot.reply_to(update.message, f"Send an image instead of this text: {update.message.text}")
        case 'photo':
            

            fileID = update.message.photo[-1].file_id
            logger.debug(f"APP:: fileID: {fileID}")
            file_info = bot.get_file(fileID)
            logger.debug(f"APP:: file_info: {file_info}")
            downloaded_file = bot.download_file(file_info.file_path)
            logger.debug(f"APP:: image object type : {type(downloaded_file)}")


            s3_client = boto3.client('s3')
            s3_client.upload_fileobj(BytesIO(downloaded_file), os.environ.get('IMAGES_BUCKET_NAME'), fileID) 

            # s3_client = boto3.client('s3')
            # try:
            #     response = s3_client.upload_fileobj(downloaded_file, "telegram-bot-serverless-044694793931", "777.png")
            # except ClientError as e:
            #     logging.error(e)

            #AgACAgIAAxkBAAIFXGSRpuBC3YCvLedStrazkrtFySIBAAI7zjEbVD-QSGAhvPqPsCQGAQADAgADeAADLwQ
            #AgACAgIAAxkBAAIFXmSRpvE9o5Z7vP8ThBl_LbYy3jbbAAI8zjEbVD-QSHaHIKNsHybiAQADAgADeQADLwQ
            #AgACAgIAAxkBAAIFYGSRpx_8Cc6SQG_F4rb4ozBnt7lcAALSzTEbVD-QSG3iBwxKZzmJAQADAgADeAADLwQ
            #AgACAgIAAxkBAAIFYmSRpyU7D0pR0Zq4YxhL5rjrj7i-AALSzTEbVD-QSG3iBwxKZzmJAQADAgADeAADLwQ



            bot.reply_to(update.message, f"Good image: {fileID}")

        case _:
            bot.reply_to(update.message, f"I can't process this")



    
    return {
        'statusCode': 200,
        'body': json.dumps('Processed message id: ' + str(update.message.message_id))
    }
    

