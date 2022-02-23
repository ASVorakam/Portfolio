--Задание 1.1
SELECT  Направление,
		Поиски,
		Сегменты,
		ROUND(CAST(Поиски as int)/CAST(Сегменты as int), 2) as L2B_MOW
		FROM Test1
WHERE Направление like '%MOW%' and Сегменты <> 0

--Задание 1.2
SELECT  TOP 3 CODE,
		SUM(CAST(L2B as int)) as sum1 
		FROM (SELECT PARSENAME(REPLACE(Направление, '-', '.'), 2) as CODE,
					 L2B
					 FROM Test1
					 UNION ALL
			  SELECT PARSENAME(REPLACE(Направление, '-', '.'), 1) as CODE,
					 L2B
					 FROM Test1
			) t
GROUP BY CODE ORDER BY sum1 desc