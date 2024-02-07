-- liquibase formatted sql

-- changeset jeff.pell:data-1 endDelimiter=go runOnChange:True
use role sysadmin;
set constant_name        = 'purge_after_days';
set constant_value       = '30';
set constant_description = 'Purge specified data after X days';
insert into constants ( constant_name, constant_value, constant_description)
select $constant_name, $constant_value, $constant_description
where $constant_name not in (select constant_name from constants);
go

-- changeset jeff.pell:data-2 endDelimiter=go runOnChange:True
use role sysadmin;
set constant_name        = 'last_pipe_check';
set constant_value       = '2020-01-01';
set constant_description = 'Date copy_history was last checked';
insert into constants ( constant_name, constant_value, constant_description)
select $constant_name, $constant_value, $constant_description
where $constant_name not in (select constant_name from constants);
go

-- changeset jeff.pell:data-3 endDelimiter=go runOnChange:True
use role sysadmin;
set constant_name        = 'nodify_email';
set constant_value       = '${SNOWFLAKE_EMAILNOTFICATIONLIST}';
set constant_description = 'Email address(es) to send notifications';
insert into constants ( constant_name, constant_value, constant_description)
select $constant_name, $constant_value, $constant_description
where $constant_name not in (select constant_name from constants);
go

-- changeset jeff.pell:data-4 endDelimiter=go runOnChange:True
use role sysadmin;
set constant_name        = 'email_integration';
set constant_value       = 'sf_email_ni';
set constant_description = 'Notification integration to send email';
insert into constants ( constant_name, constant_value, constant_description)
select $constant_name, $constant_value, $constant_description
where $constant_name not in (select constant_name from constants);
go

