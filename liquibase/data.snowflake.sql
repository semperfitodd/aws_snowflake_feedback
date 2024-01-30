-- liquibase formatted sql

-- changeset jeff.pell:data-1 endDelimiter=go runOnChange:True
set constant_name        = 'purge_after_days';
set constant_value       = '30';
set constant_description = 'Purge specified data after X days';
insert into constants ( constant_name, constant_value, constant_description)
select $constant_name, $constant_value, $constant_description
where $constant_name not in (select constant_name from constants);
go

