--TSQL - conditional display
--Code:
/*Pulling data based on conditions and display warnings
You have a master table with date sensitive records.

You have 3 other child tables with associated records and volumes.

The three child tables house the same information but T1 is considered more accurate than T2 and it is considered more accurate than T3.
These tables may or may not have information for a given day.

Your task:  
	1. To pull all information from the master table
	2.  Pull the most accurate volume in as a column (vol)
	3.  Create a warning flag for all three child tables if the volume is over 50 or below -50
	4.  Do this with the minimal amount of code
	5.  No loops
	6.  No sub queries
	7.  No temp tables
*/


SET NOCOUNT ON;

DECLARE @tbl_mstr TABLE (id int, nm varchar(50), dt datetime)
DECLARE @tbl_1 TABLE (id int, dt datetime, vol float)
DECLARE @tbl_2 TABLE (id int, dt datetime, vol float)
DECLARE @tbl_3 TABLE (id int, dt datetime, vol float)

INSERT @tbl_mstr VALUES(1,'Helga','10/1/2009')
INSERT @tbl_mstr VALUES(1,'Helga','10/2/2009')
INSERT @tbl_mstr VALUES(1,'Helga','10/3/2009')
INSERT @tbl_mstr VALUES(1,'Helga','10/4/2009')
INSERT @tbl_mstr VALUES(1,'Helga','10/5/2009')
INSERT @tbl_mstr VALUES(1,'Helga','10/6/2009')
INSERT @tbl_mstr VALUES(1,'Helga','10/7/2009')
INSERT @tbl_mstr VALUES(1,'Helga','10/8/2009')
INSERT @tbl_mstr VALUES(1,'Helga','10/9/2009')
INSERT @tbl_mstr VALUES(1,'Helga','10/10/2009')

INSERT INTO @tbl_1 VALUES(1,'10/2/2009',25)
INSERT INTO @tbl_1 VALUES(1,'10/8/2009',42)
INSERT INTO @tbl_1 VALUES(1,'10/9/2009',38)

INSERT INTO @tbl_2 VALUES(1,'10/1/2009',-55)
INSERT INTO @tbl_2 VALUES(1,'10/3/2009',69)
INSERT INTO @tbl_2 VALUES(1,'10/8/2009',74)
INSERT INTO @tbl_2 VALUES(1,'10/10/2009',16)

INSERT INTO @tbl_3 VALUES(1,'10/1/2009',08)
INSERT INTO @tbl_3 VALUES(1,'10/4/2009',37)
INSERT INTO @tbl_3 VALUES(1,'10/5/2009',75)
INSERT INTO @tbl_3 VALUES(1,'10/6/2009',-22)
INSERT INTO @tbl_3 VALUES(1,'10/7/2009',-64)


--Answer SQL Script:
SELECT tm.*,
--If using Azure SQL server, use it
      --LEAST(t1.vol, t2.vol, t3.vol) as ValMin,
       --Greatest(t1.vol, t2.vol, t3.vol) as ValMax,
	   (select max(i) from (values (t1.vol), (t2.vol), (t3.vol)) AS T(i)) [Greatest],
	   (select min(i) from (values (t1.vol), (t2.vol), (t3.vol)) AS T(i)) [Lowest],
       (CASE
            WHEN t1.vol > 50
                 OR t1.vol < -50 THEN
                'T1 Wrng'
            ELSE
                'OK'
        END
       ) AS 'T1 Flag',
       (CASE
            WHEN t2.vol > 50
                 OR t2.vol < -50 THEN
                'T2 Wrng'
            ELSE
                'OK'
        END
       ) AS 'T2 Flag',
       (CASE
            WHEN t3.vol > 50
                 OR t3.vol < -50 THEN
                'T3 Wrng'
            ELSE
                'OK'
        END
       ) AS 'T3 Flag'
FROM @tbl_mstr tm
    LEFT JOIN @tbl_1 t1
        ON t1.id = tm.id
           AND tm.dt = t1.dt
    LEFT JOIN @tbl_2 t2
        ON t2.id = tm.id
           AND tm.dt = t2.dt
    LEFT JOIN @tbl_3 t3
        ON t3.id = tm.id
           AND tm.dt = t3.dt


--Results:
 

