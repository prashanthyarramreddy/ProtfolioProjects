SELECT 
    *
FROM
    PortfolioProject.nashvillehousing;



-- Standardising Date Format

SET lc_time_names = 'en_US';
SELECT 
    SaleDate,
    STR_TO_DATE(SaleDate, '%M %d, %Y') AS ConvertedDate
FROM
    PortfolioProject.nashvillehousing;

alter table nashvillehousing
add ConvertedDate date;


UPDATE nashvillehousing 
SET 
    ConvertedDate = STR_TO_DATE(SaleDate, '%M %d, %Y');


-- Breakin out Address into Individual Columns(State, City, address)

SELECT 
    PropertyAddress
FROM
    PortfolioProject.nashvillehousing
;

SELECT 
    SUBSTRING(PropertyAddress,
        1,
        LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress,
        LOCATE(',', PropertyAddress) + 1,
        LENGTH(PropertyAddress)) AS Address
FROM
    PortfolioProject.nashvillehousing;


alter table nashvillehousing
add PropertySplitAddress char;
UPDATE nashvillehousing 
SET 
    PropertySplitAddress = SUBSTRING(PropertyAddress,
        1,
        LOCATE(',', PropertyAddress) - 1);


alter table nashvillehousing
modify  PropertySplitCity varchar(100);
UPDATE nashvillehousing 
SET 
    PropertySplitCity = SUBSTRING(PropertyAddress,
        LOCATE(',', PropertyAddress) + 1,
        LENGTH(PropertyAddress));

-- OWNER ADDRESS BREAKDOWN

SELECT 
    OwnerAddress
FROM
    PortfolioProject.nashvillehousing;

SELECT 
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)) AS street_address,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
                ',',
                - 1)) AS city,
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', - 1)) AS state
FROM
    PortfolioProject.nashvillehousing;


alter table nashvillehousing
modify OwnerSplitAddress varchar(1000);
UPDATE nashvillehousing 
SET 
    OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1));


alter table nashvillehousing
add OwnerSplitCity varchar(1000);
UPDATE nashvillehousing 
SET 
    OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
                ',',
                - 1));


alter table nashvillehousing
add OwnerSplitState varchar(1000);
UPDATE nashvillehousing 
SET 
    OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', - 1));



-- CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD

SELECT DISTINCT
    (SoldAsVacant), COUNT(SoldAsVacant)
FROM
    PortfolioProject.nashvillehousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant;



SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldasVacant
    END
FROM
    PortfolioProject.nashvillehousing;
    
UPDATE nashvillehousing 
SET 
    SoldasVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldasVacant
    END;




-- Remove Duplicating

 select 
 row_number() over(
 partition by ParcelID,
			  PropertyAddress,
              SalePrice,
              SaleDate,
              LegalReference
              ORDER BY  UniqueID) row_num
 
 FROM
    PortfolioProject.nashvillehousing ;

CREATE TEMPORARY TABLE TempRowNumbers AS
SELECT 
    UniqueID,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, 
                     PropertyAddress, 
                     SalePrice, 
                     SaleDate, 
                     LegalReference 
        ORDER BY UniqueID
    ) AS row_num
FROM PortfolioProject.nashvillehousing;

UPDATE PortfolioProject.nashvillehousing AS nh
JOIN TempRowNumbers AS trn ON nh.UniqueID = trn.UniqueID
SET nh.row_num = trn.row_num;
 DROP TEMPORARY TABLE TempRowNumbers;


-- Delete Unused Columns not advisable in original data just to use in your copy of date  NOT ADVISABLE

ALTER TABLE  PortfolioProject.nashvillehousing 
DROP COLUMN PropertyAddress ;
ALTER TABLE  PortfolioProject.nashvillehousing 
DROP COLUMN OwnerAddress ;
ALTER TABLE  PortfolioProject.nashvillehousing 
DROP COLUMN TaxDistrict ;
ALTER TABLE  PortfolioProject.nashvillehousing 
DROP COLUMN SaleDate ;

select *
from PortfolioProject.nashvillehousing;