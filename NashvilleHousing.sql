-- cleaning data in sql

select * from PortfolioProject..NashvilleHousing

select SaleDateConverted, convert(date, SaleDate)
from portfolioProject..NashvilleHousing

--update NashvilleHousing 
--set SaleDate = convert(date, SaleDate)

alter table NashvilleHousing 
add SaleDateConverted Date;

update NashvilleHousing 
set SaleDateConverted = convert(date, SaleDate)

--populate property address data

select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a. PropertyAddress is null

update a 
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a. PropertyAddress is null


--breaking address into individual cols(address, city, state)

select * from PortfolioProject..NashvilleHousing

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing 
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, 
LEN(PropertyAddress)) 

------------------------
select OwnerAddress
from PortfolioProject..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing 
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing 
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing 
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- updating 'Y' to 'YES' and 'N' to 'NO'

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'YES'
when SoldAsVacant = 'N' then 'NO'
else SoldAsVacant
end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'YES'
when SoldAsVacant = 'N' then 'NO'
else SoldAsVacant
end

--Removing duplicates 

with RowNumCTE as(
select *, ROW_NUMBER() over (
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID
) row_num
from PortfolioProject..NashvilleHousing
)
select * from RowNumCTE
where row_num > 1


--deleting unused cols

select * from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject..NashvilleHousing
drop column SaleDate

