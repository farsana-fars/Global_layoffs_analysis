#data cleaning 

#remove duplicates
#standardize data
#null values and blank values
#remove any columns.


SELECT*
from layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;


INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *,
ROW_NUMBER() OVER( PARTITION BY company,industry,total_laid_off,percentage_laid_off,`date`) AS row_num
FROM layoffs_staging;

WITH duplicate_CTE AS
(
SELECT *,
ROW_NUMBER() OVER( PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT*
FROM duplicate_CTE 
WHERE row_num > 1 ;


SELECT *

FROM layoffs_staging
WHERE company = 'Casper';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT  into layoffs_staging2
SELECT *,
ROW_NUMBER() OVER( PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE  row_num > 1;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;


SELECT *
FROM layoffs_staging2;


#standardize data 

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry 
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States.' ;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States.' ;


SELECT 	`date`,
STR_TO_DATE (`date`, '%m/%d/%Y' )
FROM layoffs_staging2;



SELECT 	`date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');



ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;


#null and blank values:

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL and percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = ''
;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL or industry ='';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT t1.industry,t2.industry
FROM layoffs_staging2 as t1
JOIN layoffs_staging2 as t2
 ON t1.company = t2.company
WHERE (t1.industry IS NULL OR  t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 as t1
JOIN layoffs_staging2 as t2
   ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT DISTINCT industry
FROM layoffs_staging2; 

SELECT *
FROM layoffs_staging2; 


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL and percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL and percentage_laid_off IS NULL;


SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

#Exploratory data analysis

SELECT MAX(total_laid_off)
FROM layoffs_staging2;

SELECT company,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company ORDER BY 2 desc;

SELECT MAX(`date`),MIN(`date`)
FROM layoffs_staging2;

SELECT industry,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry ORDER BY 2 desc;


SELECT country,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country order by 2 desc;

SELECT YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY  YEAR(`date`)
ORDER BY 1;

SELECT stage,SUM(total_laid_off)
FROM layoffs_staging2
group by stage
order by 2 desc;

SELECT *
from layoffs_staging2;

SELECT SUBSTRING(`date`,1,7) as month,SUM(total_laid_off)
from layoffs_staging2
where SUBSTRING(`date`,1,7) is not null
group by month
order by 1 ;

WITH rolling_total as
(
SELECT SUBSTRING(`date`,1,7) as month,SUM(total_laid_off) as tlf
from layoffs_staging2
where SUBSTRING(`date`,1,7) is not null
group by month
order by 1 )
SELECT month,tlf,SUM(tlf) over(order by month)
FROM rolling_total;


SELECT company,YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company ,YEAR(`date`)
ORDER BY 3 DESC;










WITH company_year (company,years,total_laid_off) AS
(
SELECT company,YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company ,YEAR(`date`)
),Company_year_rank AS 
(
SELECT * ,dense_rank() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL 
)
SELECT *
FROM Company_year_rank
WHERE ranking <=5
;







