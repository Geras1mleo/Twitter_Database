DROP TRIGGER IF EXISTS check_quote_datetime_trigger on quotes;
DROP TRIGGER IF EXISTS check_retweet_datetime_trigger on retweets;
DROP TRIGGER IF EXISTS check_mentions_count_trigger on mentions;
DROP TRIGGER IF EXISTS check_tags_count_trigger on tags;

--QUOTES
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

--RETWEETS
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

--MENTIONS
CREATE OR REPLACE FUNCTION check_mentions_count()
    RETURNS TRIGGER
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    mentions_count integer;
BEGIN
    SELECT count(parts) - 1 INTO mentions_count FROM (SELECT unnest(string_to_array(tweet.content,'@')) AS parts
        FROM tweets tweet
        WHERE tweet.id = new.tweetid) foo;

    IF mentions_count < new.index THEN
       RAISE EXCEPTION 'Mention index out of bounds';
    END IF;

    RETURN NEW;
END;
$BODY$;

CREATE TRIGGER check_mentions_count_trigger
    BEFORE INSERT
    ON mentions
    FOR EACH ROW
EXECUTE FUNCTION check_mentions_count();

--TAGS
CREATE OR REPLACE FUNCTION check_tags_count()
    RETURNS TRIGGER
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    tags_count integer;
BEGIN
    SELECT count(parts) - 1 INTO tags_count FROM (SELECT unnest(string_to_array(tweet.content,'#')) AS parts
        FROM tweets tweet
        WHERE tweet.id = new.tweetid) foo;

    IF tags_count < new.index THEN
       RAISE EXCEPTION 'Tag index out of bounds';
    END IF;

    RETURN NEW;
END;
$BODY$;

CREATE TRIGGER check_tags_count_trigger
    BEFORE INSERT
    ON tags
    FOR EACH ROW
EXECUTE FUNCTION check_tags_count();

