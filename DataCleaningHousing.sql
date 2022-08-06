Select *
from HousingProject..Housing

-------------------------------------------------------------

--Standardize Date Format

select SaleDateConverted, CONVERT(Date, SaleDate)
from HousingProject..Housing

ALTER TABLE Housing
Add SaleDateConverted Date;


Update Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)


----------------------------------------------------------------------------------------------------------------------------------------------------------

--Update PropertyAddress Data where NULL since houses with Similar ParcelID has similar PropertyAddress

select [UniqueID ], ParcelID, PropertyAddress
from HousingProject..Housing
where PropertyAddress is NUll
order by ParcelID

select  a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from HousingProject..Housing a
join
HousingProject..Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NUll


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from HousingProject..Housing a
join
HousingProject..Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NUll


----------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking the PropertyAddress into individual columns (Address, City and State)

select PropertyAddress
from HousingProject..Housing

select SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) AS PropertySplitAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress)) AS City
from HousingProject..Housing

ALTER TABLE  Housing
ADD PropertySplitAddress nvarchar(255);

UPDATE Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Housing
ADD City nvarchar(100);

UPDATE Housing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress))


--Splitting Owner Address

select PARSENAME(REPLACE(OwnerAddress,',', '.'), 3) AS OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2) AS OwnerCity,
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1) AS OwnerState
from HousingProject..Housing

ALTER TABLE housing
ADD OwnerSplitAddress nvarchar(255);

UPDATE Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)


ALTER TABLE housing
ADD OwnerCity nvarchar(255);

UPDATE Housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE housing
ADD OwnerState nvarchar(100);

UPDATE Housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

select *
from HousingProject..Housing




----------------------------------------------------------------------------------------------------------------------------------------------------------


---Change Y and N to Yes and No in 'SoldasVacant' field

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from HousingProject..Housing
group by SoldAsVacant                           
order by 2

select SoldAsVacant
 ,CASE
    when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
END
from HousingProject..Housing

UPDATE Housing
SET SoldAsVacant = CASE
    when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
END




----------------------------------------------------------------------------------------------------------------------------------------------------------

---Remove Duplication

WITH RowNumRankCTE AS (

select ParcelID, PropertyAddress,SalePrice, SaleDate, LegalReference,
      ROW_NUMBER() OVER (
	  partition by ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY ParcelID) row_numrank

from HousingProject..Housing
)

--I first deleted the records where row_numrank> 1 using the CTE hence getting rid of the duplicates
   --DELETE
   --from RowNumRankCTE
   --where row_numrank > 1

select *
from RowNumRankCTE
where row_numrank > 1 --shows that the duplicates are deleted





----------------------------------------------------------------------------------------------------------------------------------------------------------


---Delete Unused Columns

select * 
from HousingProject..Housing

ALTER TABLE HousingProject..Housing
DROP COLUMN OwnerAddress,SaleDate, TaxDistrict, PropertyAddress


