-- liquibase formatted sql

-- changeset jeff.pell:system-1 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role accountadmin;
create warehouse if not exists poc_01_wh 
  with 
  warehouse_size = xsmall
  auto_suspend = 5
  auto_resume = true
  initially_suspended = true
  ;

-- changeset jeff.pell:system-2 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role accountadmin;
create warehouse if not exists report_role_wh 
  with 
  warehouse_size = xsmall
  auto_suspend = 5
  auto_resume = true
  initially_suspended = true
  ;

-- changeset jeff.pell:system-3 endDelimiter:go runOnChange:true runAlways:false stripComments:false
use role accountadmin;
CREATE STORAGE INTEGRATION IF NOT EXISTS AWS_S3_EMAILS
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = '${AWS_IAM_ROLE_ARN}'
  STORAGE_ALLOWED_LOCATIONS = ('s3://${AWS_S3_BUCKET_NAME}/');
GRANT CREATE STAGE ON SCHEMA public TO ROLE sysadmin;
GRANT USAGE ON INTEGRATION aws_s3_emails TO ROLE sysadmin;
go

-- changeset jeff.pell:system-5 endDelimiter:go runOnChange:true runAlways:true stripComments:false
create table if not exists aws_feedback_info (name varchar(100), value varchar(1000));
truncate table poc_01.public.aws_feedback_info;
desc integration identifier('AWS_S3_EMAILS');
set parval=last_query_id();
insert into poc_01.public.aws_feedback_info (name, value)
with data as (
select parse_json(select system$pipe_status('AWS_S3_EMAILS_JSON')::variant) j
)
select 'SNOWFLAKE_SQS_ARN' as NAME, k.value::text as VALUE
from data, table(flatten(j)) k
where k.key = 'notificationChannelName' 
UNION
select "property" as NAME, "property_value" as VALUE 
from table(result_scan($parval)) 
where "property" in ('STORAGE_AWS_IAM_USER_ARN','STORAGE_AWS_EXTERNAL_ID');
UPDATE aws_feedback_info
set    NAME= 'SNOWFLAKE_AWS_USER_ARN'
where  NAME= 'STORAGE_AWS_IAM_USER_ARN';
UPDATE aws_feedback_info
set    NAME= 'SNOWFLAKE_EXTERNAL_ID'
where  NAME= 'STORAGE_AWS_EXTERNAL_ID';
go

--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:1 select count(1) where ${CONDITIONALSTOP}=0;
-- changeset jeff.pell:system-6 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role accountadmin;
CREATE NOTIFICATION INTEGRATION if not exists sf_email_ni
  TYPE=EMAIL
  ENABLED=TRUE
  ALLOWED_RECIPIENTS = (${SNOWFLAKE_EMAILNOTIFICATIONLIST});


-- changeset jeff.pell:system-7 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
CREATE STAGE if not exists aws_s3_emails 
  STORAGE_INTEGRATION = aws_s3_emails
	URL = 's3://${AWS_S3_BUCKET_NAME}/' 
	DIRECTORY = ( ENABLE = true );

