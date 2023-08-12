--TSQL - summarization and capitalization
--Code:
/*Pulling data and display with appropriate format and show summarized data

You have a simple table of data.

No additional table variables or temp tables should be used

Your task in your sql output:  
	3.  Capitalize the state names
	2.  Convert the county names to camel (meaning first letter is capitalized)
	3.  Show the city data along with county and state totals
	4.  Sort by state, county, city, then totals
*/

SET NOCOUNT ON;


/*play data*/
--**--**--
DECLARE @tbl TABLE (State varchar(2), County varchar(40), City varchar(40), WellCount int)

INSERT @tbl VALUES ('ok','la flore','Mcalister',5)
INSERT @tbl VALUES ('ok','la flore','Savannah',2)
INSERT @tbl VALUES ('ok','hughes','Dustin',9)
INSERT @tbl VALUES ('tx','tarrant','Fort Worth',51)
INSERT @tbl VALUES ('tx','tarrant','Burleson',6)
INSERT @tbl VALUES ('tx','parKer','Weatherford',7)
INSERT @tbl VALUES ('ar','bryaNnt','Little Rock',12)
INSERT @tbl VALUES ('ar','bryaNnt','Ozark',12)
INSERT @tbl VALUES ('ar','reeD','Van Buren',46)
INSERT @tbl VALUES ('nm','saN Jaun','Farmington',3)
INSERT @tbl VALUES ('nm','saN Jaun',' Bloomfield',3)
INSERT @tbl VALUES ('nm','rio arriba','Durango',104)
--**--**--

--Answer SQL Script:
SELECT UPPER(   CASE
                    WHEN [State] IS NULL THEN
                        'Total:'
                    ELSE
                        [State]
                END
            ) As [State],
       (
           SELECT STRING_AGG(UPPER(left(value, 1)) + SUBSTRING(value, 2, 999), ' ')
           from STRING_SPLIT(LOWER(   CASE
                                          WHEN County IS NULL
                                               AND [State] IS NOT NULL THEN
                                              'State Total:'
                                          ELSE
                                              County
                                      End
                                  ), ' ')
       ) AS County,
       (
           SELECT STRING_AGG(UPPER(left(value, 1)) + SUBSTRING(value, 2, 999), ' ')
           from STRING_SPLIT(LOWER(   CASE
                                          WHEN City IS NULL
                                               AND County IS NOT NULL
                                               AND [State] IS NOT NULL THEN
                                              'Country Total:'
                                          ELSE
                                              City
                                      End
                                  ), ' ')
       ) AS City,
       SUM(WellCount) AS WellCount
FROM @tbl
GROUP BY ROLLUP ([State], County, City)