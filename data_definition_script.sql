DROP TABLE IF EXISTS USERS CASCADE;
DROP TABLE IF EXISTS TWEETS CASCADE;
DROP TABLE IF EXISTS QUOTES CASCADE;
DROP TABLE IF EXISTS TAGS CASCADE;
DROP TABLE IF EXISTS MENTIONS CASCADE;
DROP TABLE IF EXISTS RETWEETS CASCADE;
DROP TABLE IF EXISTS LIKES CASCADE;

DROP TRIGGER IF EXISTS check_quote_datetime_trigger on quotes;
DROP TRIGGER IF EXISTS check_retweet_datetime_trigger on retweets;

CREATE TABLE USERS (
    username varchar,
    location varchar,
    description varchar,

    PRIMARY KEY (username),
    CHECK (POSITION('@' in username) <= 0)
);

CREATE TABLE TWEETS (
    ID integer,
    datetime timestamp NOT NULL,
    content varchar NOT NULL,
    postedby varchar NOT NULL,
    location varchar,

    PRIMARY KEY (ID),
    CHECK (datetime <= now())
);

CREATE TABLE QUOTES (
    ID integer,
    van_tweetID integer NOT NULL,

    PRIMARY KEY (ID),
    CHECK (ID <> van_tweetID)
);

CREATE TABLE MENTIONS (
    tweetID integer,
    index integer ,
    username varchar NOT NULL,

    PRIMARY KEY (tweetID, index),
    CHECK (index >= 1)
);

CREATE TABLE TAGS (
    tweetID integer,
    index integer,
    content varchar NOT NULL,

    PRIMARY KEY (tweetID, index),
    CHECK (index >= 1),
    CHECK (POSITION('#' in content) <= 0)
);

CREATE TABLE LIKES (
    tweetID integer,
    username varchar,
    
    PRIMARY KEY (tweetID, username)
);

CREATE TABLE RETWEETS (
    tweetID integer,
    username varchar,
    datetime timestamp NOT NULL,
    
    PRIMARY KEY (tweetID, username)
);

ALTER TABLE TWEETS ADD CONSTRAINT postedby_fk FOREIGN KEY (postedby) REFERENCES USERS (username);
ALTER TABLE QUOTES ADD CONSTRAINT ID_fk FOREIGN KEY (ID) REFERENCES TWEETS (ID);
ALTER TABLE QUOTES ADD CONSTRAINT quotes_van_tweetID_fk FOREIGN KEY (van_tweetID) REFERENCES TWEETS (ID);

ALTER TABLE MENTIONS ADD CONSTRAINT mentions_tweetID_fk FOREIGN KEY (tweetID) REFERENCES TWEETS (ID);
ALTER TABLE MENTIONS ADD CONSTRAINT mentions_username_fk FOREIGN KEY (username) REFERENCES USERS (username);

ALTER TABLE TAGS ADD CONSTRAINT  tags_tweetID_fk FOREIGN KEY (tweetID) REFERENCES TWEETS (ID);

ALTER TABLE LIKES ADD CONSTRAINT likes_usrname_fk FOREIGN KEY (username) REFERENCES USERS (username);
ALTER TABLE LIKES ADD CONSTRAINT likes_tweetID_fk FOREIGN KEY (tweetID) REFERENCES TWEETS (ID);

ALTER TABLE RETWEETS ADD CONSTRAINT retweets_username_fk FOREIGN KEY (username) REFERENCES USERS (username);
ALTER TABLE RETWEETS ADD CONSTRAINT retweets_tweetID_dk FOREIGN KEY (tweetID) REFERENCES TWEETS (ID);

CREATE OR REPLACE FUNCTION check_quote_datetime()
    RETURNS TRIGGER 
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    is_valid_datetime boolean;
BEGIN
    SELECT quoted_tweet.datetime <= quote.datetime INTO is_valid_datetime
    FROM tweets quote
    INNER JOIN tweets quoted_tweet ON new.van_tweetid = quoted_tweet.id
    WHERE new.id = quote.id;

    IF NOT is_valid_datetime THEN
       RAISE EXCEPTION 'Quote datetime cannot come before quoted tweet';
    END IF;

    RETURN NEW;
END;
$BODY$;

CREATE TRIGGER check_quote_datetime_trigger
    BEFORE INSERT
    ON quotes
    FOR EACH ROW
EXECUTE FUNCTION check_quote_datetime();

CREATE OR REPLACE FUNCTION check_retweet_datetime()
    RETURNS TRIGGER
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    is_valid_datetime boolean;
BEGIN
    SELECT tweet.datetime <= NEW.datetime INTO is_valid_datetime
    FROM tweets tweet
    WHERE tweet.id = new.tweetid;

    IF NOT is_valid_datetime THEN
       RAISE EXCEPTION 'Retweet datetime cannot be earlier then original tweet datetime';
    END IF;

    RETURN NEW;
END;
$BODY$;

CREATE TRIGGER check_retweet_datetime_trigger
    BEFORE INSERT
    ON retweets
    FOR EACH ROW
EXECUTE FUNCTION check_retweet_datetime();


