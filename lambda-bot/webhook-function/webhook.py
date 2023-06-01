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
    print(bot.get_webhook_info(url=callback_url))


    # Set webhook
    bot.set_webhook(url=callback_url)
    
    return {
        'statusCode': 200,
        'body': json.dumps('Current callback url: ' + str(callback_url))
    }
    
    #bot.reply_to(event, f"Answer: {event.text}")
    #update = event.json()


    
    # print(bot.get_webhook_info())
    # bot.get_webhook_info(5)
    # bot.set_webhook(url='https://xhfw8j4pwg.execute-api.us-east-1.amazonaws.com/prod/callback')
    # bot.run_webhooks()
    
    # bot.polling()



#  curl -X POST https://api.telegram.org/bot5565527261:AAHhqVqN__-CMG7LEGnMngxTYREgqyzOv5Q/getWebhookInfo 
#
# {"ok":true,"result":{"url":"https://xhfw8j4pwg.execute-api.us-east-1.amazonaws.com/prod/callback","has_custom_certificate":false,"pending_update_count":0,"max_connections":40,"ip_address":"108.156.60.15"}}% 


## curl -X POST https://api.telegram.org/bot5565527261:AAHhqVqN__-CMG7LEGnMngxTYREgqyzOv5Q/setWebhook -d "url=https://xhfw8j4pwg.execute-api.us-east-1.amazonaws.com/prod/callback";


# # Use this code snippet in your app.
# # If you need more information about configurations
# # or implementing the sample code, visit the AWS docs:
# # https://aws.amazon.com/developer/language/python/

# import boto3
# from botocore.exceptions import ClientError



