SELECT bitmapToArray(bitmapBuild([1, 2, 3, 4, 5]));
SELECT bitmapToArray(bitmapAnd(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])));
SELECT bitmapToArray(bitmapOr(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])));
SELECT bitmapToArray(bitmapXor(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])));
SELECT bitmapToArray(bitmapAndnot(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])));
SELECT bitmapCardinality(bitmapBuild([1, 2, 3, 4, 5]));
SELECT bitmapAndCardinality(bitmapBuild([1,2,3]),bitmapBuild([3,4,5]));
SELECT bitmapOrCardinality(bitmapBuild([1,2,3]),bitmapBuild([3,4,5]));
SELECT bitmapXorCardinality(bitmapBuild([1,2,3]),bitmapBuild([3,4,5]));
SELECT bitmapAndnotCardinality(bitmapBuild([1,2,3]),bitmapBuild([3,4,5]));
SELECT bitmapAndCardinality(bitmapBuild([100, 200, 500]), bitmapBuild(CAST([100, 200], 'Array(UInt16)')));
SELECT bitmapToArray(bitmapAnd(bitmapBuild([100, 200, 500]), bitmapBuild(CAST([100, 200], 'Array(UInt16)'))));

CREATE TABLE bitmap_test(pickup_date Date, city_id UInt32, uid UInt32)ENGINE = Memory;
INSERT INTO bitmap_test SELECT '2019-01-01', 1, number FROM numbers(1,50);
INSERT INTO bitmap_test SELECT '2019-01-02', 1, number FROM numbers(11,60);


SELECT groupBitmap( uid ) AS user_num FROM bitmap_test;

SELECT pickup_date, groupBitmap( uid ) AS user_num, bitmapToArray(groupBitmapState( uid )) AS users FROM bitmap_test GROUP BY pickup_date;

SELECT
    bitmapCardinality(day_today) AS today_users,
    bitmapCardinality(day_before) AS before_users,
    bitmapOrCardinality(day_today, day_before) AS all_users,
    bitmapAndCardinality(day_today, day_before) AS old_users,
    bitmapAndnotCardinality(day_today, day_before) AS new_users,
    bitmapXorCardinality(day_today, day_before) AS diff_users
FROM
(
 SELECT city_id, groupBitmapState( uid ) AS day_today FROM bitmap_test WHERE pickup_date = '2019-01-02' GROUP BY city_id
 )
ALL LEFT JOIN
(
 SELECT city_id, groupBitmapState( uid ) AS day_before FROM bitmap_test WHERE pickup_date = '2019-01-01' GROUP BY city_id
)
USING city_id;

SELECT
    bitmapCardinality(day_today) AS today_users,
    bitmapCardinality(day_before) AS before_users,
    bitmapCardinality(bitmapOr(day_today, day_before))ll_users,
    bitmapCardinality(bitmapAnd(day_today, day_before)) AS old_users,
    bitmapCardinality(bitmapAndnot(day_today, day_before)) AS new_users,
    bitmapCardinality(bitmapXor(day_today, day_before)) AS diff_users
FROM
(
 SELECT city_id, groupBitmapState( uid ) AS day_today FROM bitmap_test WHERE pickup_date = '2019-01-02' GROUP BY city_id
 )
ALL LEFT JOIN
(
 SELECT city_id, groupBitmapState( uid ) AS day_before FROM bitmap_test WHERE pickup_date = '2019-01-01' GROUP BY city_id
)
USING city_id;

-- bitmap state test
CREATE TABLE bitmap_state_test
(
	pickup_date Date,
	city_id UInt32,
    uv AggregateFunction( groupBitmap, UInt32 )
)
ENGINE = AggregatingMergeTree( pickup_date, ( pickup_date, city_id ), 8192);

INSERT INTO bitmap_state_test SELECT
    pickup_date,
    city_id,
    groupBitmapState(uid) AS uv
FROM bitmap_test
GROUP BY pickup_date, city_id;

SELECT pickup_date, groupBitmapMerge(uv) AS users from bitmap_state_test group by pickup_date;

-- between column and expression test
CREATE TABLE bitmap_column_expr_test
(
    t DateTime,
    z AggregateFunction(groupBitmap, UInt32)
)
ENGINE = MergeTree
PARTITION BY toYYYYMMDD(t)
ORDER BY t;

INSERT INTO bitmap_column_expr_test VALUES (now(), bitmapBuild(cast([3,19,47] as Array(UInt32))));

