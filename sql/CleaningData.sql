/*

cleaning data in sql queries

*/

select *
from NashvileHousing

----------------------------------------------------------------------------------------------------------------------------
-- Standardize Data Format

select SaleDateConverted
from NashvileHousing

Update NashvileHousing
SET SaleDate =  CONVERT(date, SaleDate)

alter table NashvileHousing
add SaleDateConverted Date;

Update NashvileHousing
SET SaleDateConverted =  CONVERT(date, SaleDate)


----------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data

select *
from NashvileHousing
where PropertyAddress is null
order by ParcelID

select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
from NashvileHousing as A
join NashvileHousing as B
on A.ParcelID = B.ParcelID and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null

update A
set PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
from NashvileHousing as A
join NashvileHousing as B
on A.ParcelID = B.ParcelID and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null


----------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Colums (Address, City, State)

select PropertyAddress
from NashvileHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from NashvileHousing


alter table NashvileHousing
add PropertySplitAddress Nvarchar(255);

Update NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)


alter table NashvileHousing
add PropertySplitCity Nvarchar(255);

Update NashvileHousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

select *
from NashvileHousing





select OwnerAddress
from NashvileHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from NashvileHousing

alter table NashvileHousing
add OwnerSplitAddress Nvarchar(255);

Update NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


alter table NashvileHousing
add OwnerSplitCity Nvarchar(255);

Update NashvileHousing
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

alter table NashvileHousing
add OwnerSplitState Nvarchar(255);

Update NashvileHousing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

select *
from NashvileHousing

----------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in Sold as Vacant field


select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvileHousing
group by SoldAsVacant
order by 2


select case 
	when SoldAsVacant = 'Y' then 'Yes' 
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from NashvileHousing


update NashvileHousing
set SoldAsVacant = 
case 
	when SoldAsVacant = 'Y' then 'Yes' 
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end



----------------------------------------------------------------------------------------------------------------------------
-- remove duplicates

with rowNumCTE as (
select *,
	ROW_NUMBER() over (
		partition by parcelID,
					propertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
		order by UniqueID

	) row_num
from NashvileHousing
)
delete
from rowNumCTE
where row_num > 1


----------------------------------------------------------------------------------------------------------------------------
-- delete unused columns


select *
from NashvileHousing


alter table NashvileHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvileHousing
drop column SaleDate

















