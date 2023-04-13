/* Split the "M" and "k" characters then change the column type to integers */
WITH a AS (
SELECT title, (split_part("installs"::TEXT, '.0 M', 1)::NUMERIC)*1000000 AS total_download FROM android_games
WHERE installs LIKE '%M'
UNION ALL
SELECT title, (split_part("installs"::TEXT, '.0 k', 1)::NUMERIC)*1000 FROM android_games
WHERE installs LIKE '%k')
UPDATE android_games
SET installs = a.total_download::NUMERIC FROM a
WHERE android_games.title = a.title;

ALTER TABLE public.android_games ALTER COLUMN installs TYPE int4 USING installs::int4;

/* Remove the "GAME" part from the category column */
UPDATE android_games
SET category = split_part("category"::TEXT, 'GAME ', 2);

/* Check the number of category */
SELECT COUNT(DISTINCT category) FROM android_games;

/* Delete rows where a specific ratings is higher than total ratings */
DELETE FROM android_games
WHERE ("5 star ratings" > "total ratings") OR ("4 star ratings" > "total ratings") OR ("3 star ratings" > "total ratings") OR ("2 star ratings" > "total ratings") OR ("1 star ratings" > "total ratings") OR (("5 star ratings" + "4 star ratings" + "3 star ratings" + "2 star ratings" + "1 star ratings") > "total ratings");

/* Check to see which category has duplicate datas */
SELECT category, COUNT(title) FROM android_games
GROUP BY 1;

/* Inspect rows in "WORD" and "CARD" category */
SELECT * FROM android_games
WHERE category = 'WORD' OR category = 'CARD'
ORDER BY title ASC, "total ratings";

/* Delete duplicate rows */
DELETE FROM android_games
WHERE title = 'Word Search' AND "5 star ratings" = 261241;

DELETE FROM android_games
WHERE title = 'Solitaire' AND (
	("total ratings" = 102434 AND "5 star ratings" = 66889) 
	OR ("total ratings" = 106773 AND ("5 star ratings" = 66889 OR "5 star ratings" = 88759))
	OR ("total ratings" = 164757 AND "5 star ratings" = 114538)
	OR ("total ratings" = 172895 AND ("5 star ratings" = 114538 OR "5 star ratings" = 121771))
	OR ("total ratings" = 507250 AND "5 star ratings" = 299715)
	OR ("total ratings" = 648068 AND ("5 star ratings" = 299715 OR "5 star ratings" = 418115))
	OR ("total ratings" = 1590733 AND ("5 star ratings" = 431463 OR "5 star ratings" = 418115 OR "5 star ratings" = 299715))
	);
	
DELETE FROM android_games
WHERE title = 'Spider Solitaire' AND "total ratings" = 140758 AND "5 star ratings" = 94475;

/* Convert "average rating" column to real data type */
ALTER TABLE public.android_games ALTER COLUMN "average rating" TYPE float4 USING "average rating"::float4;

/* Re-calculate average ratings with decimals */
UPDATE android_games
SET "average rating" = (("5 star ratings"::NUMERIC * 5 + "4 star ratings"::NUMERIC * 4 + "3 star ratings"::NUMERIC * 3 + "2 star ratings"::NUMERIC * 2 + "1 star ratings"::NUMERIC)/"total ratings"::NUMERIC);

/* Calculate number of games that passed each install milestones, by each category */
SELECT installs, category, COUNT(installs) FROM android_games
GROUP BY 1, 2
ORDER BY 1 DESC, 2;

