#!/bin/bash
#set -x

if [ ! -f ./.lb_env ]
then
  echo Enter Snowflake username
  read LIQUIBASE_COMMAND_USERNAME
  export LIQUIBASE_COMMAND_USERNAME
  
  echo Enter Snowflake password
  read LIQUIBASE_COMMAND_PASSWORD
  export LIQUIBASE_COMMAND_PASSWORD

  echo Enter Snowflake Account
  read SNOWFLAKE_ACCOUNT
  export SNOWFLAKE_ACCOUNT
  
  echo Enter notification email list
  read SNOWFLAKE_EMAILNOTIFICATIONLIST
  export SNOWFLAKE_EMAILNOTIFICATIONLIST
  
  echo Enter password for Snowflake report user
  read SNOWFLAKE_REPORT_USER_PASSWORD
  export SNOWFLAKE_REPORT_USER_PASSWORD
  
  echo Enter AWS IAM Role ARN
  read AWS_IAM_ROLE_ARN
  export AWS_IAM_ROLE_ARN

  echo Enter AWS S3 bucket name
  read AWS_S3_BUCKET_NAME
  export AWS_S3_BUCKET_NAME
else
  . ./.lb_env
fi

export LIQUIBASE_COMMAND_URL="jdbc:snowflake://${SNOWFLAKE_ACCOUNT}.snowflakecomputing.com/?db=${SNOWFLAKE_DATABASE}&schema=public&warehouse=${SNOWFLAKE_WAREHOUE}&multi_statement_count=0"

echo Stop the process after initial creation of Storage Integration [0 or 1]
read CONDITIONALSTOP
export CONDITIONALSTOP


liquibase status 
#liquibase update

# Retrieve necessary information for AWS

export SNOWSQL_USER=$LIQUIBASE_COMMAND_USERNAME
export SNOWSQL_PWD=$LIQUIBASE_COMMAND_PASSWORD
export SNOWSQL_ACCOUNT=$SNOWFLAKE_ACCOUNT

rm -f ./aws_feedback_info.txt 2> /dev/null
snowsql -r accountadmin -d poc_01 -s public -q 'select name, value from   poc_01.public.aws_feedback_info' -o output_file=./aws_feedback_info.txt -o friendly=False -o header=False -o output_format=plain -o timing=False -o echo=False -o quiet=true 
