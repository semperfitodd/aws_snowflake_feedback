-- liquibase formatted sql

-- changeset jeff.pell:permission-1
use role accountadmin;
grant usage on  integration AWS_S3_EMAILS to role sysadmin; 


