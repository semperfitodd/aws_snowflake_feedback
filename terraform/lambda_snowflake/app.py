import boto3
import csv
import io
import json
import os

s3_client = boto3.client('s3')
comprehend = boto3.client('comprehend')
ses_bucket_name = os.environ['S3_BUCKET_NAME_SES']
snowflake_bucket_name = os.environ['S3_BUCKET_NAME_SNOWFLAKE']
emails_folder = 'emails/'
output_csv_file = 'aggregated_emails.csv'


def null_if_empty(value):
    return value if value else 'null'


def get_sentiment_and_key_phrases(text):
    # Detect sentiment
    sentiment_response = comprehend.detect_sentiment(Text=text, LanguageCode='en')
    sentiment = sentiment_response['Sentiment']

    # Detect key phrases
    key_phrases_response = comprehend.detect_key_phrases(Text=text, LanguageCode='en')
    key_phrases_list = [phrase['Text'] for phrase in key_phrases_response['KeyPhrases']]
    key_phrases = '. '.join(key_phrases_list)

    return sentiment, key_phrases


def lambda_handler(event, context):
    response = s3_client.list_objects_v2(Bucket=ses_bucket_name, Prefix=emails_folder)
    all_emails = []
    files_to_delete = []

    if 'Contents' in response:
        for item in response['Contents']:
            file_content = s3_client.get_object(Bucket=ses_bucket_name, Key=item['Key'])['Body'].read().decode('utf-8')
            email_data = json.loads(file_content)
            email_body = email_data.get('body', '')
            sentiment, key_phrases = get_sentiment_and_key_phrases(email_body)
            email_data.update({'sentiment': sentiment, 'key_phrases': key_phrases})
            all_emails.append(email_data)
            files_to_delete.append({'Key': item['Key']})

    output = io.StringIO()
    writer = csv.writer(output, delimiter='|')
    writer.writerow(['datetime', 'sender', 'subject', 'body', 'sentiment', 'key_phrases'])

    for email in all_emails:
        writer.writerow([
            null_if_empty(email.get('received_datetime', '')),
            null_if_empty(email.get('sender', '')),
            null_if_empty(email.get('subject', '')),
            null_if_empty(email.get('body', '')),
            null_if_empty(email.get('sentiment', '')),
            null_if_empty(email.get('key_phrases', ''))
        ])

    # Upload the file to Snowflake S3 bucket
    try:
        s3_client.put_object(Bucket=snowflake_bucket_name, Key=output_csv_file, Body=output.getvalue())

        # If upload is successful, delete the processed files
        for file in files_to_delete:
            s3_client.delete_object(Bucket=ses_bucket_name, Key=file['Key'])
        return {
            'statusCode': 200,
            'body': json.dumps('Email data aggregated into CSV and processed files deleted')
        }
    except Exception as e:
        # Log the error and return a failure response
        print(e)
        return {
            'statusCode': 500,
            'body': json.dumps('Error in processing')
        }
