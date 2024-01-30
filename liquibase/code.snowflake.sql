-- liquibase formatted sql

-- changeset jeff.pell:code-1 endDelimiter:; runOnChange:true runAlways:false stripComments:false
CREATE FUNCTION area_of_circle(radius FLOAT)
  RETURNS FLOAT
  AS
  $$
    pi() * radius * radius
  $$
  ;

