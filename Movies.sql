

--������ ������� ��� ���� � Kaggle. �������� � ���� ���������� � ������� � 1980 �� 2021. ����� ���-�� ����� - 7668.
--������: ��������� ������ ��������� SQL ��� ������������ � tableau

SELECT *
FROM PortfolioProject..Movies;

--�������� ������ �� ����������� ��������. StackOverflow ���������� ������ �� ����������� ������� ����� ������, � �� ������� ����������� �������� ������

SELECT *
FROM PortfolioProject..Movies
where name is NULL or
	  rating is NULL or
	  genre is NULL or
	  year is NULL or
	  released is NULL or
	  score is NULL or
	  votes is NULL or
	  director is NULL or
	  writer is NULL or
	  star is NULL or
	  country is NULL or
	  budget is NULL or
	  gross is NULL or
	  company is NULL or
	  runtime is NULL;

-- 2247 ������� � ���� �� ����� ����������� ���������. ��������� �� ������, ��������� ����� ����������, ��� �������� ���� ����������� �������� ��������
-- ������� budget. ��������� ���-�� ���� ��������.

SELECT SUM(CASE WHEN budget is null THEN 1 ELSE 0 END) AS NumberOfNullValues
	,COUNT(budget) AS NumberOfNonNullValues
FROM PortfolioProject..Movies;

-- 2171 �������� ���������. 
-- �������� ������ � �������� ���� ���������, ������ �������� ��������� �������-����� ��� ��������.

DROP TABLE if exists #TempMovies
Create Table #TempMovies
(
Name nvarchar(255),
Rating nvarchar(255),
Genre nvarchar(255),
Year nvarchar(255),
Released nvarchar(255),
Score float,
Votes float,
Director nvarchar(255),
writer nvarchar(255),
star nvarchar(255),
country nvarchar(255),
budget float,
gross float,
company nvarchar(255),
runtime float
);

INSERT into #TempMovies
SELECT *
FROM PortfolioProject..Movies;

SELECT *
FROM #TempMovies;

-- ��� �������� ��������� ������� �������, ��� �������� ������� Year �� ������ ��������� � ����� ������� ������ � ������� Released.
-- ������� ����� ������� � ������������ �����

ALTER TABLE #TempMovies
Add YearSplit nvarchar(255);

WITH CTE AS
(
SELECT YearSplit, Released, PARSENAME(REPLACE(Released, ',', '.'), 1) as SplitYear
FROM #TempMovies
)
UPDATE CTE
SET YearSplit = SUBSTRING(SplitYear, 1, CHARINDEX(' (', SplitYear));

UPDATE #TempMovies
SET YearSplit = PARSENAME(REPLACE(RTRIM(YearSplit), ' ', '.'), 1);


SELECT *
FROM #TempMovies;

-- ��� �� �������� ��������� ������� ��� ������ � ��� �������


ALTER TABLE #TempMovies
Add MonthSplit nvarchar(255);

ALTER TABLE #TempMovies
Add DaySplit nvarchar(255);


SELECT Released, SUBSTRING(Released, 1, CHARINDEX(' ', Released) -1)
FROM #TempMovies;

SELECT Released, CASE WHEN CHARINDEX(',', Released) > 0 THEN SUBSTRING(Released, CHARINDEX(' ', Released), CHARINDEX(',', Released) - CHARINDEX(' ', Released))
          ELSE SUBSTRING(Released, 1, CHARINDEX(' ', Released)) END 
FROM #TempMovies;


UPDATE #TempMovies
SET MonthSplit = SUBSTRING(Released, 1, CHARINDEX(' ', Released) -1);

UPDATE #TempMovies
SET DaySplit =  CASE WHEN CHARINDEX(',', Released) > 0 THEN SUBSTRING(Released, CHARINDEX(' ', Released), CHARINDEX(',', Released) - CHARINDEX(' ', Released))
          ELSE '-' END;

UPDATE #TempMovies
SET MonthSplit = CASE When MonthSplit = 'January' then '01'
	   WHEN MonthSplit = 'February' THEN '02'
	   WHEN MonthSplit = 'March' THEN '03'
	   WHEN MonthSplit = 'April' THEN '04'
	   WHEN MonthSplit = 'May' THEN '05'
	   WHEN MonthSplit = 'June' THEN '06'
	   WHEN MonthSplit = 'July' THEN '07'
	   WHEN MonthSplit = 'August' THEN '08'
	   WHEN MonthSplit = 'September' THEN '09'
	   WHEN MonthSplit = 'October' THEN '10'
	   WHEN MonthSplit = 'November' THEN '11'
	   WHEN MonthSplit = 'December' THEN '12'
	   ELSE MonthSplit
	   END


-- ������� ������� Released, ����� �������� ���������� ������ ������� ��� ����������� ������� ������������ ���������� ����. ������������� ��� �������� ���������.

SELECT CASE WHEN CHARINDEX('-', YearSplit + '.' + MonthSplit + '.' + DaySplit) >= 1 THEN '0' 
		  ELSE TRIM(YearSplit) + '.' + TRIM(MonthSplit) + '.' + TRIM(DaySplit) END
FROM #TempMovies;


UPDATE #TempMovies
SET Released = CASE WHEN CHARINDEX('-', YearSplit + '.' + MonthSplit + '.' + DaySplit) >= 1 THEN '0' 
		  ELSE TRIM(YearSplit) + '.' + TRIM(MonthSplit) + '.' + TRIM(DaySplit) END

SELECT *
FROM #TempMovies;

-- ������ ��������� ����������� � ������������ ���������� � ������. ����� � ������� budget ����� ������ ������� ����������������� ���������� (41457296,6),
-- ������� ��������� 2171 ������ ��������� ��� ������� ��������� �� ���������� �������. 
-- �� ���������� �������� ������� ������ ������ (web scraping, ������������ ��������), �������� ������� - �������� ����������� ��������.

SELECT
STDEV (Budget) AS StandardDeviation
FROM #TempMovies;

SELECT DISTiNCT
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY budget)
OVER (PARTITION BY (SELECT 1)) AS Median
FROM #TempMovies;

SELECT AVG(budget) AS Average
FROM #TempMovies;

delete from #TempMovies
where budget is null or
	  gross is null or
	  company is null 
	--  score is null or
	--  votes is null or
	-- rating is null;

	  
SELECT *
FROM #TempMovies
where name is NULL or
	  rating is NULL or
	  genre is NULL or
	  year is NULL or
	  released is NULL or
	  score is NULL or
	  votes is NULL or
	  director is NULL or
	  writer is NULL or
	  star is NULL or
	  country is NULL or
	  budget is NULL or
	  gross is NULL or
	  company is NULL or
	  runtime is NULL;

-- ������� � ����������� rating ����� ��������� ��������� R - �� ����������� ���� ����� � �� �������� �� ���������� ������������.
SELECT COUNT(CASE WHEN Rating is null then 1 END)
FROM #TempMovies;

UPDATE #TempMovies  
SET     Rating =  'R'
WHERE Rating is null

-- ������������ ����������� ���������� runtime ������� ������� ��������� �� ���� �������
SELECT AVG(runtime)
FROM #TempMovies

UPDATE #TempMovies
SET runtime = 108
WHERE runtime is null

-- ��������� ������� � ������ ������� ����� �������� ����������� �� Released

UPDATE #TempMovies
SET country = 'United States'
WHERE Name like 'Clinton Road'

SELECT *
FROM #TempMovies

-- �������� ������ ������.


				
