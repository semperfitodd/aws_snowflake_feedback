-- liquibase formatted sql

-- changeset jeff.pell:permission-1
use role accountadmin;
grant usage on  integration AWS_S3_EMAILS to role sysadmin; 


-- changeset jeff.pell:permission-2
use role accountadmin;
GRANT USAGE ON INTEGRATION sf_email_ni TO ROLE sysadmin;

-- changeset jeff.pell:permission-3
use role accountadmin;
create role if not exists report_role;

-- changeset jeff.pell:permission-4
use role accountadmin;
grant usage on database poc_01 to role report_role;

-- changeset jeff.pell:permission-5
use role accountadmin;
grant usage on schema poc_01.public to role report_role;

-- changeset jeff.pell:permission-6
use role accountadmin;
grant usage on warehouse report_role_wh to role report_role;

-- changeset jeff.pell:permission-7
use role accountadmin;
grant select on view poc_01.public.v_feedback_source to role report_role;
grant select on view poc_01.public.v_date_range to role report_role;
grant select on view poc_01.public.v_feedback_overview to role report_role;
grant select on view poc_01.public.mv_all_feedback to role report_role;
grant select on view poc_01.public.v_overall_attributes to role report_role;
grant select on view poc_01.public.v_feedback_overview_by_period to role report_role;
grant select on view poc_01.public.v_feedback_with_keyword to role report_role;
grant select on view poc_01.public.v_feedback_with_keyword_by_period to role report_role;
grant select on view poc_01.public.v_feedback_overview_today to role report_role;
grant select on view poc_01.public.v_feedback_with_keyword_today to role report_role;

-- changeset jeff.pell:permission-8
use role accountadmin;
create user if not exists report_display
   password = '${SNOWFLAKE_REPORT_USER_PASSWORD}'
   login_name ='report_display'
   default_warehouse = report_role_wh
   default_namespace = poc_01
   default_role = report_role
   comment = 'User to access data for reporting only.';

-- changeset jeff.pell:permission-9
use role accountadmin;
grant role report_role to user report_display;

-- changeset jeff.pell:permission-10
use role accountadmin;
grant execute task on account to role sysadmin;

