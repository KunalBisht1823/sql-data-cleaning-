/*cleaning data in SQL query */

select*
from Nashvillehousing

--standerdise sales date 
select saledateconverted, convert(date,SaleDate)
from Nashvillehousing

update Nashvillehousing
set SaleDate = convert(date,SaleDate)

alter table Nashvillehousing 
add saledateconverted date 

update Nashvillehousing
set saledateconverted = convert(date,SaleDate)


--Populate property address data 

select *
from Nashvillehousing
--where PropertyAddress is null 
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from Nashvillehousing a
join Nashvillehousing  b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Nashvillehousing a
join Nashvillehousing  b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 


--Breaking Out address into Individual Column (Address, city, state)
select PropertyAddress
from Nashvillehousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from Nashvillehousing

alter table Nashvillehousing 
add PropertySplitAddresss Nvarchar(255)

update Nashvillehousing
set PropertySplitAddresss = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table Nashvillehousing 
add  PropertySplitCity Nvarchar(255)

update Nashvillehousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from Nashvillehousing

select 
parsename (replace (OwnerAddress,',','.'),3)
,parsename (replace (OwnerAddress,',','.'),2)
,parsename (replace (OwnerAddress,',','.'),1)
from Nashvillehousing

alter table Nashvillehousing 
add OwnerSplitAddresss Nvarchar(255)

update Nashvillehousing
set OwnerSplitAddresss = parsename (replace (OwnerAddress,',','.'),3)

alter table Nashvillehousing 
add  OwnerSplitCity Nvarchar(255)

update Nashvillehousing
set OwnerSplitCity = parsename (replace (OwnerAddress,',','.'),2)

alter table Nashvillehousing 
add  OwnerSplitState Nvarchar(255)

update Nashvillehousing
set OwnerSplitState = parsename (replace (OwnerAddress,',','.'),1)

select *
from Nashvillehousing


--Change Y and N to Yes and NO in "Sold as Vacant " field

select distinct(SoldAsVacant),count(SoldAsVacant)
from Nashvillehousing
group by SoldAsVacant
order by 2

select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'Yes'
	  else SoldAsVacant
	  end 
from Nashvillehousing

update Nashvillehousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'Yes'
	  else SoldAsVacant
	  end 

-- Remove duplicate 
with RowNumCTE As (
select *,
     ROW_NUMBER() Over (
	 Partition by ParcelID,
	              Propertyaddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  order by 
				  UniqueID
				  ) row_num 
				  
from Nashvillehousing
--order by ParcelID
)

Delete 
from RowNumCTE
where row_num > 1

--Delete unused column 

select *
from Nashvillehousing

alter table Nashvillehousing 
drop column PropertyAddress, TaxDistrict, OwnerAddress

alter table Nashvillehousing 
drop column SaleDate 