DROP TRIGGER IF EXISTS check_quote_datetime_trigger on quotes;
DROP TRIGGER IF EXISTS check_retweet_datetime_trigger on retweets;

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

