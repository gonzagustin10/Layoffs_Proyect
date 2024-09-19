-- Remove Duplicates

CREATE TABLE layoffs_staging
LIKE layoffs;

Select * From layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

Select *,
ROW_NUMBER() OVER(
PARTITION BY company,industry,total_laid_off, percentage_laid_off, `date`) AS row_num
From layoffs_staging;

WITH duplicate_cte AS
(
Select *,
ROW_NUMBER() OVER(
PARTITION BY company, location 
,industry,total_laid_off, percentage_laid_off, `date`, stage
,country, funds_raised_millions) AS row_num
From layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num>1;

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
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
Select *, 
ROW_NUMBER() OVER(
PARTITION BY company, location 
,industry,total_laid_off, percentage_laid_off, `date`, stage
,country, funds_raised_millions) AS row_num
From layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Stardarzizing Data

SELECT company,TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT (industry)
FROM layoffs_staging2
ORDER BY (industry) ASC;

UPDATE layoffs_staging2
SET industry = "Crypto"
WHERE industry LIKE "Crypto%";

SELECT * FROM layoffs_staging2
WHERE industry LIKE "Crypto%";

SELECT DISTINCT country 
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = "United States"
WHERE country LIKE "United States.%";

SELECT `date`,
STR_TO_DATE(`date`, "%m/%d/%Y")
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, "%m/%d/%Y");

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Look at null values and see what 

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry ="";

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT * FROM layoffs_staging2
WHERE industry IS NULL 
or industry ="";

SELECT * FROM layoffs_staging2
WHERE company = "Airbnb";

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = "")
AND t2.industry IS NOT NULL;  

-- remove any columns and rows we need to  

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;