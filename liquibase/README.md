# Setup Snowflake utilizing Liquibase

## Assumptions:
* Liquibase is installed locally and in executing user's path
* Username specified in variable LIQUIBASE_COMMAND_USERNAME is granted roles `sysadmin` and `accountadmin`
* Snowflake database specified in variable SNOWFLAKE_DATABASE exists and user has required access 
* Snowflake warehouse specified in variable SNOWFLAKE_WAREHOUSE exists and user has required access 
* Due to coordination required between AWS and Snowflake, the full install must be run in two steps.  Execute process below and utilize values in file `aws_feedback_info.txt` to complete AWS configuration


## Preliminary Steps:
* Copy file `sample.lb_env` to `.lb_env` and set variable values as specified below
  * NOTE:  if you want to be prompted for all variables skip the this step
* Perform all necessary AWS configurations specified separately

## Variables in file .lb_env:
* SNOWFLAKE_DATABASE              : Snowflake database where all objects are created
* SNOWFLAKE_WAREHOUSE             : Snowflake warehouse utilized to execute process
* SNOWFLAKE_ACCOUNT               : Snowflake account number used to build connection string
* LIQUIBASE_COMMAND_USERNAME      : Snowflake user that has `sysadmin` and `accountadmin` roles granted
* LIQUIBASE_COMMAND_PASSWORD      : Password for user specified in LIQUIBASE_COMMAND_USERNAME
* SNOWFLAKE_EMAILNOTIFICATIONLIST : List of comma-separated email addresses to received alert notifications.   These must meet all Snowflake requirements for send emails.
* SNOWFLAKE_REPORT_USER_PASSWORD  : Password for user `report_display` created for viewing data
* AWS_IAM_ROLE_ARN                : AWS IAM Role ARN previously created for S3 access
* AWS_S3_BUCKET_NAME              : AWS S3 bucket named used to store JSON files 

## Execution:
* Execute file `run_liquibase.sh`
* If parameter file `.lb_env` not utilized, respond to prompts for necessary information.   Prompts correspond to variables specified above
* When prompted by "Stop the process after initial creation of Storage Integration" answer as follows:
  * If process has not been previously executed and the additional AWS configuration not completed then respond with "1".
  * If process has been previously executed and the additional AWS configuration completed then respond with "0".
* Use information in file `aws_feedback_info.txt` to complete the AWS configuration.  This will require two different steps:
  1.  After initial execution, use values for "SNOWFLAKE_AWS_USER_ARN" and "SNOWFLAKE_EXTERNAL_ID" to complete S3 access setup.
  2.  After final execution, use values for "SNOWFLAKE_SQL_ARN" to complete SQS setup.
     