/* 
installs  |category    |count|
----------+------------+-----+
1000000000|ARCADE      |    1|
1000000000|CASUAL      |    1|
 500000000|ACTION      |    4|
 500000000|ARCADE      |    1|
 500000000|BOARD       |    1|
 500000000|CASUAL      |    3|
 500000000|RACING      |    1|
 500000000|SPORTS      |    1|
 500000000|STRATEGY    |    1|
 100000000|ACTION      |   37|
 100000000|ADVENTURE   |    6|
 100000000|ARCADE      |   41|
 100000000|BOARD       |    5|
 100000000|CASUAL      |   24|
 100000000|EDUCATIONAL |    4|
 100000000|MUSIC       |    5|
 100000000|PUZZLE      |   17|
 100000000|RACING      |   23|
 100000000|ROLE PLAYING|    4|
 100000000|SIMULATION  |   12|
 100000000|SPORTS      |   11|
 100000000|STRATEGY    |    6|
 100000000|TRIVIA      |    2|
 100000000|WORD        |    1|
  50000000|ACTION      |   28|
  50000000|ADVENTURE   |   10|
  50000000|ARCADE      |   25|
  50000000|BOARD       |   11|
  50000000|CARD        |    3|
  50000000|CASINO      |    5|
  50000000|CASUAL      |   18|
  50000000|EDUCATIONAL |   14|
  50000000|MUSIC       |    5|
  50000000|PUZZLE      |   28|
  50000000|RACING      |   26|
  50000000|ROLE PLAYING|    6|
  50000000|SIMULATION  |   18|
  50000000|SPORTS      |   23|
  50000000|STRATEGY    |   13|
  50000000|TRIVIA      |    1|
  50000000|WORD        |    8|
  10000000|ACTION      |   31|
  10000000|ADVENTURE   |   63|
  10000000|ARCADE      |   31|
  10000000|BOARD       |   42|
  10000000|CARD        |   35|
  10000000|CASINO      |   35|
  10000000|CASUAL      |   49|
  10000000|EDUCATIONAL |   64|
  10000000|MUSIC       |   36|
  10000000|PUZZLE      |   50|
  10000000|RACING      |   47|
  10000000|ROLE PLAYING|   58|
  10000000|SIMULATION  |   65|
  10000000|SPORTS      |   58|
  10000000|STRATEGY    |   53|
  10000000|TRIVIA      |   28|
  10000000|WORD        |   54|
   5000000|ADVENTURE   |   13|
   5000000|BOARD       |   28|
   5000000|CARD        |   28|
   5000000|CASINO      |   28|
   5000000|CASUAL      |    3|
   5000000|EDUCATIONAL |    8|
   5000000|MUSIC       |   22|
   5000000|PUZZLE      |    4|
   5000000|RACING      |    3|
   5000000|ROLE PLAYING|   24|
   5000000|SIMULATION  |    4|
   5000000|SPORTS      |    6|
   5000000|STRATEGY    |   21|
   5000000|TRIVIA      |   24|
   5000000|WORD        |   21|
   1000000|ADVENTURE   |    8|
   1000000|ARCADE      |    1|
   1000000|BOARD       |   13|
   1000000|CARD        |   32|
   1000000|CASINO      |   31|
   1000000|CASUAL      |    2|
   1000000|EDUCATIONAL |    9|
   1000000|MUSIC       |   27|
   1000000|PUZZLE      |    1|
   1000000|ROLE PLAYING|    8|
   1000000|SIMULATION  |    1|
   1000000|SPORTS      |    1|
   1000000|STRATEGY    |    6|
   1000000|TRIVIA      |   36|
   1000000|WORD        |   16|
    500000|CARD        |    2|
    500000|CASINO      |    1|
    500000|EDUCATIONAL |    1|
    500000|MUSIC       |    3|
    500000|TRIVIA      |    8|
    100000|MUSIC       |    2|
    100000|TRIVIA      |    1|
*/

/* Calculate the average number of ratings for each category */
SELECT category, SUM("total ratings")/100 AS average_number_of_ratings
FROM android_games
GROUP BY 1
ORDER BY 2 DESC;

/*
category    |average_number_of_ratings|
------------+-------------------------+
ACTION      |                  4011343|
CASUAL      |                  2470866|
STRATEGY    |                  1856569|
ARCADE      |                  1793779|
SPORTS      |                  1353828|
RACING      |                  1139026|
PUZZLE      |                   946692|
SIMULATION  |                   934141|
ADVENTURE   |                   893561|
ROLE PLAYING|                   708764|
BOARD       |                   445743|
WORD        |                   396268|
CASINO      |                   361903|
CARD        |                   305782|
TRIVIA      |                   298221|
MUSIC       |                   216302|
EDUCATIONAL |                   152980|
*/

