import json
import boto3
import logging
import email
import os
import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')
bucket_name = os.environ['S3_BUCKET_NAME']


def extract_email_body(message):
    msg = email.message_from_string(message)
    if msg.is_multipart():
        for part in msg.walk():
            if part.get_content_type() == "text/plain":
                return part.get_payload()
    else:
        return msg.get_payload()


def lambda_handler(event, context):
    logger.info("Received event: {}".format(json.dumps(event)))

    sns_message = json.loads(event['Records'][0]['Sns']['Message'])
    mail = sns_message['mail']
    source = mail['source']  # Sender
    subject = mail['commonHeaders']['subject']  # Subject

    raw_content = sns_message['content']
    body = extract_email_body(raw_content)  # Get the plain text content

    # Get current date and time in a readable format
    current_datetime = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    email_data = {
        'sender': source,
        'subject': subject,
        'body': body,
        'received_datetime': current_datetime
    }

    s3_key = 'emails/' + mail['messageId']
    s3.put_object(Bucket=bucket_name, Key=s3_key, Body=json.dumps(email_data))

    return {
        'statusCode': 200,
        'body': json.dumps('Email data saved to S3')
    }
