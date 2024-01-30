import smtplib
import random
import boto3
import json
import logging
from botocore.response import StreamingBody
from secrets import from_email, to_email, password

bedrock = boto3.client(service_name='bedrock-runtime', region_name='us-east-1')

SMTP_SERVER = 'smtp.gmail.com'
SMTP_PORT = 465
MODEL_ID = 'arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-instant-v1'
ACCEPT = 'application/json'
CONTENT_TYPE = 'application/json'
EMAIL_TYPES = ['negative', 'positive', 'neutral']


def invoke_bedrock_model(email_type):
    body = json.dumps({
        "prompt": f"\n\nHuman: Create a {email_type} email subject and three sentence body. \n\nAssistant:",
        "max_tokens_to_sample": 300,
        "temperature": 0.7,
        "top_p": 1,
    })
    try:
        response = bedrock.invoke_model(body=body, modelId=MODEL_ID, accept=ACCEPT, contentType=CONTENT_TYPE)
        if isinstance(response.get('body'), StreamingBody):
            response_content = response['body'].read().decode('utf-8')
        else:
            response_content = response.get('body')

        response_body = json.loads(response_content)
        completion = response_body.get('completion', '')
        subject_marker = "Subject:"
        subject_index = completion.find(subject_marker)

        if subject_index != -1:
            subject_end = completion.find('\n', subject_index)
            subject = completion[subject_index + len(subject_marker):subject_end].strip()
            body = completion[subject_end:].strip()
        else:
            subject = "No Subject"
            body = completion.strip()

        return subject, body
    except Exception as e:
        logging.error(f"Error invoking Bedrock model: {e}")
        return None, None


def send_email(subject, body, server, email_count):
    msg = f"From: {from_email}\nTo: {to_email}\nSubject: {subject}\n\n{body}"
    try:
        server.sendmail(from_email, to_email, msg)
        logging.info(f"Email sent with subject: {subject}")
        print(f"\rSending emails... {email_count} AI created emails sent", end="")
    except Exception as e:
        logging.error(f"Failed to send email: {e}")


def main():
    try:
        server = smtplib.SMTP_SSL(SMTP_SERVER, SMTP_PORT)
        server.login(from_email, password)
        print("AI creating emails...")

        for i in range(75):
            email_type = random.choice(EMAIL_TYPES)
            subject, body = invoke_bedrock_model(email_type)
            if subject and body:
                send_email(subject, body, server, i + 1)

        server.quit()
        print("\nAll emails sent successfully.")
    except Exception as e:
        logging.error(f"Error with SMTP server: {e}")


if __name__ == "__main__":
    main()
