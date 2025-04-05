CREATE OR REPLACE DATABASE SPOTIFY;
CREATE OR REPLACE SCHEMA SPOTIFYSCHEMA;

CREATE OR REPLACE TABLE SPOTIFY.SPOTIFYSCHEMA.tblAlbum (
    albumid STRING PRIMARY KEY,
    name STRING,
    release_date DATE,
    total_tracks INT,
    url STRING
);

CREATE OR REPLACE TABLE SPOTIFY.SPOTIFYSCHEMA.tblArtist (
    artist_id STRING PRIMARY KEY,
    artist_name STRING,
    external_url STRING
);

CREATE OR REPLACE TABLE SPOTIFY.SPOTIFYSCHEMA.tblSongs (
    song_id STRING PRIMARY KEY,
    Song_name STRING,
    duration_ms INT,
    url STRING,
    popularity INT,
    song_added TIMESTAMP_LTZ,
    album_id STRING
);

--fileformat
CREATE OR REPLACE file format SPOTIFY.SPOTIFYSCHEMA.csv_file_format
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL', 'null')
    empty_field_as_null = TRUE;

--storage integration
--first create a role with external id 00000 and s3 full access in aws
--now create a storage integration in snowflake by getting the arn from the aws role and the bucket name from s3
CREATE OR REPLACE storage integration s3_init
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = S3
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::*****:role/Snowflake-s3-connection'
    STORAGE_ALLOWED_LOCATIONS = ('s3://spotify-etl-pipeline-prudhvi')
    COMMENT = 'Creating s3 connection to spotify folder'

--now copy the user arn vale and external id from below command description and put them in the aws role trust policy
DESC integration s3_init

--stage
CREATE OR REPLACE STAGE SPOTIFY.SPOTIFYSCHEMA.albumstage
    URL = "s3://spotify-etl-pipeline-prudhvi/transformed_data/album_data/"
    STORAGE_INTEGRATION = s3_init
    FILE_FORMAT = SPOTIFY.SPOTIFYSCHEMA.csv_file_format


CREATE OR REPLACE STAGE SPOTIFY.SPOTIFYSCHEMA.artiststage
    URL = "s3://spotify-etl-pipeline-prudhvi/transformed_data/artist_data/"
    STORAGE_INTEGRATION = s3_init
    FILE_FORMAT = SPOTIFY.SPOTIFYSCHEMA.csv_file_format


CREATE OR REPLACE STAGE SPOTIFY.SPOTIFYSCHEMA.songstage
    URL = "s3://spotify-etl-pipeline-prudhvi/transformed_data/songs_data/"
    STORAGE_INTEGRATION = s3_init
    FILE_FORMAT = SPOTIFY.SPOTIFYSCHEMA.csv_file_format

    
CREATE OR REPLACE SCHEMA SPOTIFY.pipes
--pipes
CREATE OR REPLACE pipe SPOTIFY.pipes.album_pipe
auto_ingest = TRUE
AS
COPY INTO SPOTIFY.SPOTIFYSCHEMA.tblAlbum
FROM @SPOTIFY.SPOTIFYSCHEMA.albumstage


CREATE OR REPLACE pipe SPOTIFY.pipes.artist_pipe
auto_ingest = TRUE
AS
COPY INTO SPOTIFY.SPOTIFYSCHEMA.tblArtist
FROM @SPOTIFY.SPOTIFYSCHEMA.artiststage

CREATE OR REPLACE pipe SPOTIFY.pipes.songs_pipe
auto_ingest = TRUE
AS
COPY INTO SPOTIFY.SPOTIFYSCHEMA.tblSongs
FROM @SPOTIFY.SPOTIFYSCHEMA.songstage

--event in s3
DESC pipe SPOTIFY.pipes.album_pipe
DESC pipe SPOTIFY.pipes.artist_pipe
DESC pipe SPOTIFY.pipes.songs_pipe

--Query
SELECT * FROM SPOTIFY.SPOTIFYSCHEMA.tblSongs;



















