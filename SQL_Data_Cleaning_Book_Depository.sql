/* 
 * 
 *  Data cleaning, formatting, normalizing
 * 
 */

--- Formatting dates and populating the table with converted dates


select *
from "Books_1".book_depository
order by title, author

ALTER DATABASE "Books" SET datestyle TO "ISO, MDY";

alter table "Books_1".book_depository
add column publish_date_converted date

select publishdate, to_date(to_char(to_date(publishdate, 'Month DDth YYYY'), 'MM/DD/YYYY'),'MM/DD/YYYY') as publish_date_converted
from "Books_1".book_depository
where publishdate like 'January%' 
	or publishdate like 'February%'
	or publishdate like 'March%'
	or publishdate like 'April%'
	or publishdate like 'May%'
	or publishdate like 'June%' 
	or publishdate like 'July%'
	or publishdate like 'August%'
	or publishdate like 'September%'
	or publishdate like 'October%'
	or publishdate like 'November%'
	or publishdate like 'December%'

	
update "Books_1".book_depository
set publish_date_converted = to_date(to_char(to_date(publishdate, 'Month DDth YYYY'), 'MM/DD/YYYY'),'MM/DD/YYYY')
where publishdate like 'January%' 
	or publishdate like 'February%'
	or publishdate like 'March%'
	or publishdate like 'April%'
	or publishdate like 'May%'
	or publishdate like 'June%' 
	or publishdate like 'July%'
	or publishdate like 'August%'
	or publishdate like 'September%'
	or publishdate like 'October%'
	or publishdate like 'November%'
	or publishdate like 'December%';

	
select publishdate, to_date(to_char(to_date(publishdate, 'MON-YY'), 'MM/DD/YYYY'),'MM/DD/YYYY') as publish_date_converted
from "Books_1".book_depository
where publishdate like 'Jan-%' 
	or publishdate like 'Feb-%'
	or publishdate like 'Mar-%'
	or publishdate like 'Apr-%'
	or publishdate like 'May-%'
	or publishdate like 'Jun-%' 
	or publishdate like 'Jul-%'
	or publishdate like 'Aug-%'
	or publishdate like 'Sep-%'
	or publishdate like 'Oct-%'
	or publishdate like 'Nov-%'
	or publishdate like 'Dec-%';

update "Books_1".book_depository
set publish_date_converted = to_date(to_char(to_date(publishdate, 'MON-YY'), 'MM/DD/YYYY'),'MM/DD/YYYY')
where publishdate like 'Jan-%' 
	or publishdate like 'Feb-%'
	or publishdate like 'Mar-%'
	or publishdate like 'Apr-%'
	or publishdate like 'May-%'
	or publishdate like 'Jun-%' 
	or publishdate like 'Jul-%'
	or publishdate like 'Aug-%'
	or publishdate like 'Sep-%'
	or publishdate like 'Oct-%'
	or publishdate like 'Nov-%'
	or publishdate like 'Dec-%';

select publishdate, to_date(publishdate, 'YYYY') as publish_date_converted
from "Books_1".book_depository
where publishdate like '____'

update "Books_1".book_depository
set publish_date_converted = to_date(publishdate, 'YYYY')
where publishdate like '____'


--- Seeking and deleting improper date column entries


select publishdate
from "Books_1".book_depository
where publishdate = 'Published'

select nullif(publishdate, 'Published')
from "Books_1".book_depository
	
update "Books_1".book_depository
set publishdate = nullif(publishdate, 'Published')
where publishdate = 'Published' and publishdate is not null;

select publishdate, publish_date_converted 
from "Books_1".book_depository
where publishdate like '%ost%'

delete from "Books_1".book_depository
where publishdate like '%ost%'

select publishdate, publish_date_converted 
from "Books_1".book_depository
where publishdate like '%voter%'

delete from "Books_1".book_depository
where publishdate like '%voter%'


--- Rounding the price [Documentation missing - Currency unknown, US $ presumed]


alter table "Books_1".book_depository
add column price_rounded float

update "Books_1".book_depository
set price_rounded = ROUND(CAST(price as NUMERIC), 2)


--- Rounding rating to second decimal point


alter table "Books_1".book_depository
add column rating_rounded float

update "Books_1".book_depository
set rating_rounded = ROUND(CAST(rating as NUMERIC), 2)



--- Cleaning, formatting 'author' column


select author
from "Books_1".book_depository
where author like '%(%)%'

select author, regexp_replace(author, '\([^()]*\)', '', 'g') AS author_clean
from "Books_1".book_depository;

alter table "Books_1".book_depository
add column author_clean text

update "Books_1".book_depository 
set author_clean = regexp_replace(author, '\([^()]*\)', '', 'g')


