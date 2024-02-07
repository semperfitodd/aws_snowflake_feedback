-- liquibase formatted sql

-- changeset jeff.pell:task-1 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create task if not exists POC_01.PUBLIC.MONITOR_COPY_ERRORS
	warehouse=POC_01_WH
	schedule='15 minute'
	as call poc_01.public.monitor_copy_errors();
alter task  POC_01.PUBLIC.MONITOR_COPY_ERRORS resume;
