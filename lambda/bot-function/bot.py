import telebot
import json
import boto3
import os
from botocore.exceptions import ClientError
from io import BytesIO
from boto3.dynamodb.conditions import Key

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
    
def lambda_handler(event, context):
    logger.debug(f"APP:: event: {event}")
    logger.debug(f"APP:: event body: {event['body']}")
    logger.debug(f"APP:: context: {context}")

    update = telebot.types.Update.de_json(event['body'])

    logger.debug(f"APP:: This is bot update structure: {update}")
    logger.debug(f"APP:: Message type: {update.message.content_type}")

    match update.message.content_type:
        case 'text':
            if update.message.text == '/start':
                bot.reply_to(update.message, f"Welcome! Send an image for recognition")
            elif update.message.text == '/stat':
                bot.reply_to(update.message, f"Statistics")
            else:
                bot.reply_to(update.message, f"Send an image to recognize of type /stat to show statistics")
        case 'photo':
            images_bucket_name = os.environ.get('IMAGES_BUCKET_NAME')

            fileID = update.message.photo[-1].file_id
            logger.debug(f"APP:: fileID: {fileID}")
            file_info = bot.get_file(fileID)
            logger.debug(f"APP:: file_info: {file_info}")
            downloaded_file = bot.download_file(file_info.file_path)

            #
            #   Store the image to the S3
            #

            s3_client = boto3.client('s3')
            try:
                response = s3_client.upload_fileobj(BytesIO(downloaded_file), images_bucket_name, fileID)
                logger.debug(f"APP:: s3 upload result : {response}")

                bot.reply_to(update.message, f"Image has stored: s3://{images_bucket_name}/{fileID}")
            except ClientError as e:
                logger.error(e)
                bot.reply_to(update.message, f"ERROR: Can't store the image")

            
            

            #
            #   Detect Label on the stored image
            #

            rekognition_client = boto3.client('rekognition')
            try:
                response = rekognition_client.detect_labels(Image={'S3Object':{'Bucket':images_bucket_name,'Name':fileID}}, MaxLabels=10)

                logger.debug(f"APP:: rekognition result : {response}")



                json_data_dump = json.dumps(response)
                json_data = json.loads(json_data_dump)
                
                result = []
                for label in json_data["Labels"]:
                    name = label["Name"]
                    first_category = label["Categories"][0]["Name"]
                    confidence = label["Confidence"]
                    result.append(f"Label: {name}")
                    result.append(f"  Category: {first_category}")
                    result.append(f"  Confidence: {confidence}")

                delimiter = '\n'

                result_string = delimiter.join(result)
                logger.debug(f"APP:: LABELS string: {result_string}")

                bot.reply_to(update.message, f"{result_string}")
                    
            except ClientError as e:
                logger.error(e)
                bot.reply_to(update.message, f"ERROR: Can't detect labels")

            #
            #  Save statistics
            #



            dynamodb_client = boto3.resource('dynamodb')
            try:
                table = dynamodb_client.Table('aws-telegram-bot-statistics')
                response = table.query(
                    KeyConditionExpression=Key('UserID').eq(update.message['json']['from']['id'])
                )
                items = response['Items']
                logger.debug(items)

            except ClientError as e:
                logger.error(e)
                raise


        case _:
            bot.reply_to(update.message, f"I can't process this {update.message.content_type}")



    
    return {
        'statusCode': 200,
        'body': json.dumps('Processed message id: ' + str(update.message.message_id))
    }
    

