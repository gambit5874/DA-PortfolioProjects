-- Nashville Housing Query list
-- Data cleaning - user friendly columns 


SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing


-- Standardize date
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing -- Didn't work :(
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address
SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


-- Fills in the NULL address from duplicated parcel ID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Individual address columns (address, city, state), Delimiter - separates columns
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing


-- Holds address update
ALTER TABLE NashvilleHousing
ADD PropertyAddressSplit nvarchar(255);

UPDATE NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCitySplit nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
-- New things go to the end of a table



-- Alternate method to substrings - parsename
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..NashvilleHousing


-- Owner address adds
ALTER TABLE NashvilleHousing
ADD OwnerAddySplit nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerCitySplit nvarchar(255);

UPDATE NashvilleHousing
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerStateSplit nvarchar(255);

UPDATE NashvilleHousing
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


-- Sold as vacant - make all Yes or No
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing


-- Remove dupes by checking specifics
WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID
	) row_num
FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



-- Delete unused columns
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


SELECT *
FROM PortfolioProject..NashvilleHousing