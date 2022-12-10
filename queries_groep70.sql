select count(username) from users where location is not null and description is not null;
select count(distinct content) from tags where content ilike 'b%';
select count(username) from likes group by tweetid order by count desc limit 1;
select count(id) from tweets where length(content) > 140;
select count(distinct tweetid) from mentions where tweetid in (select tweetid from mentions group by tweetid having count(distinct index) >= 4);
-- todo opgave 6
select count(id) from quotes where van_tweetid = 170454;

