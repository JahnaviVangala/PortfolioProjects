select *
from PortfolioProject..NashvilleHousing


--standardize date format

select saledateconverted-- convert(date,saledate) 
from PortfolioProject..NashvilleHousing


update NashvilleHousing
set SaleDate= convert(date,saledate) 

alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set saledateconverted=convert(date,saledate) 


--populate property address data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.propertyaddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.propertyaddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out address into individual coulums (address, city , state)

select propertyaddress
from PortfolioProject..NashvilleHousing

select SUBSTRING(propertyaddress,1, CHARINDEX(',', PropertyAddress)-1)as address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, len(propertyaddress))as address
from PortfolioProject..NashvilleHousing


alter table portfolioproject..nashvillehousing
add propertysplitaddress nvarchar(255);

update portfolioproject..NashvilleHousing
set propertysplitaddress= SUBSTRING(propertyaddress,1, CHARINDEX(',', PropertyAddress)-1)


alter table NashvilleHousing
add propertysplitcity nvarchar(255);

update NashvilleHousing
set propertysplitcity=SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, len(propertyaddress))


select *
from PortfolioProject..NashvilleHousing

--using parsename to split

select owneraddress
from NashvilleHousing


select 
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from NashvilleHousing

alter table portfolioproject..nashvillehousing
add OwnerSplitAddress nvarchar(255);

update portfolioproject..NashvilleHousing
set OwnerSplitAddress=PARSENAME(replace(owneraddress,',','.'),3)


alter table portfolioproject..nashvillehousing
add OwnerSplitCity nvarchar(255);

update portfolioproject..NashvilleHousing
set OwnerSplitCity=PARSENAME(replace(owneraddress,',','.'),2)

alter table portfolioproject..nashvillehousing
add OwnerSplitState nvarchar(255);

update portfolioproject..NashvilleHousing
set OwnerSplitState=PARSENAME(replace(owneraddress,',','.'),1)


--change Y and N to Yes and No in "sold as vacant " field

select distinct SoldAsVacant,count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant='y' then 'Yes'
when SoldAsVacant='n' then 'No'
else SoldAsVacant
end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant= case when SoldAsVacant='y' then 'Yes'
when SoldAsVacant='n' then 'No'
else SoldAsVacant
end 



--remove duplicates

with RowNumCTE as(
select *,
ROW_NUMBER() over(
partition by ParcelID,
             Propertyaddress,SalePrice, SaleDate,LegalReference
			 order by uniqueID)  row_num
from NashvilleHousing)

delete 
from RowNumCTE
where row_num>1
--order by PropertyAddress


--delete unused columns

alter table nashvillehousing
drop column owneraddress,taxdistrict,propertyaddress

alter table nashvillehousing
drop column saledate






 
