select * from NashvilleHousing

--STANDARDIZE DATE
select CONVERT(date, SaleDate) as convertedDate  from NashvilleHousing

alter table nashvillehousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

select saledate, saledateconverted from NashvilleHousing


--POPULATE ADDRESS DATA
select * from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
from NashvilleHousing a
join NashvilleHousing b on
a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b on
a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--BREAK ADDRESS INTO INDUVIDUAL COLUMNS
select substring(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1) as Address ,
substring(propertyaddress, charindex(',',PropertyAddress) + 1, len(propertyaddress)) as City
from NashvilleHousing

alter table nashvillehousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set propertysplitaddress = substring(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table nashvillehousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set propertysplitcity = substring(propertyaddress, charindex(',',PropertyAddress) + 1, len(propertyaddress))


select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

alter table nashvillehousing
add OwnerSplitAddress nvarchar(255)

alter table nashvillehousing
add OwnerSplitCity nvarchar(255)

alter table nashvillehousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

update NashvilleHousing
set OwnerSplitcity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--CHANGING Y AND N TO YES AND NO IN "SoldasVacant" FIELD

select distinct(soldasvacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select soldasvacant,
case 
  when soldasvacant = 'Y' then 'Yes'
  when soldasvacant = 'N' then 'No'
  else soldasvacant
end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case 
  when soldasvacant = 'Y' then 'Yes'
  when soldasvacant = 'N' then 'No'
  else soldasvacant
end


--REMOVING DUPLICATES
with RowNumCTE as 
(
  select *, 
  ROW_NUMBER() over (
  partition by parcelid,
               propertyaddress,
			   saleprice,
			   saledate,
			   legalreference
			   order by uniqueid
			   ) as rownum
from NashvilleHousing
--order by parcelid
)

select * from RowNumCTE
where rownum > 1
order by PropertyAddress



--DELETE UNUSED COLUMNS

alter table nashvillehousing
drop column propertyaddress, saledate, owneraddress, taxdistrict