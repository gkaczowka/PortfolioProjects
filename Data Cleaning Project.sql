SELECT *
FROM Portfolioproject..Nashville


-- Standarize Date Format

--#1
--SELECT SaleDate, CONVERT(Date,SaleDate)
--FROM PortfolioProject..Nashville

--#2
ALTER TABLE Portfolioproject..Nashville
ALTER COLUMN SaleDate date

-- Populate Property Address Data

SELECT a.ParcelID, a.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville a
JOIN PortfolioProject..Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville a
JOIN PortfolioProject..Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

-- Breaking out Property Address into Indiviudal Columns (Address, City, State)
--#1

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject..Nashville

ALTER TABLE PortfolioProject..Nashville
ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject..Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject..Nashville
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject..Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- Breaking out Address into Onwer Address Columns (Address, City, State)
--#2

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) as State
FROM PortfolioProject..Nashville

ALTER TABLE PortfolioProject..Nashville
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject..Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE PortfolioProject..Nashville
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject..Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE PortfolioProject..Nashville
ADD OwnerSplitState nvarchar(255);

UPDATE PortfolioProject..Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

-- Change Y and N to Yes and No in "SoldAsVacant"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Nashville
GROUP BY SoldAsVacant

--#1

UPDATE PortfolioProject..Nashville
SET SoldAsVacant = 'Yes'
WHERE SoldAsVacant = 'Y'

UPDATE PortfolioProject..Nashville
SET SoldAsVacant = 'No'
WHERE SoldAsVacant = 'N'

--#2

UPDATE Portfolioproject..Nashville
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant 
	END

-- Remove Duplicates

WITH RowNUMCTE as (
 SELECT *,
 ROW_NUMBER() OVER (
 PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			ParcelID
			) row_num
FROM Portfolioproject..Nashville
)
DELETE
FROM RowNUMCTE
WHERE row_num > 1


--Delete Unused Columns


ALTER TABLE PortfolioProject..Nashville
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProject..Nashville
DROP COLUMN SaleDate