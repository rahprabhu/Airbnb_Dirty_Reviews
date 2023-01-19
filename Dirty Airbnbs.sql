-- How many reviews this year (2022) commented about uncleanliness
SELECT
	COUNT(*) AS dirty_reviews
FROM airbnb.reviews
WHERE 
	comments SIMILAR TO '%(unclean|dirty|not clean|filthy|messy|stain)%'
	AND date >= '2020-09-01';

-- Create a materialized view to sum up the number of reviews over the last 2 years

DROP MATERIALIZED VIEW IF EXISTS airbnb.review_summary;
CREATE MATERIALIZED VIEW airbnb.review_summary AS
SELECT
	listing_id,
	COUNT(review_id) AS num_reviews,
	MAX(date) AS latest_review_date
FROM airbnb.reviews
WHERE
	date >= '2020-09-01'
GROUP BY listing_id
ORDER BY num_reviews DESC, latest_review_date DESC;

-- Create a materialized view to sum up the number of "dirty" reviews over the last 2 years

DROP MATERIALIZED VIEW IF EXISTS airbnb.dirty_review_summary;
CREATE MATERIALIZED VIEW airbnb.dirty_review_summary AS
SELECT
	listing_id,
	COUNT(review_id) AS dirty_reviews,
	MAX(date) AS latest_dirty_review_date
FROM airbnb.reviews
WHERE
	comments SIMILAR TO '%(unclean|dirty|not clean|filthy|messy|stain)%'
	AND date >= '2020-09-01'
GROUP BY listing_id
ORDER BY dirty_reviews DESC, latest_dirty_review_date DESC;

-- Create materialized view to combine number of reviews and number of dirty reviews

DROP MATERIALIZED VIEW IF EXISTS airbnb.combined_reviews;
CREATE MATERIALIZED VIEW airbnb.combined_reviews AS
SELECT
	review_summary.*, COALESCE(dirty.dirty_reviews,0) AS dirty_reviews, dirty.latest_dirty_review_date
FROM airbnb.review_summary review_summary
LEFT JOIN airbnb.dirty_review_summary dirty
	ON dirty.listing_id = review_summary.listing_id
ORDER BY dirty_reviews DESC;

-- Perform data cleaning on listings table before joining with combined reviews summary table
SELECT 
	bathrooms,
	COUNT(*)
FROM airbnb.listings
GROUP BY 1
ORDER BY 2 DESC;

UPDATE airbnb.listings
SET bathrooms = CASE
	WHEN bathrooms = 'Half-bath' THEN '0.5'
	WHEN bathrooms = 'Shared half-bath' THEN '0.5'
	WHEN bathrooms = 'Private half-bath' THEN '0.5'
	ELSE regexp_replace(bathrooms, '[^0-9.]', '', 'g')
	END;
ALTER TABLE airbnb.listings
ALTER COLUMN bathrooms TYPE NUMERIC
	USING bathrooms::NUMERIC;
	

UPDATE airbnb.listings
SET price = regexp_replace(price, '[^0-9.]', '', 'g')::numeric;
ALTER TABLE airbnb.listings
ALTER COLUMN price TYPE NUMERIC
	USING price::NUMERIC;

-- Create a materialized view that combines all of the listing data with the summary data on reviews/dirty reviews
DROP MATERIALIZED VIEW IF EXISTS airbnb.listings_reviews;
CREATE MATERIALIZED VIEW airbnb.listings_reviews AS
SELECT
	listings.*, 
	COALESCE(combined_reviews.dirty_reviews,0) AS dirty_reviews, combined_reviews.latest_dirty_review_date, 
	COALESCE(combined_reviews.num_reviews,0) AS num_reviews, combined_reviews.latest_review_date
FROM airbnb.listings listings
LEFT JOIN airbnb.combined_reviews combined_reviews
	ON combined_reviews.listing_id = listings.listing_id
ORDER BY dirty_reviews DESC;