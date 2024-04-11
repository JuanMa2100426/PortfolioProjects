
--Cleaning Data in SQL Queries

SELECT *
from PortfolioProject..NashvilleHousing

-- Standardize Date Format

SELECT salesdateconverted, CONVERT(date, SaleDate)
from PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SalesDateConverted Date;

UPDATE NashvilleHousing
SET SalesDateConverted = CONVERT(date, SaleDate)

-- Populate Property Address data

SELECT *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is NULL
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as address2

from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
from PortfolioProject..NashvilleHousing

--Breaking out OwnerAddress into Individual Columns easyway

SELECT OwnerAddress
from PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
from PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" 

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' then 'Yes'
     When SoldAsVacant = 'N' then 'No'
     ELSE SoldAsVacant
     END
from PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
     When SoldAsVacant = 'N' then 'No'
     ELSE SoldAsVacant
     END

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
   ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
                 UniqueID
                 ) RowNumber
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where RowNumber > 1
order by PropertyAddress

-- Delete Unused Columns

SELECT *
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

--end--