--- Querying for duplicates - Removing duplicates


with duplicate as (
select author_clean, 
	publisher, 
	pages, 
	language, 
	series, 
	title, 
	publish_date_converted, 
	numratings,
	row_number() over(partition by author_clean, publisher, language, series, pages, publish_date_converted,  title, numratings) as duplicate_num
from "Books_1".book_depository
)
select * from duplicate
where duplicate_num > 1

WITH duplicate AS (
  SELECT author_clean, 
         publisher, 
         pages, 
         language, 
         series, 
         title, 
         publish_date_converted, 
         numratings,
         ROW_NUMBER() OVER(PARTITION BY author_clean, publisher, language, series, publish_date_converted, pages,  title, numratings) AS duplicate_num
  FROM "Books_1".book_depository
)
DELETE FROM "Books_1".book_depository
USING duplicate
WHERE "Books_1".book_depository.author_clean = duplicate.author_clean 
  AND "Books_1".book_depository.publisher = duplicate.publisher 
  AND "Books_1".book_depository.pages = duplicate.pages 
  AND "Books_1".book_depository.language = duplicate.language 
  AND "Books_1".book_depository.series = duplicate.series 
  AND "Books_1".book_depository.title = duplicate.title 
  AND "Books_1".book_depository.publish_date_converted = duplicate.publish_date_converted 
  AND "Books_1".book_depository.numratings = duplicate.numratings 
  AND duplicate.duplicate_num > 1;
 
 
 --- Splitting 'ratingsbystars' into [5] columns, each representing the number of star reviews
 
 
 select ratingsbystars
 from "Books_1".book_depository

alter table "Books_1".book_depository
add column five_stars int
add column four_stars int,
add column three_stars int,
add column two_stars int,
add column one_stars int

select ratingsbystars, regexp_replace(ratingsbystars, '[^0-9,]', '', 'g') as ratings_cleaned
from "Books_1".book_depository

alter table "Books_1".book_depository
add column ratings_cleaned text

update "Books_1".book_depository
set ratings_cleaned = regexp_replace(ratingsbystars, '[^0-9,]', '', 'g')


UPDATE "Books_1".book_depository
SET
  five_stars = CASE WHEN (string_to_array(ratings_cleaned, ',')::int[])[1] IS NOT NULL THEN (string_to_array(ratings_cleaned, ',')::int[])[1] ELSE 0 END,
  four_stars = CASE WHEN (string_to_array(ratings_cleaned, ',')::int[])[2] IS NOT NULL THEN (string_to_array(ratings_cleaned, ',')::int[])[2] ELSE 0 END,
  three_stars = CASE WHEN (string_to_array(ratings_cleaned, ',')::int[])[3] IS NOT NULL THEN (string_to_array(ratings_cleaned, ',')::int[])[3] ELSE 0 END,
  two_stars = CASE WHEN (string_to_array(ratings_cleaned, ',')::int[])[4] IS NOT NULL THEN (string_to_array(ratings_cleaned, ',')::int[])[4] ELSE 0 END,
  one_stars = CASE WHEN (string_to_array(ratings_cleaned, ',')::int[])[5] IS NOT NULL THEN (string_to_array(ratings_cleaned, ',')::int[])[5] ELSE 0 END;


--- Scrubbing 'setting' column of special characters
 
 
SELECT setting,
  CASE 
    WHEN setting <> '' THEN regexp_replace(setting, '[\[\]\'']', '', 'g')
    ELSE NULL 
  END
FROM "Books_1".book_depository;

alter table "Books_1".book_depository
add column settings_cleaned text

update "Books_1".book_depository
set settings_cleaned = CASE WHEN setting <> '' THEN regexp_replace(setting, '[\[\]\'']', '', 'g') ELSE NULL 
END


--- Scrubbing 'awards' column of special characters