/* Calculate the average ratings for each category */
SELECT category, (SUM("5 star ratings"::NUMERIC) * 5 + SUM("4 star ratings"::NUMERIC) * 4 + SUM("3 star ratings"::NUMERIC) * 3 + SUM("2 star ratings"::NUMERIC) * 2 + SUM("1 star ratings")::NUMERIC)/SUM("total ratings"::NUMERIC) AS average_ratings
FROM android_games
GROUP BY 1
ORDER BY 2 DESC;

/*
category    |average_ratings   |
------------+------------------+
WORD        |4.4667789003359818|
CASINO      |4.4195986002772179|
PUZZLE      |4.4148096618278290|
TRIVIA      |4.3857805192727076|
CASUAL      |4.3787907660101233|
CARD        |4.3578057783206756|
STRATEGY    |4.3410685970726389|
ARCADE      |4.3390059709164654|
SPORTS      |4.3366939034434206|
SIMULATION  |4.3308377482151663|
ROLE PLAYING|4.3205526436744893|
RACING      |4.3189154899603767|
BOARD       |4.3092512464635737|
ADVENTURE   |4.2918822822472233|
EDUCATIONAL |4.2658586543958097|
ACTION      |4.2378447211552758|
MUSIC       |4.2372330133578965|
*/

/* Find out which game has the fastest growth within 30 days */
SELECT category, title, ROUND("growth (30 days)"::NUMERIC, 2) AS growth_30_days
FROM android_games
GROUP BY 1, 2, 3
ORDER BY 3 DESC
LIMIT 20;

/*
category    |title                                             |growth_30_days|
------------+--------------------------------------------------+--------------+
CASINO      |Dummy ดัมมี่ ไพ่แคง เกมไพ่ฟรี                          |     227106.00|
TRIVIA      |Gartic                                            |      69928.50|
CARD        |Belote.com - Free Belote Game                     |      55880.60|
CARD        |Durak Online                                      |      37994.40|
TRIVIA      |New QuizDuel!                                     |      28062.90|
ROLE PLAYING|세븐나이츠                                         |      17025.00|
ADVENTURE   |Mini World: Block Art                             |      15364.20|
RACING      |Truck Driver Cargo                                |      12602.30|
SPORTS      |Mobile Soccer League                              |       9750.20|
CASINO      |GAMEE Prizes - Play Free Games, WIN REAL CASH!    |       5550.20|
SPORTS      |Soccer Star 2021 Top Leagues: Play the SOCCER game|       5546.90|
EDUCATIONAL |Truck games for kids - build a house, car wash    |       5446.90|
ADVENTURE   |Street Chaser                                     |       5156.30|
TRIVIA      |Flags and Capitals of the World Quiz              |       3914.80|
ARCADE      |BBTAN by 111%                                     |       2948.20|
RACING      |City Racing Lite                                  |       2577.70|
EDUCATIONAL |My Baby Panda Chef                                |       2428.70|
TRIVIA      |Genius Quiz - Smart Brain Trivia Game             |       2391.10|
ADVENTURE   |Transformers: RobotsInDisguise                    |       2283.00|
BOARD       |Backgammon Plus                                   |       2212.20|
*/

/* Find out which game has the fastest growth within 60 days */
SELECT category, title, ROUND("growth (60 days)"::NUMERIC, 3) AS growth_60_days
FROM android_games
GROUP BY 1, 2, 3
ORDER BY 3 DESC
LIMIT 20;

