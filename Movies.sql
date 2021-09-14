

--Данный датасет был взят с Kaggle. Содержит в себе информацию о фильмах с 1980 по 2021. Общее кол-во строк - 7668.
--Задача: отчистить данные используя SQL для визуализации в tableau

SELECT *
FROM PortfolioProject..Movies;

--Проверим данные на пропущенные значения. StackOverflow предлагает совсем уж замудренные решения такой задачи, я же проверю пропущенные значения руками

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

-- 2247 строчек с хотя бы одним пропущенным значением. Посмотрев на запрос, визуально можно определить, что основную долю пропущенных значений занимает
-- колонка budget. Посчитаем кол-во этих значений.

SELECT SUM(CASE WHEN budget is null THEN 1 ELSE 0 END) AS NumberOfNullValues
     ,COUNT(budget) AS NumberOfNonNullValues
FROM PortfolioProject..Movies;

-- 2171 значение пропущено.
-- Изменять данные в исходной базе запрещено, потому создадим временную таблицу-копию для отчистки.

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

-- При проверке временной таблицы заметил, что значения колонки Year не всегда совпадают с годом выпуска фильма в колонке Released.
-- Добавим новую колонку с исправленным годом

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

-- Так же создадим отдельные колонки для месяца и дня выпуска


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


-- Изменим колонку Released, убрав ненужные упоминания страны выпуска для последующей удобной визуализации временного ряда. Воспользуемся уже готовыми столбцами.

SELECT CASE WHEN CHARINDEX('-', YearSplit + '.' + MonthSplit + '.' + DaySplit) >= 1 THEN '0'
            ELSE TRIM(YearSplit) + '.' + TRIM(MonthSplit) + '.' + TRIM(DaySplit) END
FROM #TempMovies;


UPDATE #TempMovies
SET Released = CASE WHEN CHARINDEX('-', YearSplit + '.' + MonthSplit + '.' + DaySplit) >= 1 THEN '0'
                    ELSE TRIM(YearSplit) + '.' + TRIM(MonthSplit) + '.' + TRIM(DaySplit) END

SELECT *
FROM #TempMovies;

-- Теперь предстоит разобраться с пропущенными значениями в данных. Цифры в колонке budget имеют весьма большое среднекваратичное отклонение (41457296,6),
-- поэтому заполнить 2171 ячейку медианным или средним значением не подходящий вариант.
-- Из нескольких способов решения данной задачи (web scraping, предсказание значений), наиболее быстрый - удаление пропущенных значений.

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

-- Позиции с пропущенным rating можно заполнить рейтингом R - он встречается чаще всего и не повлияет на дальнейшую визуализацию.
SELECT COUNT(CASE WHEN Rating is null then 1 END)
FROM #TempMovies;

UPDATE #TempMovies
SET     Rating =  'R'
WHERE Rating is null

-- Единственный пропущенный показатель runtime заменим средним значением по всей колонке
SELECT AVG(runtime)
FROM #TempMovies

UPDATE #TempMovies
SET runtime = 108
WHERE runtime is null

-- Последнюю строчку с пустой страной можно заменить информацией из Released

UPDATE #TempMovies
SET country = 'United States'
WHERE Name like 'Clinton Road'

SELECT *
FROM #TempMovies

-- Отчистка данных готова.


				
