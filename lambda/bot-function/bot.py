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
            images_bucket_name = os.environ.get('IMAGES_BUCKET_NAME')

            fileID = update.message.photo[-1].file_id
            logger.debug(f"APP:: fileID: {fileID}")
            file_info = bot.get_file(fileID)
            logger.debug(f"APP:: file_info: {file_info}")
            downloaded_file = bot.download_file(file_info.file_path)

            s3_client = boto3.client('s3')
            try:
                response = s3_client.upload_fileobj(BytesIO(downloaded_file), images_bucket_name, fileID)
                logger.debug(f"APP:: s3 upload result : {response}")
            except ClientError as e:
                logger.error(e)

            rekognition_client = boto3.client('rekognition')

            response = rekognition_client.detect_labels(Image={'S3Object':{'Bucket':images_bucket_name,'Name':fileID}}, MaxLabels=10)

            logger.debug(f"APP:: rekognition result : {response}")



            json_data_dump = json.dumps(response)
            json_data = json.loads(json_data_dump)
            
            result_string = ''
            for label in json_data["Labels"]:
                name = label["Name"]
                first_category = label["Categories"][0]["Name"]
                confidence = label["Confidence"]
                
                result = []
                result.append(f"Label: {name}")
                result.append(f"  Category: {first_category}")
                result.append(f"  Confidence: {confidence}")

                delimiter = '\n'

                result_string = delimiter.join(result)
                logger.debug(f"APP:: LABELS string : {result_string}")

            bot.reply_to(update.message, f"Good image: s3://{images_bucket_name}/{fileID}")
            bot.reply_to(update.message, f"result_string")

        case _:
            bot.reply_to(update.message, f"I can't process \n this {update.message.content_type}")



    
    return {
        'statusCode': 200,
        'body': json.dumps('Processed message id: ' + str(update.message.message_id))
    }
    

