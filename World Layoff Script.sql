# USING THE WORLD LAYOFFS DATABASE
 USE world_layoffs;

 SELECT * FROM world_layoffs.layoffs;


# CREATING A STAGGING TABLE FOR LAYOFFS
 CREATE TABLE IF NOT EXISTS layoffs_staging 
 LIKE layoffs;
 INSERT INTO layoffs_staging 
 SELECT *
 FROM layoffs;

 SELECT * FROM layoffs_staging;
 
 
 # CHECKING FOR DUPLICATES
 WITH Duplicate_CTE AS(SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS ROW_NUM
 FROM layoffs_staging)
 SELECT *
 FROM Duplicate_CTE 
 WHERE ROW_NUM > 1;
 
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
  `ROW_NUM` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

 

INSERT INTO `layoffs_staging2`
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, total_laid_off, date, percentage_laid_off, industry, stage, funds_raised_millions, country) AS ROW_NUM
FROM layoffs_staging;
 
SELECT *
FROM layoffs_staging2
WHERE ROW_NUM > 1;

DELETE
FROM layoffs_staging2
WHERE ROW_NUM > 1;


# STANDARDIZING DATA
SELECT DISTINCT company
FROM layoffs_staging2
ORDER BY 1;

SELECT  company, char_length(company),TRIM(company), Char_length(TRIM(company))
FROM layoffs_staging2
WHERE company <> TRIM(company);

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2  
ORDER BY 1;

SELECT  industry, char_length(industry),TRIM(industry), Char_length(TRIM(industry))
FROM layoffs_staging2
WHERE industry <> TRIM(industry);

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

UPDATE layoffs_staging2
SET industry = "Crypto"
WHERE industry like "crypto%";

SELECT DISTINCT country
FROM layoffs_staging2  
ORDER BY 1;

UPDATE layoffs_staging2
SET country = "United States"
WHERE country like "United States%";

SELECT  country, char_length(country),TRIM(country), Char_length(TRIM(country))
FROM layoffs_staging2
WHERE country <> TRIM(country);

SELECT DISTINCT location
FROM layoffs_staging2  
ORDER BY 1;

SELECT  location, char_length(location),TRIM(location), Char_length(TRIM(location))
FROM layoffs_staging2
WHERE location <> TRIM(location);

 
# CHANGING  DATA TYPE OF REQUIRED COLUMNS
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` date;


# CHECKING FOR NULL OR BLANK VALUES
SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *  
FROM layoffs_staging2
WHERE company = "Airbnb" 
OR company = "Carvana";

UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';

SELECT *
FROM layoffs_staging2 L1
JOIN layoffs_staging2 L2
ON L1.company = L2.company
WHERE L1.industry IS NULL
AND L2.industry IS NOT NULL;

UPDATE layoffs_staging2 L1
JOIN layoffs_staging2 L2
ON L1.company = L2.company
SET L1.industry = L2.industry
WHERE L1.industry IS NULL
AND L2.industry IS NOT NULL;


DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


#REMOVING NOT REQUIRED COLUMNS
ALTER TABLE layoffs_staging2
DROP COLUMN ROW_NUM;







