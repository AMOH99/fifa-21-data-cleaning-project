the data set is available here kaggle datasets download -d yagunnersya/fifa-21-messy-raw-dataset-for-cleaning-exploring

	
	--DATA CLEANING(FIFA 21 DATASET)

SELECT COUNT(*)
  FROM [fifadatacleaning].[dbo].[fifa21_raw_datav2]


  SELECT * 
FROM fifa21_raw_datav2;


--checking for duplicates

SELECT LongName,
		 Nationality,
		 Age,
		 Club,
		 count(*) as count
FROM fifa21_raw_datav2
Group BY  LongName,
		 Nationality,
		 Age,
		 Club
HAVING count(*) > 1;

SELECT *
FROM fifa21_raw_datav2
WHERE LongName = 'Peng Wang'

-- cheking for null values in the datatset 

SELECT *
from fifa21_raw_datav2
WHERE  LongName IS NULL OR
         photoUrl IS NULL OR
		 playerUrl IS NULL OR
		 Nationality IS NULL OR
		 Age IS NULL OR
		 Club IS NULL;

 SELECT *
FROM fifa21_raw_datav2;

-- removing excess space in the club column

select  distinct(Club)
from fifa21_raw_datav2
order by Club;

update fifa21_raw_datav2
set Club = TRIM(Club);


select  Club
from fifa21_raw_datav2
ORDER BY Club;


-- clean and divide the contract column into two contract start and contract end

Select distinct(contract)
from fifa21_raw_datav2;

-- replace '~' WITH '-'

UPDATE fifa21_raw_datav2
SET Contract = replace(contract, '~', '-');

-- extract the year from contract e.g (Dec 30, 2020 On Loan)

update fifa21_raw_datav2
 set Contract = SUBSTRING(contract, 9, 4)
 where Contract like '%On%';

 -- CREATE column contract start and contract end

 alter table fifa21_raw_datav2
 add ContractStart varchar(50);
 
 update fifa21_raw_datav2
 set ContractStart = SUBSTRING(contract, 1, 4);

 alter table fifa21_raw_datav2
 add ContractEnd varchar(50);

 update fifa21_raw_datav2
 set ContractEnd = SUBSTRING(contract, 8, 4);

-- cleaning the height column into cm from e.g (6'2")

 select distinct(Height)
 from fifa21_raw_datav2;


select Height, SUBSTRING(height, 1, CHARINDEX('''', height)-1), TRY_CONVERT(SUBSTRING(height, 1, CHARINDEX('''', height)-1))*30.48
 FROM fifa21_raw_datav2
 where Height like '%''%"';
 

 update fifa21_raw_datav2
 SET height = CASE 
        WHEN height LIKE '%''%"' THEN 
            TRY_CONVERT(DECIMAL(10,2), SUBSTRING(height, 1, CHARINDEX('''', height)-1))*30.48 + 
            TRY_CONVERT(DECIMAL(10,2), SUBSTRING(height, CHARINDEX('''', height)+1, LEN(height)-CHARINDEX('''', height)-1))*2.54 
        WHEN height LIKE '%"' THEN TRY_CONVERT(DECIMAL(10,2), SUBSTRING(height, 1, LEN(height) - 2)) * 2.54 
        ELSE TRY_CONVERT(DECIMAL(10,2), SUBSTRING(height, 1, LEN(height) - 2)) 
    END;

alter table fifa21_raw_datav2
alter column Height float;

-- cleaning the weight column and convert into kgs


update fifa21_raw_datav2
set Weight = CASE 
WHEN Weight like '%lbs%' THEN
  TRY_CONVERT(DECIMAL(10,2), SUBSTRING(Weight, 1, 3)) * 0.453592
 ELSE TRY_CONVERT(DECIMAL(10,2), SUBSTRING(Weight, 1, LEN(Weight) - 2))
END
from fifa21_raw_datav2;

alter table fifa21_raw_datav2
alter column Weight float;

select distinct(Weight)
from fifa21_raw_datav2



--- cleaning the value wage and Realease_clause columns e.g $103.5M

select value, Wage, Release_clause
from fifa21_raw_datav2

--- Removing the(.)sign in the columns

update fifa21_raw_datav2
set Value = REPLACE(value, '', ' ')

update fifa21_raw_datav2
set Wage = REPLACE(Wage, '', ' ')


update fifa21_raw_datav2
set Release_clause = Replace(Release_clause, '', ' ')


-- removing the M and K in the corresponding columns

update fifa21_raw_datav2
SET value = (select
CASE
    WHEN value LIKE '% %' THEN REPLACE(value, 'M', '00000')
    WHEN value LIKE '%K' THEN REPLACE(value, 'K', '000')
	WHEN value LIKE '%M' THEN REPLACE(value, 'M', '000000')
 ELSE value End as Player_Value)

 --Replace the "K" and "M" with their corresponding zeros in the Wage column
UPDATE fifa21_raw_datav2
SET Wage = 
 (SELECT CASE
   WHEN Wage LIKE '% %' THEN REPLACE( Value, 'M', '00000')
   WHEN Wage LIKE '%K' THEN REPLACE( Value, 'K', '000')
   WHEN Wage LIKE '%M' THEN REPLACE( Value, 'M', '000000')
   ELSE Wage END AS Player_Wage);

--Replace the "K" and "M" with their corresponding zeros in the Release_Clause column
UPDATE fifa21_raw_datav2
SET Release_Clause = 
 (SELECT CASE
   WHEN Release_Clause LIKE '% %' THEN REPLACE( Value, 'M', '00000')
   WHEN Release_Clause LIKE '%K' THEN REPLACE( Value, 'K', '000')
   WHEN Release_Clause LIKE '%M' THEN REPLACE( Value, 'M', '000000')
   ELSE Release_Clause END AS Release_Clause);

----- REMOVING the dollar sign

update fifa21_raw_datav2
SET value = SUBSTRING(value, 2, len(value) - 1);

update fifa21_raw_datav2
SET Wage = SUBSTRING(Wage, 2, len(value) - 1);

update fifa21_raw_datav2
SET Release_Clause = SUBSTRING(Release_Clause, 2, LEN(Release_Clause) - 1);

--- cleaning the W_F, SM, IR

SELECT W_F, SM, IR
From fifa21_raw_datav2

-- remove the special signs

Update fifa21_raw_datav2
SET W_F = SUBSTRING(W_F, 1, 1)

UPDATE fifa21_raw_datav2
SET SM = SUBSTRING(SM, 1, 1)

UPDATE fifa21_raw_datav2
SET IR = SUBSTRING(IR, 1, 1)

-- Convert to integers

ALTER TABLE fifa21_raw_datav2
ALTER COLUMN W_F INT;

ALTER TABLE fifa21_raw_datav2
ALTER COLUMN SM INT;

ALTER TABLE fifa21_raw_datav2
ALTER COLUMN IR INT;

--THE DATA IS NOW READY FOR ANALYSIS

Select *
From fifa21_raw_datav2
