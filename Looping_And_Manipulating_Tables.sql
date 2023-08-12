--looping and manipulating tables
--Code:
/*Looping and manipulating tables

Have auto commit set in your SQL Server Management Studio settings
You have 1 simple table of data.  
Based on the date range given, display the data in a horizontal format for each unload event
Looping is recommended, and 1 temp table is recommended.  You may also need another temp or table variable.
Working variables are also recommended.


Your task in your sql output:  
	1.  Catch all unload events for a date range
	2.	Sequence the time events in numerical order incrementing by 1
	3.	Display the sequence in one column
	4.  Have another column for each unload serial number - start date and display all unload density values per sequence
	5.	The column creation for the serial numbers should be dynamic requiring looping
	6.	Create the script so that you can feed it a start date and end date
	
*/

SET NOCOUNT ON;

/*declare initial data holding table*/
CREATE TABLE ##data (recorddatetime datetime, unload_density float, loadserialnumber int);


/*load initial data to work with*/
INSERT INTO ##data VALUES('2010-10-09 13:26:36.000',1.01059,252);
INSERT INTO ##data VALUES('2010-10-09 13:26:41.000',1.01068,252);
INSERT INTO ##data VALUES('2010-10-09 13:26:46.000',1.02589,252);

INSERT INTO ##data VALUES('2010-10-10 08:15:02.000',1.03333,266);
INSERT INTO ##data VALUES('2010-10-10 08:15:07.000',1.04444,266);
INSERT INTO ##data VALUES('2010-10-10 08:15:12.000',1.01561,266);
INSERT INTO ##data VALUES('2010-10-10 08:15:17.000',1.03581,266);
INSERT INTO ##data VALUES('2010-10-10 08:15:22.000',1.03554,266);

INSERT INTO ##data VALUES('2010-10-08 18:47:45.000',1.04983,302);
INSERT INTO ##data VALUES('2010-10-08 18:47:50.000',1.09813,302);
INSERT INTO ##data VALUES('2010-10-08 18:47:56.000',1.04576,302);
INSERT INTO ##data VALUES('2010-10-08 18:48:01.000',1.03485,302);

--Answer SQL Script:

CREATE TABLE #MyData (Record INT IDENTITY(1,1));

DECLARE @ListDates TABLE(Record INT IDENTITY(1,1), RecordDate DateTime, RecordTime varchar(20), SerialNumber int)

INSERT INTO @ListDates
SELECT Distinct
    CONVERT(date, recorddatetime) AS recorddate,
    FIRST_VALUE(CONVERT(VARCHAR(20), recorddatetime, 8)) OVER (PARTITION BY CONVERT(date, recorddatetime),
                                                                            loadserialnumber
                                                               ORDER BY loadserialnumber ASC
                                                              ),
    loadserialnumber
FROM ##data
ORDER BY loadserialnumber

DECLARE @counter int = 1
DECLARE @Rowcount int = (SELECT COUNT(*) FROM @ListDates)

DECLARE @ColumnName NVARCHAR(200) = ''
DECLARE @SelecColumnName NVARCHAR(200) = ''
DECLARE @TempColumnName NVARCHAR(200) = ''
DECLARE @serialnumber NVARCHAR(10) = ''


DECLARE @InnerColumnText NVARCHAR(MAX) = ''

WHILE @counter <= @Rowcount
BEGIN
	IF  @ColumnName <> ''  BEGIN
			SET @ColumnName += ', '
			SET @SelecColumnName += ', '
		END

		SELECT @serialnumber = CAST(SerialNumber AS VARCHAR(20)),
		   @TempColumnName
			   = '[Load' + CAST(SerialNumber AS VARCHAR(20)) + '_' + CONVERT(VARCHAR(20), RecordDate, 101) + '_'
				 + RecordTime + ']',
		   @SelecColumnName += @TempColumnName + '.unload_density',
		   @ColumnName += @TempColumnName + 'float NULL'
	FROM @ListDates
	WHERE Record = @counter

	SET @InnerColumnText += FORMATMESSAGE('LEFT JOIN (SELECT ROW_NUMBER() OVER (ORDER BY recorddatetime) as rn, unload_density
FROM ##data WHERE loadserialnumber=%s) %s ON %s.rn =d1.rn ',  @serialnumber, @TempColumnName,  @TempColumnName)

	SET @counter += 1
END

SET @ColumnName = 'ALTER TABLE #MyData ADD ' + @ColumnName

Exec sp_executesql @ColumnName

SET @InnerColumnText
    = FORMATMESSAGE(
                       'INSERT INTO #MyData
SELECT %s FROM
(SELECT ROW_NUMBER() OVER (ORDER BY recorddatetime) as rn
FROM ##data) d1 %s 
WHERE COALESCE (%s ) IS NOT NULL; ',
                       @SelecColumnName,
                       @InnerColumnText,
                       @SelecColumnName
                   )

Exec sp_executesql @InnerColumnText


SELECT * FROM #MyData

DROP TABLE ##data

DROP TABLE #MyData

--Independent:
--SELECT t1.unload_density,
--       t2.unload_density,
--       t3.unload_density
--FROM
--(
--    SELECT ROW_NUMBER() OVER (ORDER BY recorddatetime) as rn
--    FROM ##data
--) d1
--    LEFT JOIN
--    (
--        SELECT ROW_NUMBER() OVER (ORDER BY recorddatetime) as rn,
--               unload_density
--        FROM ##data
--        WHERE loadserialnumber = 252
--    ) t1
--        ON t1.rn = d1.rn
--    LEFT JOIN
--    (
--        SELECT ROW_NUMBER() OVER (ORDER BY recorddatetime) as rn,
--               unload_density
--        FROM ##data
--        WHERE loadserialnumber = 266
--    ) t2
--        ON t2.rn = d1.rn
--    LEFT JOIN
--    (
--        SELECT ROW_NUMBER() OVER (ORDER BY recorddatetime) as rn,
--               unload_density
--        FROM ##data
--        WHERE loadserialnumber = 302
--    ) t3
--        ON t3.rn = d1.rn
--WHERE COALESCE(t1.unload_density, t2.unload_density, t3.unload_density) IS NOT NULL;
