-- 3) Display the total number of customers based on gender who have placed orders of worth at least Rs.3000.
SELECT count(t2.CUS_GENDER) as NoOfCustomers, t2.CUS_GENDER from
(select t1.CUS_ID, t1.CUS_GENDER, t1.ORD_AMOUNT, t1.CUS_NAME from
(select `order`.ORD_AMOUNT, `order`.CUS_ID,customer.CUS_GENDER, customer.CUS_NAME 
from `order-directory`.`order` 
inner join 
`order-directory`.customer 
on `order`.CUS_ID=customer.CUS_ID 
having `order`.ORD_AMOUNT>=3000)
as t1 
group by t1.CUS_ID) as t2 
group by t2.CUS_GENDER;

-- 4)	Display all the orders along with product name ordered by a customer having Customer_Id=2
select `order`.*, SA1.PRO_NAME from `order-directory`.`order`
inner join
(select product.PRO_NAME, supplier_pricing.PRICING_ID from 
`order-directory`.product
inner join
`order-directory`.supplier_pricing 
on
supplier_pricing.PRO_ID = product.PRO_ID ) as SA1
on
`order`.PRICING_ID = SA1.PRICING_ID where `order`.CUS_ID=2;

select product.pro_name, `order`.* from `order-directory`.`order`, `order-directory`.supplier_pricing, `order-directory`.product
where `order`.cus_id=2 and
`order`.pricing_id=supplier_pricing.pricing_id and supplier_pricing.pro_id=product.pro_id;

-- 5. Display the Supplier details who can supply more than one product.
select supplier.* from `order-directory`.supplier where supplier.SUPP_ID in
(select SUPP_ID from `order-directory`.supplier_pricing group by SUPP_ID having
count(SUPP_ID)>1);

-- 6)	Find the least expensive product from each category and print the table with category id, name, product name and price of the product
select category.CAT_ID,category.CAT_NAME, min(t3.min_price) as Min_Price,
t3.pro_name from 
`order-directory`.category 
inner join
(select product.CAT_ID, product.PRO_NAME, t2.* from `order-directory`.product inner join
(select PRO_ID, min(supp_price) as Min_Price from `order-directory`.supplier_pricing group by PRO_ID)
as t2 
where t2.PRO_ID = product.PRO_ID)as t3 
where t3.CAT_ID = category.CAT_ID group by t3.CAT_ID;

-- 7)	Display the Id and Name of the Product ordered after “2021-10-05"
select product.PRO_ID,product.PRO_NAME from 
`order-directory`.`order` 
inner join 
`order-directory`.supplier_pricing 
on supplier_pricing.PRICING_ID=`order`.PRICING_ID 
inner join 
`order-directory`.product
on 
product.PRO_ID=supplier_pricing.PRO_ID where `order`.ORD_DATE>"2021-10-05";

-- 8)	Display customer name and gender whose names start or end with character 'A'.
SELECT CUS_NAME,CUS_GENDER FROM `order-directory`.customer where CUS_NAME like 'A%' or CUS_NAME like '%A';

/*
9) Create a stored procedure to display supplier id, 
name, rating and Type_of_Service. 
For Type_of_Service, If rating =5, print “Excellent
Service”,If rating >4 print “Good Service”, If rating >2 print “Average Service” 
else print “Poor Service”.
*/
select report.SUPP_ID,report.SUPP_NAME,report.AVERAGE,
CASE
WHEN report.AVERAGE =5 THEN 'Excellent Service'
WHEN report.AVERAGE >4 THEN 'Good Service'
WHEN report.AVERAGE >2 THEN 'Average Service'
ELSE 'Poor Service'
END AS Type_of_Service from
(select final.SUPP_ID, supplier.supp_name, final.Average from
(select test2.SUPP_ID, avg(test2.rat_ratstars) as Average from
(select supplier_pricing.SUPP_ID, test.ORD_ID, test.RAT_RATSTARS from 
`order-directory`.supplier_pricing inner join
(select `order`.PRICING_ID, rating.ORD_ID, rating.RAT_RATSTARS from 
`order-directory`.`order` 
inner join 
`order-directory`.rating 
on rating.`ord_id` = `order`.ORD_ID ) 
as test
on test.PRICING_ID = supplier_pricing.PRICING_ID)
as test2 group by supplier_pricing.SUPP_ID)
as final 
inner join 
`order-directory`.supplier 
where final.SUPP_ID = supplier.SUPP_ID) as report;

call Rating_StoredProc();