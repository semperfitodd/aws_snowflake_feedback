-- liquibase formatted sql

-- changeset jeff.pell:structure-1
use role sysadmin;
CREATE TABLE constants (constant_name varchar(100), constant_value varchar(500), constant_description varchar(500));

-- changeset jeff.pell:structure-2  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace file format ff_sample_csv_pipe
type = CSV
SKIP_HEADER = 1
FIELD_DELIMITER = '|'
FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- changeset jeff.pell:structure-3  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace view v_all_feedback
as
select $1::timestamp as date_created, $2 as originating_email_address, $3 as email_subject, $4 as email_body, $5 as feedback, $6 as keywords
from @poc_01.public.aws_s3_emails
(file_format => 'ff_sample_csv_pipe')
;


-- changeset jeff.pell:structure-4  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace view v_feedback_overview
as
select $5 as feedback, count(1) as reccount 
from @poc_01.public.aws_s3_emails
(file_format => 'ff_sample_csv_pipe')
group by feedback;

-- changeset jeff.pell:structure-5  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace view v_date_range
as
select min(date_created) date_created_min, max(date_created) date_created_max
from (
select $1::timestamp as date_created
from @poc_01.public.aws_s3_emails
(file_format => 'ff_sample_csv_pipe')
) interim01;


-- changeset jeff.pell:structure-6  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace view v_feedback_source
as
select $2 as originating_email, count(1) as reccount 
from @poc_01.public.aws_s3_emails
(file_format => 'ff_sample_csv_pipe')
group by originating_email;


-- changeset jeff.pell:structure-7  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace TABLE POC_01.PUBLIC.JSON_EMAIL (
	EMAIL_INFO VARIANT,
	DATE_LOADED TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP()
);


-- changeset jeff.pell:structure-8  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace view POC_01.PUBLIC.MV_ALL_FEEDBACK(
	DATE_CREATED,
	ORIGINATING_EMAIL_ADDRESS,
	EMAIL_SUBJECT,
	EMAIL_BODY,
	FEEDBACK,
	KEYWORDS
) as
select email_info:received_datetime::datetime as date_created, 
       email_info:sender::text  as originating_email_address, 
       email_info:subject::text as email_subject, 
       email_info:body::text as email_body, 
       email_info:sentiment::text as feedback, 
       email_info:keyPhrases::text as keywords
from poc_01.public.json_email
;

-- changeset jeff.pell:structure-9  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace view POC_01.PUBLIC.V_DATE_RANGE(
	DATE_CREATED_MIN,
	DATE_CREATED_MAX
) as
select min(date_created) date_created_min, max(date_created) date_created_max
from (
select date_created
from poc_01.public.mv_all_feedback
) interim01;

-- changeset jeff.pell:structure-10  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace view POC_01.PUBLIC.V_FEEDBACK_OVERVIEW(
	FEEDBACK,
	RECCOUNT
) as
select feedback, count(1) as reccount 
from poc_01.public.mv_all_feedback
group by feedback
order by feedback;

-- changeset jeff.pell:code-2 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
CREATE OR REPLACE FUNCTION POC_01.PUBLIC.DATE_DIFF_MINUTES()
RETURNS NUMBER(24,6)
LANGUAGE SQL
AS '
select datediff(''minute'',min(date_created), max(date_created))/2
from poc_01.public.mv_all_feedback
';

-- changeset jeff.pell:code-3 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
CREATE OR REPLACE FUNCTION POC_01.PUBLIC.DATE_SPLIT()
RETURNS TIMESTAMP_NTZ(9)
LANGUAGE SQL
AS '
select dateadd(''minute'', POC_01.PUBLIC.DATE_DIFF_MINUTES(), min(date_created))
from poc_01.public.mv_all_feedback
';

-- changeset jeff.pell:structure-11  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace view POC_01.PUBLIC.V_FEEDBACK_OVERVIEW_BY_PERIOD(
	PERIOD,
	FEEDBACK,
	RECCOUNT
) as
select 'Previous period' as period, feedback, count(1) as reccount from mv_all_feedback where date_created<POC_01.PUBLIC.DATE_SPLIT() group by feedback
union
select 'Current period' as period,feedback, count(1) as reccount from mv_all_feedback where date_created>=POC_01.PUBLIC.DATE_SPLIT() group by feedback
order by period, feedback
;

-- changeset jeff.pell:structure-12  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace view POC_01.PUBLIC.V_FEEDBACK_OVERVIEW_TODAY(
	PERIOD,
	FEEDBACK,
	RECCOUNT
) as
select 'Previous period' as period, feedback, count(1) as reccount from mv_all_feedback 
where convert_timezone('UTC','America/New_York',timestampadd('hour',2,date_created)) > current_date()
group by feedback;

