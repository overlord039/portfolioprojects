--cleaning data using sql queries'

select*
from [NashvilleHousing ]


--standardize date formate

update [NashvilleHousing ]
set SaleDate =cast(saleDate as date)

select SaleDate,cast(saleDate as date)
from [NashvilleHousing ] 
order by SaleDate

alter table NashvilleHousing
alter column saleDate date

select SaleDate
from [NashvilleHousing ] 
order by SaleDate


---------------------------------------------------------------

--populate property address data

select* --propertyaddress
from [NashvilleHousing ]
--where propertyaddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from [NashvilleHousing ] a
join [NashvilleHousing ] b
on a.ParcelID=b.ParcelID 
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from [NashvilleHousing ] a
join [NashvilleHousing ] b
on a.ParcelID=b.ParcelID 
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

select*
from [NashvilleHousing ]
where PropertyAddress is null

---------------------------------------------------------------------------------------

--breaking address into city,address,state

select PropertyAddress
from [NashvilleHousing ]

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as city
from [NashvilleHousing ]

alter table NashvilleHousing
add address nvarchar(255)

alter table NashvilleHousing
add city nvarchar(255)

update [NashvilleHousing ]
set 
address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

update [NashvilleHousing ]
set 
city = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select 
substring(OwnerAddress,CHARINDEX(',',owneraddress,CHARINDEX(',',OwnerAddress)+1)+1,len(OwnerAddress)) 
from [NashvilleHousing ]

--SELECT 
--    SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, LEN(OwnerAddress)) AS new,
--    SUBSTRING(
--        SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, LEN(OwnerAddress)),
--        CHARINDEX(',', SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, LEN(OwnerAddress))) + 1,
--        LEN(SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, LEN(OwnerAddress)))
--    ) AS state
--FROM [NashvilleHousing];
SELECT 
    SUBSTRING(OwnerAddress, 
              CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) + 1, 
              LEN(OwnerAddress)) AS AfterSecondComma
FROM [NashvilleHousing];


--using parsename

select 
PARSENAME(replace(owneraddress,',','.'),1) as state
from [NashvilleHousing ]

alter table [NashvilleHousing ]
add state nvarchar(255)

update [NashvilleHousing ]
set state =PARSENAME(replace(owneraddress,',','.'),1)

select*
from [NashvilleHousing ]

---------------------------------------------------

--change y and n to yes and no in "sold as vacant" field

select distinct(soldasvacant),count(soldasvacant)
from [NashvilleHousing ]
group by soldasvacant
order by 2

select soldasvacant,
case
when soldasvacant = 'y' then 'yes'
when soldasvacant ='n' then 'no'
else SoldAsVacant
end
from [NashvilleHousing ]

update [NashvilleHousing ]
set SoldAsVacant=case
when soldasvacant = 'y' then 'yes'
when soldasvacant ='n' then 'no'
else SoldAsVacant
end

-----------------------------------------------------------------

--remove duplicate

with rownumcte as(
select*,
ROW_NUMBER() over (
partition by parcelID,
propertyaddress,
saleprice,
legalreference
order by uniqueID
)row_num
from [NashvilleHousing ]
--order by 2
)
select*
from rownumcte
where row_num>1

delete
from rownumcte
where row_num>1
--order by ParcelID

-------------------------------------------------------------------
--delete unused columns

select*
from [NashvilleHousing ]

alter table [NashvilleHousing ]
drop column propertyaddress 
