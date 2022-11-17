drop table if exists super_tweets;
drop table if exists super_favorites;

create table super_tweets (
    tweet_id varchar,
    tweet_tijdstip varchar,
    tweet_inhoud varchar,
    tweet_locatie varchar,
    tweet_gebruikersnaam varchar,
    gebruiker_beschrijving varchar,
    gebruiker_locatie varchar,
	quoted_tweet varchar,
    tag varchar,
    tag_volgnummer varchar,
    mention_gebruikersnaam varchar,
    mention_volgnummer varchar,
    mention_gebruiker_beschrijving varchar,
    mention_gebruiker_locatie varchar,
    retweet_tijdstip varchar,
    retweet_gebruikersnaam varchar,
    retweet_gebruiker_beschrijving varchar,
    retweet_gebruiker_locatie varchar
);

create table super_favorites (
    tweet_id varchar,
    favorite_gebruikersnaam varchar,
    favorite_gebruiker_beschrijving varchar,
    favorite_gebruiker_locatie varchar
);

-- \copy super_tweets from ../tweets_en_retweets.csv delimiter ',' csv header
-- \copy super_favorites from ../favorites.csv delimiter ',' csv header