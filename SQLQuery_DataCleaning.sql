/*

Cleaning Data with SQL Queries

*/


SELECT *
FROM [Nashville Housing Data for Data Cleaning]

------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate
FROM [Nashville Housing Data for Data Cleaning]

UPDATE [Nashville Housing Data for Data Cleaning]
SET SaleDate = CONVERT(Date, SaleDate)

------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM [Nashville Housing Data for Data Cleaning]
WHERE PropertyAddress IS NULL 
    
-- this shows us there are many empty addresses in the dataset; we will fill them in using the addresses of listings with the same ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
    ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing Data for Data Cleaning] a
JOIN [Nashville Housing Data for Data Cleaning] b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing Data for Data Cleaning] a
JOIN [Nashville Housing Data for Data Cleaning] b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM [Nashville Housing Data for Data Cleaning]

SELECT 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM [Nashville Housing Data for Data Cleaning]

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD PropertySplitAddress NVARCHAR(255)

UPDATE [Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD PropertySplitCity NVARCHAR(255)

UPDATE [Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT * 
FROM [Nashville Housing Data for Data Cleaning]


-- splitting owner's address
SELECT OwnerAddress 
FROM [Nashville Housing Data for Data Cleaning]

SELECT
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Nashville Housing Data for Data Cleaning]



ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE [Nashville Housing Data for Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD OwnerSplitCity NVARCHAR(255)

UPDATE [Nashville Housing Data for Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD OwnerSplitState NVARCHAR(255)

UPDATE [Nashville Housing Data for Data Cleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM [Nashville Housing Data for Data Cleaning]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
 CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM [Nashville Housing Data for Data Cleaning]

UPDATE [Nashville Housing Data for Data Cleaning]
 SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END

------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY ParcelID,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
                        ORDER BY 
                            UniqueID
        ) row_num
    FROM [Nashville Housing Data for Data Cleaning]
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


WITH RowNumCTE AS(
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY ParcelID,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
                        ORDER BY 
                            UniqueID
        ) row_num
    FROM [Nashville Housing Data for Data Cleaning]
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1


SELECT * 
FROM [Nashville Housing Data for Data Cleaning]

------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM [Nashville Housing Data for Data Cleaning]

ALTER TABLE [Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate