import json
import boto3
import snowflake.connector
import os


def lambda_handler(event, context):
    secret_name = os.environ['SECRET_NAME']

    client = boto3.client(service_name='secretsmanager')
    secret = client.get_secret_value(SecretId=secret_name)
    credentials = json.loads(secret["SecretString"])

    conn = snowflake.connector.connect(
        account=credentials["url"],
        password=credentials["password"],
        user=credentials["username"],
        view=credentials["view"]
    )

    try:
        cursor = conn.cursor()
        view_name = credentials["view"]
        cursor.execute(f"SELECT * FROM {view_name} LIMIT 10")
        rows = cursor.fetchall()
        return {
            'statusCode': 200,
            'body': json.dumps(rows)
        }
    except Exception as e:
        print("Error executing query:", e)
        return {
            'statusCode': 500,
            'body': json.dumps("Error executing query")
        }
    finally:
        cursor.close()
        conn.close()