---1---
---What is the total number of parts per theme
SELECT * FROM analytics_main
SELECT theme_name, sum(num_parts) total_number_of_parts
FROM dbo.analytics_main
--WHERE parent_theme_name IS NOT NULL
GROUP BY theme_name
ORDER BY 2 DESC


---2---
---What is the total number of parts per year
SELECT year, sum(num_parts) total_number_of_parts
FROM dbo.analytics_main
--WHERE parent_theme_name IS NOT NULL
GROUP BY year
ORDER BY 2 DESC

---3---
---How many sets were created in each century in the dataset

SELECT Century, COUNT(set_num) as total_set_num
FROM dbo.analytics_main
---WHERE parent_theme_name IS NOT NULL
GROUP BY Century

---4---
---What percentage of sets ever realesed in the 21st Century were Trains Themed
;WITH cte AS
(
	SELECT Century, theme_name, COUNT(set_num) total_set_num
	FROM analytics_main
	WHERE Century = '21st_Century'
	GROUP BY Century, theme_name
)
SELECT SUM(total_set_num), sum(percentage)
FROM(
	SELECT Century, theme_name, total_set_num, SUM(total_set_num) OVER() as total, CAST(1.00 * total_set_num / SUM(total_set_num) OVER() as decimal(5, 4)) * 100 Percentage
	FROM cte )m
WHERE theme_name LIKE 'train%'


---5---
---What is the most popular theme by year in terms of sets released  in the 21 Century
SELECT year, theme_name, total_set_num
FROM (
	SELECT year, theme_name, COUNT(set_num) total_set_num, ROW_NUMBER() OVER (partition by year order by COUNT(set_num) DESC) rn
	FROM analytics_main
	WHERE Century = '21st_Century'
	GROUP BY year, theme_name
	)m
WHERE rn = 1
ORDER BY year DESC


---6---
---What is the most produced color of lego ever in terms of quantity of parts
SELECT color_name, SUM(quantity) as quantity_of_parts
FROM
     (
		SELECT INV.color_id, INV.inventory_id, INV.part_num, CAST(INV.quantity as numeric) quantity, INV.is_spare, C.name color_name, C.rgb, P.name part_name, P.part_material, PC.name Category_name
		FROM Rebrickable..inventory_parts INV
		INNER JOIN Rebrickable..colors C
			 ON INV.color_id = C.id
		INNER JOIN Rebrickable..parts P
			 ON INV.part_num = P.part_num
		INNER JOIN Rebricable..part_categories PC
			 ON INV.part_cat_id = pc.id
		) main
GROUP BY color_name
ORDER BY 2 DESC