SELECT bitmapAndCardinality( bitmapBuild(cast([19,7] AS Array(UInt32))), z) FROM bitmap_column_expr_test;
SELECT bitmapAndCardinality( z, bitmapBuild(cast([19,7] AS Array(UInt32))) ) FROM bitmap_column_expr_test;

SELECT bitmapCardinality(bitmapAnd(bitmapBuild(cast([19,7] AS Array(UInt32))), z )) FROM bitmap_column_expr_test;
SELECT bitmapCardinality(bitmapAnd(z, bitmapBuild(cast([19,7] AS Array(UInt32))))) FROM bitmap_column_expr_test;



-- bitmapHasAny:
---- Empty
SELECT bitmapHasAny(bitmapBuild([1, 2, 3, 5]), bitmapBuild(emptyArrayUInt8()));
SELECT bitmapHasAny(bitmapBuild(emptyArrayUInt32()), bitmapBuild(emptyArrayUInt32()));
SELECT bitmapHasAny(bitmapBuild(emptyArrayUInt16()), bitmapBuild([1, 2, 3, 500]));
---- Small x Small
SELECT bitmapHasAny(bitmapBuild([1, 2, 3, 5]),bitmapBuild([0, 3, 7]));
SELECT bitmapHasAny(bitmapBuild([1, 2, 3, 5]),bitmapBuild([0, 4, 7]));
---- Small x Large
select bitmapHasAny(bitmapBuild([100,110,120]),bitmapBuild([ 99, 100, 101,
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33]));
select bitmapHasAny(bitmapBuild([100,200,500]),bitmapBuild([ 99, 101, 600,
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33]));
---- Large x Small
select bitmapHasAny(bitmapBuild([
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,
    100,200,230]),bitmapBuild([ 99, 100, 101]));
select bitmapHasAny(bitmapBuild([
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,
    100,200,500]),bitmapBuild([ 99, 101, 600]));
---- Large x Large
select bitmapHasAny(bitmapBuild([
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,
    40,50,60]),bitmapBuild([ 41, 50, 61,
    99,98,97,96,95,94,93,92,91,90,89,88,87,86,85,84,83,82,81,80,79,78,77,76,75,74,73,72,71,70,69,68,67,66,65]));
select bitmapHasAny(bitmapBuild([
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,
    40,50,60]),bitmapBuild([ 41, 49, 51, 61,
    99,98,97,96,95,94,93,92,91,90,89,88,87,86,85,84,83,82,81,80,79,78,77,76,75,74,73,72,71,70,69,68,67,66,65]));

-- bitmapHasAll:
---- Empty
SELECT bitmapHasAll(bitmapBuild([1, 2, 3, 5]), bitmapBuild(emptyArrayUInt8()));
SELECT bitmapHasAll(bitmapBuild(emptyArrayUInt32()), bitmapBuild(emptyArrayUInt32()));
SELECT bitmapHasAll(bitmapBuild(emptyArrayUInt16()), bitmapBuild([1, 2, 3, 500]));
---- Small x Small
select bitmapHasAll(bitmapBuild([1,5,7,9]),bitmapBuild([5,7]));
select bitmapHasAll(bitmapBuild([1,5,7,9]),bitmapBuild([5,7,2]));
---- Small x Large
select bitmapHasAll(bitmapBuild([100,110,120]),bitmapBuild([ 99, 100, 101,
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33]));
select bitmapHasAll(bitmapBuild([100,200,500]),bitmapBuild([ 99, 101, 600,
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33]));
---- Small x LargeSmall
select bitmapHasAll(bitmapBuild([1,5,7,9]),bitmapXor(bitmapBuild([1,5,7]), bitmapBuild([5,7,9])));
select bitmapHasAll(bitmapBuild([1,5,7,9]),bitmapXor(bitmapBuild([1,5,7]), bitmapBuild([2,5,7])));
---- Large x Small
select bitmapHasAll(bitmapBuild([
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,
    100,200,500]),bitmapBuild([100, 500]));
select bitmapHasAll(bitmapBuild([
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,
    100,200,500]),bitmapBuild([ 99, 100, 500]));
---- LargeSmall x Small
select bitmapHasAll(bitmapXor(bitmapBuild([1,7]), bitmapBuild([5,7,9])), bitmapBuild([1,5]));
select bitmapHasAll(bitmapXor(bitmapBuild([1,7]), bitmapBuild([5,7,9])), bitmapBuild([1,5,7]));
---- Large x Large
select bitmapHasAll(bitmapBuild([
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,
    100,200,500]),bitmapBuild([ 100, 200, 500,
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33]));
select bitmapHasAll(bitmapBuild([
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,
    100,200,500]),bitmapBuild([ 100, 200, 501,
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33]));
