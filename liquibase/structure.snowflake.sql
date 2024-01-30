-- liquibase formatted sql

-- changeset jeff.pell:structure-1
CREATE TABLE constants (constant_name varchar(100), constant_value varchar(500), constant_description varchar(500));

-- changeset jeff.pell:structure-2  runOnChange:true runAlways:false stripComments:false
create or replace file format ff_sample_csv_pipe
type = CSV
SKIP_HEADER = 1
FIELD_DELIMITER = '|'
FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- changeset jeff.pell:structure-3  runOnChange:true runAlways:false stripComments:false
create or replace view v_all_feedback
as
select $1::timestamp as date_created, $2 as originating_email_address, $3 as email_subject, $4 as email_body, $5 as feedback, $6 as keywords
from @poc_01.public.aws_s3_emails
(file_format => 'ff_sample_csv_pipe')
;


-- changeset jeff.pell:structure-4  runOnChange:true runAlways:false stripComments:false
create or replace view v_feedback_overview
as
select $5 as feedback, count(1) as reccount 
from @poc_01.public.aws_s3_emails
(file_format => 'ff_sample_csv_pipe')
group by feedback;

-- changeset jeff.pell:structure-5  runOnChange:true runAlways:false stripComments:false
create or replace view v_date_range
as
select min(date_created) date_created_min, max(date_created) date_created_max
from (
select $1::timestamp as date_created
from @poc_01.public.aws_s3_emails
(file_format => 'ff_sample_csv_pipe')
) interim01;


-- changeset jeff.pell:structure-6  runOnChange:true runAlways:false stripComments:false
create or replace view v_feedback_source
as
select $2 as originating_email, count(1) as reccount 
from @poc_01.public.aws_s3_emails
(file_format => 'ff_sample_csv_pipe')
group by originating_email;
