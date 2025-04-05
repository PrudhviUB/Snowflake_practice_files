CREATE OR REPLACE DATABASE MANAGE_DB;

CREATE OR REPLACE SCHEMA external_stages;

//Creating external stage
CREATE STAGE MANAGE_DB.external_stages.aws_stage
    URL = "s3://project-instacart/Instacart/"
    CREDENTIALS = (AWS_KEY_ID = '' 
    AWS_SECRET_KEY = '');

//Description of External stage
DESC STAGE MANAGE_DB.external_stages.aws_stage;

//Alter external stage
ALTER STAGE aws_stage
    SET credentials = (aws_key_id = 'dummy id' aws_secret_key='dummy key'); 

//To access publicly available bucket
CREATE OR REPLACE STAGE MANAGE_DB.external_stages.aws_stage
    url='s3://bucketsnowflakes3';

//To see the files in the above bucket
LIST @aws_stage;

//Creating orders tables
CREATE OR REPLACE TABLE MANAGE_DB.PUBLIC.ORDERS ( //inside the pubic schema we are creating orders table
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

//COPY DATA FROM THE OrderDetails.csv in the publicly available storage to the orders table
COPY INTO MANAGE_DB.PUBLIC.ORDERS
FROM @aws_stage
file_format = (type = csv field_delimiter=',' skip_header=1)
files=('OrderDetails.csv')

//Query the table
SELECT * FROM MANAGE_DB.PUBLIC.orders

//CREATEING ORDERS_EX TABLE
CREATE OR REPLACE TABLE MANAGE_DB.PUBLIC.ORDERS_EX ( 
    ORDER_ID VARCHAR(30),
    AMOUNT INT)

COPY INTO MANAGE_DB.PUBLIC.ORDERS_EX
FROM (SELECT s.$1, s.$2 FROM @MANAGE_DB.external_stages.aws_stage AS s)
file_format = (type = csv field_delimiter=',' skip_header=1)
files=('OrderDetails.csv');

SELECT * FROM MANAGE_DB.PUBLIC.ORDERS_EX
