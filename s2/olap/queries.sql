-- Динамика количества въездов по месяцам
SELECT 
    dd.year,
    dd.month,
    COUNT(f.fact_id) AS entries_count,
    SUM(CASE WHEN f.has_criminal_record THEN 1 ELSE 0 END) AS entries_with_criminal_record
FROM olap.fact_entries f
JOIN olap.dim_date dd ON f.date_id = dd.date_id
GROUP BY dd.year, dd.month
ORDER BY dd.year, dd.month;

-- Топ-5 самых популярных видов деятельности среди въезжающих
SELECT 
    da.activity_description,
    COUNT(f.fact_id) AS activity_count,
    ROUND(COUNT(f.fact_id) * 100.0 / NULLIF(COUNT(*) OVER(), 0), 2) AS share_percent
FROM olap.fact_entries f
JOIN olap.dim_activity da ON f.activity_id = da.activity_id
WHERE f.has_work_permission = TRUE
GROUP BY da.activity_description
ORDER BY activity_count DESC
LIMIT 5;

-- Профиль въезжающего по странам (багаж + конверсия в документы)
SELECT 
    dc.country_name,
    COUNT(f.fact_id) AS total_entries,
    ROUND(AVG(f.luggage_items_count), 2) AS avg_luggage_items,
    ROUND(SUM(CASE WHEN f.has_work_permission THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(f.fact_id), 0), 2) AS work_perm_conversion_pct,
    ROUND(SUM(CASE WHEN f.has_diplomat_cert THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(f.fact_id), 0), 2) AS diplomat_cert_conversion_pct
FROM olap.fact_entries f
JOIN olap.dim_country dc ON f.country_id = dc.country_id
GROUP BY dc.country_name
ORDER BY total_entries DESC;