/****** Script for SelectTopNRows command from SSMS  ******/


-- CLEANING DATA IN SQL QUERIES

select *
from portfolioproject.dbo.NashvilleHousing 

-- STANDARDIZE DATE FORMAT
SELECT SaleDateConverted, CONVERT(Date, SaleDate) 
FROM portfolioproject.dbo.NashvilleHousing 

UPDATE portfolioproject.dbo.NashvilleHousing
SET SaleDate= CONVERT(Date, SaleDate);

-- ALTER TABLE statement
ALTER TABLE portfolioproject.dbo.NashvilleHousing
ADD SaleDateConverted Date;

-- UPDATE statement
UPDATE portfolioproject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM portfolioproject.dbo.NashvilleHousing 
--WHERE PropertyAddress is null 
ORDER BY ParcelID

-- this joins the table to itself where the ParcelID is the same but it is not the same row i.e different unique id. 
-- purpose of this it identify rows with the same parcel ID because same parcel id corresponds to the same property address. This will be used to populate the Null property address

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolioproject.dbo.NashvilleHousing a
JOIN portfolioproject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- N.B: This part of the above code "ISNULL(a.PropertyAddress, b.PropertyAddress)" is used to populate(replace) the Null property address in a with the property address in b

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolioproject.dbo.NashvilleHousing a
JOIN portfolioproject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
SELECT PropertyAddress
FROM portfolioproject.dbo.NashvilleHousing
--WHERE PropertyAddress is null 
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM [portfolioproject].[dbo].[NashvilleHousing] 

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

-- UPDATE statement

UPDATE portfolioproject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

-- UPDATE statement
UPDATE portfolioproject.dbo.NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) ;


SELECT *
FROM portfolioproject.dbo.NashvilleHousing 

--Another easier way to do this by using parsename instead of substring



SELECT OwnerAddress
FROM portfolioproject.dbo.NashvilleHousing 

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
FROM portfolioproject.dbo.NashvilleHousing 

-- an interesting thing about parse name is it separate things backwards, so to have the address in the right order we use 3 2 1 instead of 1 2 3
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM portfolioproject.dbo.NashvilleHousing 


ALTER TABLE portfolioproject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE portfolioproject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE portfolioproject.dbo.NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE portfolioproject.dbo.NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM portfolioproject.dbo.NashvilleHousing 



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD
SELECT DISTINCT(SoldAsVacant), count(SoldAsVacant)
FROM portfolioproject.dbo.NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2

-- using a case statement for this is similar to an if, else statement in python
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THen 'Yes'
	 WHEN SoldAsVacant = 'N' THen 'No'
	 ELSE SoldAsVacant
	 END
FROM portfolioproject.dbo.NashvilleHousing 

UPDATE portfolioproject.dbo.NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THen 'Yes'
	 WHEN SoldAsVacant = 'N' THen 'No'
	 ELSE SoldAsVacant
	 END


-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- REMOVE DUPLICATES

WITH ROWNUMCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 )row_num

FROM portfolioproject.dbo.NashvilleHousing 
--ORDER BY ParcelID
)

SELECT *
FROM ROWNUMCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--SELECT *
--FROM portfolioproject.dbo.NashvilleHousing 


----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS

ALTER TABLE portfolioproject.dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT *
FROM portfolioproject.dbo.NashvilleHousing 


ALTER TABLE portfolioproject.dbo.NashvilleHousing 
DROP COLUMN SaleDate


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------