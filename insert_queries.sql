-- TODO remove truncates!!
truncate users cascade;
truncate tweets cascade;
truncate quotes cascade;
truncate tags cascade;
truncate mentions cascade;
truncate retweets cascade;
truncate interactions cascade;

insert into users
select distinct
    tweet_gebruikersnaam,
    gebruiker_beschrijving,
    gebruiker_locatie
from super_tweets
where 
    tweet_gebruikersnaam is not null
union
select distinct
    favorite_gebruikersnaam,
    favorite_gebruiker_beschrijving,
    favorite_gebruiker_locatie
from super_favorites
where 
    favorite_gebruikersnaam is not null
union
select distinct
    mention_gebruikersnaam,
    mention_gebruiker_beschrijving,
    mention_gebruiker_locatie
from super_tweets
where 
    mention_gebruikersnaam is not null
union
select distinct
    retweet_gebruikersnaam,
    retweet_gebruiker_beschrijving,
    retweet_gebruiker_locatie
from super_tweets
where 
    retweet_gebruikersnaam is not null;

insert into tweets
select distinct
    tweet_id::integer,
    tweet_tijdstip::timestamp,
    tweet_inhoud,
    tweet_gebruikersnaam
    tweet_locatie
from super_tweets
where 
    tweet_id is not null
    and tweet_tijdstip is not null
    and tweet_inhoud is not null
    and tweet_gebruikersnaam is not null;

insert into quotes
select distinct
    tweet_id::integer,
    quoted_tweet::integer
from super_tweets
where
    tweet_id is not null
    and quoted_tweet is not null;

insert into tags
select distinct
    tweet_id::integer,
    tag_volgnummer::integer,
    tag
from super_tweets
where 
    tweet_id is not null
    and tag_volgnummer is not null
    and tag is not null;

insert into mentions
select distinct
    tweet_id::integer,
    mention_volgnummer::integer,
    mention_gebruikersnaam
from super_tweets
where
    tweet_id is not null
    and mention_volgnummer is not null
    and mention_gebruikersnaam is not null;

insert into retweets
select distinct
    retweet_gebruikersnaam,
    tweet_id::integer,
    retweet_tijdstip::timestamp
from super_tweets
where
    tweet_id is not null
    and retweet_gebruikersnaam is not null
    and retweet_tijdstip is not null;

--insert into favorites
-- TODO interactions


