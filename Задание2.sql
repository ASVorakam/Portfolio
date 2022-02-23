
WITH cte_con AS (
	SELECT (Откуда + '-' + Куда) as Направление,
			День,
			Поставщик,
			Стоимость
	FROM Test2)
	


SELECT Направление, Поставщик FROM
	(SELECT Направление, Поставщик, DENSE_RANK() OVER (PARTITION BY Направление ORDER BY Rank_Cnt DESC) Most_Profitable FROM
		(SELECT Направление, Поставщик, SUM(rank) OVER (PARTITION BY Направление, Поставщик ) Rank_Cnt FROM
			(SELECT Направление,
					День,
					Поставщик,
					sum(Стоимость) sum1,
					dense_rank() OVER (PARTITION BY Направление, День ORDER BY SUM(Стоимость) ASC) rank
					FROM cte_con
					GROUP BY Направление, День, Поставщик) a
			WHERE a.rank = 1) 
		 b)	
	c
WHERE Most_Profitable = 1
GROUP BY Направление, Поставщик