-- changeset jeff.pell:structure-13  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace view POC_01.PUBLIC.V_FEEDBACK_SOURCE(
	ORIGINATING_EMAIL_ADDRESS,
	RECCOUNT
) as
select originating_email_address, count(1) as reccount 
from poc_01.public.mv_all_feedback
group by originating_email_address;

-- changeset jeff.pell:structure-14  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace view POC_01.PUBLIC.V_FEEDBACK_WITH_KEYWORD(
	FEEDBACK,
	RECCOUNT,
	KEYWORD_LIST
) as
select feedback, reccount,  listagg(keyword, ', ') as keyword_list from (
select feedback, s.value::string as keyword, count(1) as reccount , rank() over (partition by feedback order by reccount desc) as rank_val
from mv_all_feedback, lateral flatten(input=>split(keywords,'.')) s 
group by feedback, keyword
--having count(1)>5
) interim01 
where rank_val <= 5
group by feedback, reccount
order by feedback, reccount desc;

-- changeset jeff.pell:structure-15  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace view POC_01.PUBLIC.V_FEEDBACK_WITH_KEYWORD_BY_PERIOD(
	PERIOD,
	FEEDBACK,
	RECCOUNT,
	KEYWORD_LIST
) as
select period, feedback, reccount,  listagg(keyword, ', ') as keyword_list from (
select 'Previous period' as period, feedback, s.value::string as keyword, count(1) as reccount , rank() over (partition by feedback order by reccount desc) as rank_val
from mv_all_feedback, lateral flatten(input=>split(keywords,'.')) s 
where date_created<POC_01.PUBLIC.DATE_SPLIT() 
group by feedback, keyword
union 
select 'Current period' as period, feedback, s.value::string as keyword, count(1) as reccount , rank() over (partition by feedback order by reccount desc) as rank_val
from mv_all_feedback, lateral flatten(input=>split(keywords,'.')) s 
where date_created>=POC_01.PUBLIC.DATE_SPLIT() 
group by feedback, keyword
) interim01 
where rank_val <= 5
group by period, feedback, reccount
order by period, feedback, reccount desc;

-- changeset jeff.pell:structure-16  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace view POC_01.PUBLIC.V_FEEDBACK_WITH_KEYWORD_TODAY(
	PERIOD,
	FEEDBACK,
	RECCOUNT,
	KEYWORD_LIST
) as
select period, feedback, reccount,  listagg(keyword, ', ') as keyword_list from (
select 'Previous period' as period, feedback, s.value::string as keyword, count(1) as reccount , rank() over (partition by feedback order by reccount desc) as rank_val
from mv_all_feedback, lateral flatten(input=>split(keywords,'.')) s 
where convert_timezone('UTC','America/New_York',timestampadd('hour',2,date_created))>=current_date() 
group by feedback, keyword
) interim01 
where rank_val <= 5
group by period, feedback, reccount
order by period, feedback, reccount desc;

-- changeset jeff.pell:structure-17  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace view POC_01.PUBLIC.V_OVERALL_ATTRIBUTES(
	ATTRIBUTE,
	VALUE
) as
select 'Latest date' as attribute, max(date_created)::text as value from poc_01.public.mv_all_feedback
union
select 'Oldest date' as attribute, min(date_created)::text as value from poc_01.public.mv_all_feedback
union
select 'Total responses' as attribute, count(1)::text as value from poc_01.public.mv_all_feedback;

-- changeset jeff.pell:structure-18  runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create or replace file format ff_sample_json
type = JSON
strip_outer_array = TRUE;


-- changeset jeff.pell:structure-19  runOnChange:true runAlways:false stripComments:false
drop view if exists POC_01.PUBLIC.MV_ALL_FEEDBACK;


-- changeset jeff.pell:structure-20  runOnChange:true runAlways:false stripComments:false
create materialized view if not exists POC_01.PUBLIC.MV_ALL_FEEDBACK(
	DATE_CREATED,
	ORIGINATING_EMAIL_ADDRESS,
	EMAIL_SUBJECT,
	EMAIL_BODY,
	FEEDBACK,
	KEYWORDS
) as
select email_info:received_datetime::datetime as date_created,
       email_info:sender::text  as originating_email_address,
       email_info:subject::text as email_subject,
       email_info:body::text as email_body,
       email_info:sentiment::text as feedback,
       email_info:keyPhrases::text as keywords
from poc_01.public.json_email;

