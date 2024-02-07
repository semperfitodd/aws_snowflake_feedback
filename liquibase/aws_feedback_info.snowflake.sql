-- liquibase formatted sql

-- changeset jeff.pell:aws_feedback-5 endDelimiter:go runOnChange:true runAlways:true stripComments:false
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
