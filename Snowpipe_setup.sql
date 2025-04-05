//create table first
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.employees (
    id INT,
    first_name STRING,
    last_name STRING,
    email STRING,
    location STRING,
    department STRING
)

//create file format object
CREATE OR REPLACE file format OUR_FIRST_DB.PUBLIC.csv_file_format
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL', 'null')
    empty_field_as_null = TRUE;


CREATE OR REPLACE STAGE MANAGE_DB.external_stages.spstage
    URL = "s3://snowflake-datasets-prudhvi/snowpipe/"
    CREDENTIALS = (AWS_KEY_ID = '' 
    AWS_SECRET_KEY = '')
    FILE_FORMAT = OUR_FIRST_DB.PUBLIC.csv_file_format

//create schema to keep things organized 
CREATE OR REPLACE SCHEMA MANAGE_DB.pipes

CREATE OR REPLACE pipe MANAGE_DB.pipes.employee_pipe
auto_ingest = TRUE
AS
COPY INTO OUR_FIRST_DB.PUBLIC.employees
FROM @MANAGE_DB.external_stages.spstage

DESC pipe MANAGE_DB.pipes.employee_pipe
//from the above result copy the notification channel arn address and use that in a create event in the s3 bucket


SELECT * FROM OUR_FIRST_DB.PUBLIC.employees

SHOW PIPES;
