SELECT awards,
    CASE 
    WHEN awards <> '' THEN TRIM(regexp_replace(awards, '[\[\]\'']', '', 'g'))
    ELSE NULL 
  END
FROM "Books_1".book_depository;

alter table "Books_1".book_depository
add column awards_cleaned text

update "Books_1".book_depository 
set awards_cleaned = CASE 
    WHEN awards <> '' THEN TRIM(regexp_replace(awards, '[\[\]\'']', '', 'g'))
    ELSE NULL 
  END

  
--- Scrubbing 'genres' column of special characters


SELECT genres,
  CASE 
    WHEN genres <> '' THEN TRIM(regexp_replace(genres, '[\[\]\'']', '', 'g'))
    ELSE NULL 
  END
FROM "Books_1".book_depository;

alter table "Books_1".book_depository
add column genres_cleaned text

update "Books_1".book_depository 
set genres_cleaned = CASE 
    WHEN genres <> '' THEN TRIM(regexp_replace(genres, '[\[\]\'']', '', 'g'))
    ELSE NULL 
  END

--- Scrubbing 'characters' column of special characters


SELECT characters,
  CASE 
    WHEN characters <> '' THEN TRIM(regexp_replace(characters, '[\[\]\'']', '', 'g'))
    ELSE NULL 
  END
FROM "Books_1".book_depository;

alter table "Books_1".book_depository
add column characters_cleaned text

update "Books_1".book_depository 
set characters_cleaned = CASE 
    WHEN characters <> '' THEN TRIM(regexp_replace(characters, '[\[\]\'']', '', 'g'))
    ELSE NULL 
  END
  
  
--- Dropping unused columns


alter table "Books_1".book_depository
drop column firstpublishdate

alter table "Books_1".book_depository
drop column isbn

alter table "Books_1".book_depository
drop column rating

alter table "Books_1".book_depository
drop column price

alter table "Books_1".book_depository
drop column firstpublishdate

alter table "Books_1".book_depository
drop column description

alter table "Books_1".book_depository
drop column setting

alter table "Books_1".book_depository
drop column ratingsbystars

alter table "Books_1".book_depository
drop column author

alter table "Books_1".book_depository
drop column genres

alter table "Books_1".book_depository
drop column characters

alter table "Books_1".book_depository
drop column publishdate

alter table "Books_1".book_depository
drop column awards

alter table "Books_1".book_depository
drop column ratings_cleaned



--- Standardizing entries


select edition
from "Books_1".book_depository
where edition = '' --- 47,098 rows missing edition entries

select bookformat, initcap(bookformat)
from "Books_1".book_depository

update "Books_1".book_depository
set bookformat = initcap(bookformat)

select edition, regexp_replace(regexp_replace(edition, '1(?!st)', 'First'), '1st', 'First')
from "Books_1".book_depository
where edition = '1' or edition = '1st'

update "Books_1".book_depository
set edition = regexp_replace(regexp_replace(edition, '1(?!st)', 'First'), '1st', 'First')
where edition = '1' or edition = '1st'

update "Books_1".book_depository
set edition = regexp_replace(edition, 'First Edition', 'First')
where edition = 'First Edition'

update "Books_1".book_depository
set edition = regexp_replace(edition, '1st. edition', 'First')
where edition = '1st. edition'

update "Books_1".book_depository
set edition = regexp_replace(edition, '1st Edition', 'First')
where edition = '1st Edition'

update "Books_1".book_depository
set edition = regexp_replace(edition, '1st edition', 'First')
where edition = '1st edition'

update "Books_1".book_depository
set edition = regexp_replace(edition, '2nd', 'Second')
where edition = '2nd'

update "Books_1".book_depository
set edition = regexp_replace(edition, '2nd edition', 'Second')
where edition = '2nd edition'

update "Books_1".book_depository
set edition = regexp_replace(edition, '2nd Edition', 'Second')
where edition = '2nd Edition'

update "Books_1".book_depository
set edition = regexp_replace(edition, 'Second edition', 'Second')
where edition = 'Second edition'

update "Books_1".book_depository
set edition = regexp_replace(edition, '3', 'Third')
where edition = '3'

update "Books_1".book_depository
set edition = regexp_replace(edition, '3rd', 'Third')
where edition = '3rd'

update "Books_1".book_depository
set edition = regexp_replace(edition, '3rd edition', 'Third')
where edition = '3rd edition'


--- Renaming columns 


alter table "Books_1".book_depository
rename column awards_cleaned to awards

alter table "Books_1".book_depository
rename column publish_date_converted to date_published

alter table "Books_1".book_depository
rename column price_rounded to price

alter table "Books_1".book_depository
rename column rating_rounded to rating

alter table "Books_1".book_depository
rename column author_clean to author

alter table "Books_1".book_depository
rename column settings_cleaned to setting

alter table "Books_1".book_depository
rename column genres_cleaned to genres

alter table "Books_1".book_depository
rename column characters_cleaned to characters


--- Creating a view with sensibly ordered columns in a way that doesn't alter the physical position of the columns in the table


drop view if exists "Books_1".ordered;

create view "Books_1".ordered as 
select  title, 
		author, 
		series, 
		publisher, 
		date_published, 
		edition, 
		language, 
		bookformat,
		pages, 
		awards,
		rating,
		likedpercent,
		numratings, 
		five_stars, 
		four_stars, 
		three_stars,
		two_stars,
		one_stars,
		genres,
		setting,
		characters
from "Books_1".book_depository;
		
select * from "Books_1".ordered
order by title, author desc


