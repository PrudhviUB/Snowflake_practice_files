//https://us-east-1.console.aws.amazon.com/s3/buckets/snowflake-datasets-prudhvi?region=us-east-1&bucketType=general

//CREATE OR REPLACE SCHEMA external_stages;

//Creating external stage
CREATE OR REPLACE STAGE MANAGE_DB.external_stages.jsonstage
    URL = "s3://snowflake-datasets-prudhvi"
    CREDENTIALS = (AWS_KEY_ID = '' 
    AWS_SECRET_KEY = '');

CREATE OR REPLACE FILE FORMAT json_file_format
    TYPE = JSON;

DESC file format json_file_format;

CREATE DATABASE OUR_FIRST_DB;

CREATE OR REPLACE table OUR_FIRST_DB.PUBLIC.JSON_RAW (
    raw_file variant
);

COPY INTO OUR_FIRST_DB.PUBLIC.JSON_RAW 
    FROM @MANAGE_DB.EXTERNAL_STAGES.jsonstage
    file_format = OUR_FIRST_DB.PUBLIC.json_file_format
    files = ('HR_data.json')

SELECT * FROM OUR_FIRST_DB.PUBLIC.JSON_RAW

SELECT $1:city::string CITY, $1:first_name::string FIRST_NAME FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT 
    RAW_FILE:id::int as id,
    RAW_FILE:first_name::string as first_name,
    RAW_FILE:last_name::string as last_name,
    RAW_FILE:gender::string as gender
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

//Extracting the nested file data
SELECT RAW_FILE:job.salary, RAW_FILE:job.title as job FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

//Extracting Arrays
SELECT RAW_FILE:prev_company[0]::string as prev_company FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT RAW_FILE:spoken_languages as spoken_languages FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

CREATE OR REPLACE TABLE Languages AS
select
    RAW_FILE:first_name::STRING as first_name,
    f.value:language::STRING language,
    f.value:level::STRING level
from OUR_FIRST_DB.PUBLIC.JSON_RAW, table(flatten(RAW_FILE:spoken_languages)) AS f

SELECT * FROM Languages;
















