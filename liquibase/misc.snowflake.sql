-- liquibase formatted sql

-- changeset jeff.pell:misc-4 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace pipe POC_01.PUBLIC.AWS_S3_EMAILS_JSON 
auto_ingest=true 
as 
  copy into poc_01.public.json_email (email_info)
  from @poc_01.public.AWS_S3_EMAILS
  pattern = '.*[.]json'
  FILE_FORMAT =  (format_name = 'poc_01.public.ff_sample_json');

