/*

CLEANING DATA USING SQL QUERIES

*/

--------------------------------------------------------------------------------------------------------------------------


SELECT *
FROM NashvilleHousing


-- STANDARDIZE DATE FORMAT
--------------------------------------------------------------------------------------------------------------------------


SELECT saleDateConverted, CONVERT(Date,SaleDate)
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- POPULATE PROPERTY ADDRESS DATA
--------------------------------------------------------------------------------------------------------------------------


-- (Properites with same ParcelID have same PropertyAddress so values can be populated to the places where PropertyAddress is NULL)

SELECT a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress , b.PropertyAddress)
FROM NashvilleHousing AS a 
JOIN NashvilleHousing AS b 
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress)
FROM NashvilleHousing AS a 
JOIN NashvilleHousing AS b 
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (Address, City, State)
--------------------------------------------------------------------------------------------------------------------------


SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress , 1 , CHARINDEX(',', PropertyAddress) - 1) AS Address , 
SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing


-- BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMNS (Address, City, State)
--------------------------------------------------------------------------------------------------------------------------

SELECT 
PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 3) , 
PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 2) ,
PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 1)

SELECT *
FROM NashvilleHousing


-- CHANGE 0 AND 1 TO Yes AND No IN "SoldAsVacant" FIELD
--------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant Nvarchar(255);

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 1 THEN 'Yes'
     WHEN SoldAsVacant = 0 THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 1 THEN 'Yes'
     WHEN SoldAsVacant = 0 THEN 'No'
	 ELSE SoldAsVacant
	 END


-- DELETING DUPLICATE ROWS
--------------------------------------------------------------------------------------------------------------------------


WITH RowNumCTE AS (
   SELECT * , 
             ROW_NUMBER() OVER (
			 PARTITION BY ParcelID,
			              PropertyAddress,
						  SalePrice,
						  SaleDate,
						  LegalReference
						  ORDER BY
						         UniqueID
								 ) row_num
   FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-- DELETING UNUSED COLUMNS
--------------------------------------------------------------------------------------------------------------------------

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate