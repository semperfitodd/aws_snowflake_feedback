-- liquibase formatted sql

-- changeset jeff.pell:monitor-1 endDelimiter:go runOnChange:true runAlways:false stripComments:false
use role accountadmin;
create or replace resource monitor daily_max_credit
with credit_quota = 3
frequency = daily
start_timestamp = immediately
TRIGGERS ON 50 PERCENT DO NOTIFY
         on 75 PERCENT DO SUSPEND
         on 95 PERCENT DO SUSPEND_IMMEDIATE;

-- changeset jeff.pell:monitor-2 endDelimiter:go runOnChange:true runAlways:false stripComments:false
use role sysadmin;
CREATE OR REPLACE PROCEDURE POC_01.PUBLIC.MONITOR_COPY_ERRORS()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS OWNER
AS 'declare
  pipe_name            varchar(100);
  file_name            varchar(100);
  stage_location       varchar(250);
  first_error_message  varchar(1000);
  last_load_time       varchar(100);
  email_subject        varchar(100);
  email_body           varchar(25000);
  send_email_SQL       varchar(25000);
  email_address        varchar(1000);
  notification_integration varchar(50);
  last_check_date          varchar(50);
  return_value             varchar(50);
  reccount                 int;
  first_error_date         varchar(50);
begin
  return_value := ''No error encountered'';
  select constant_value into :email_address from poc_01.public.constants where constant_name=''nodify_email'';
  select constant_value into :notification_integration from poc_01.public.constants where constant_name=''email_integration'';
  select constant_value into :last_check_date from poc_01.public.constants where constant_name=''last_pipe_check'';
  
  select count(1) as reccount, max(last_load_time) as last_check_date, min(last_load_time) as first_error_date,
         listagg((pipe_name ||chr(10) || file_name || chr(10) || stage_location ||chr(10) || first_error_message || chr(10) ||  last_load_time), '''' ) within group (order by first_error_message desc) as files_with_errors
  into :reccount, :last_check_date, :first_error_date, :email_body
  from snowflake.account_usage.copy_history 
  where error_count>0
  and last_load_time > :last_check_date
  order by last_load_time desc;

  
  if (:reccount > 0) then
  begin
    return_value  := ''Error encountered'';
    email_subject := ''Error(s) in SnowPipe'';

    if (:reccount > 1) then
    begin
      email_body := ''Total of '' || reccount::text || '' errors occurred between '' || :first_error_date || '' and '' || :last_check_date || ''.   Please review Snowflake logs for details.'';
    end;
    end if;
    
    send_email_SQL := ''CALL SYSTEM$SEND_EMAIL(''''''||:notification_integration||'''''',''''''||:email_address||'''''',''''''||:email_subject||'''''',''''''||:email_body||'''''')'';
    execute immediate send_email_SQL;

    update poc_01.public.constants
    set    constant_value = :last_check_date
    where  constant_name = ''last_pipe_check'';
  end;
  end if;
  return :return_value;
end';
go