/*
category   |title                                             |growth_60_days|
-----------+--------------------------------------------------+--------------+
CARD       |Domino QiuQiu 2020 - Domino 99 · Gaple online     |     69441.400|
BOARD      |Carrom King™ - Best Online Carrom Board Pool Game |     42875.200|
STRATEGY   |Castle Clash: Схватка Гильдий                     |     41869.700|
BOARD      |인생역전윷놀이                                     |     15483.900|
ACTION     |Special Forces Group 2                            |      7584.900|
RACING     |Racing Fever: Moto                                |      6004.400|
WORD       |Aplasta Palabras：Juego de Palabras Gratis sin wifi|      5556.200|
ACTION     |Talking Tom Gold Run                              |      4012.800|
RACING     |Moto Racer 3D                                     |      2716.500|
CASUAL     |Idle Sightseeing Train - Game of Train Transport  |      1251.800|
ARCADE     |Color Bump 3D                                     |      1107.100|
STRATEGY   |Top War: Battle Game                              |      1019.600|
ARCADE     |Sonic Dash 2: Sonic Boom                          |       863.600|
MUSIC      |Dynamix                                           |       718.200|
SIMULATION |Extreme Landings                                  |       709.000|
EDUCATIONAL|Baby Phone for Kids - Learning Numbers and Animals|       672.700|
SPORTS     |8 Ball Pool                                       |       630.800|
SIMULATION |Godus                                             |       516.900|
MUSIC      |Love Live! School idol festival- Music Rhythm Game|       498.500|
STRATEGY   |Zombie Defense                                    |       490.900|
*/

/* Games with highest proportion of 4-5 stars ratings */
SELECT category, title, ROUND(("4 star ratings"::NUMERIC + "5 star ratings"::NUMERIC)/"total ratings"::NUMERIC, 2) AS high_ratings_prop FROM android_games
GROUP BY 1, 2, 3
ORDER BY 3 DESC
LIMIT 10;

/*
category   |title                                             |high_ratings_prop|
-----------+--------------------------------------------------+-----------------+
EDUCATIONAL|超級單字王 - 英檢、多益、托福 輕鬆學                 |             0.98|
PUZZLE     |Indy Cat for VK                                   |             0.97|
PUZZLE     |Sudoku                                            |             0.97|
EDUCATIONAL|Английский для Начинающих: LinDuo HD              |             0.96|
RACING     |DATA WING                                         |             0.96|
SPORTS     |Retro Bowl                                        |             0.96|
WORD       |Aplasta Palabras：Juego de Palabras Gratis sin wifi|             0.96|
WORD       |Word Nut: Word Puzzle Games & Crosswords          |             0.96|
BOARD      |Slots: Epic Jackpot Slots Games Free & Casino Game|             0.95|
BOARD      |Slots: VIP Deluxe Slot Machines Free - Vegas Slots|             0.95|
*/

/* Games with highest proportion of 1-2 stars ratings */
SELECT category, title, ROUND(("1 star ratings"::NUMERIC + "2 star ratings"::NUMERIC)/"total ratings"::NUMERIC, 2) AS low_ratings_prop FROM android_games
GROUP BY 1, 2, 3
ORDER BY 3 DESC
LIMIT 10;

/*
category  |title                                             |low_ratings_prop|
----------+--------------------------------------------------+----------------+
SPORTS    |Futsal Football 2                                 |            0.55|
MUSIC     |Au Mobile VTC – Game nhảy Audition                |            0.45|
MUSIC     |Piano Music Tiles 2 - Free Music Games            |            0.43|
TRIVIA    |TopQuiz -Play Quiz & Lottery | Win Money via Paytm|            0.42|
BOARD     |모두의마블                                         |            0.41|
TRIVIA    |New QuizDuel!                                     |            0.38|
TRIVIA    |Live Quiz Games App, Trivia & Gaming App for Money|            0.36|
SIMULATION|Taxi Game                                         |            0.35|
ACTION    |Among Us                                          |            0.34|
BOARD     |Backgammon Plus                                   |            0.34|
*/

/* Proportion of "dead games" */ 
SELECT COUNT(*)/1700::NUMERIC AS prop_of_dead_games FROM android_games
WHERE "growth (30 days)" = 0

/*
prop_of_dead_games    |
----------------------+
0.15588235294117647059|
*/

/* Number of paid games and info about their prices */
SELECT COUNT(*), MIN(price), MAX(price), AVG(price) FROM android_games
WHERE paid = TRUE;

/*
count|min |max |avg               |
-----+----+----+------------------+
    7|0.99|7.49|2.7042856897626604|
*/
