# Brazilian-E-Commerce-Public-Dataset-by-Olist

This project analyzes Olist's public Brazilian e-commerce dataset to understand delivery reliability, revenue trends, and customer retention, using SQL for analysis and Power BI for visualization."

## DATASET DESCRIPTION
The Olist dataset has 9 tables detailing data on the below categories:
  - Customers
  - Sellers
  - Orders
  - Order items
  - Product categories
  - Payment methods
  - Order reviews

## TOOLS USED
 - MySQLWorkbench
 - PowerBi
 - DAX

## DATA INGESTION AND DATA CLEANING
The data was ingested into mysql using the inbuilt upload function.
I proceeded to modify the columns by adding unique identifiers(primary and foreign keys) in each table. I also modified the data types of various columns to ensure uniformity.

## KEY FINDINGS
### ORDER ANALYSIS
The dataset had a total of 99.441K orders. 96,478 of the orders had been successfully delivered.
<img width="483" height="369" alt="image" src="https://github.com/user-attachments/assets/f300bf92-98a9-4d1f-8c92-88f2d6dcde38" />

### DELIVERY ANALYSIS
I created a view in sql to aid in delayed delivery analysis.
On average, it took 11 days for deliveries to be made.
In total, 6,534 deliveries were delayed. This makes up 6.7% of the total deliveries made.
The city of "armação dos búzios" had the highest percentage of delayed orders at 41% whereas "Sao paulo" had the highest number of delayed orders at 715 orders against a total of 15,540 orders.

<img width="516" height="265" alt="image" src="https://github.com/user-attachments/assets/6cb61537-f33e-46ea-b4ea-ab2013e6158d" />

"Sao paulo" had the highest count of delayed orders in the selling city categories while "itajobi" had the highest percentage of delayed orders at 27%.
This analysis was done on orders count exceeding 20 to avoid skewing of data.
<img width="526" height="276" alt="image" src="https://github.com/user-attachments/assets/3732982f-5303-4c06-af4e-988757ec70a9" />

### CUSTOMER BEHAVIOUR ANALYSIS
The dataset contained a total of 96,096 unique customers. 2,997 were repeat customers which makes a total of 3% of the total customer data.
The repeat customers resulted in a revenue total of 922,021 which forms 5.82% of the total revenue.

<img width="455" height="343" alt="image" src="https://github.com/user-attachments/assets/d2c7240a-ff1c-44bf-ad1f-30d8fa40d477" />

### REVIEW SCORE ANALYSIS
Orders that experienced delayed deliveries had a lower review score compared to those that experienced no delayed deliveries.

<img width="408" height="344" alt="image" src="https://github.com/user-attachments/assets/dd86b011-e777-4f0a-bd2c-e05c9cc6a21b" />

### REVENUE TREND BY MONTH
The month of May yielded the highest revenue across the years at a total sum of 1,695,625.92 across all three years.

<img width="492" height="367" alt="image" src="https://github.com/user-attachments/assets/782872e9-6c75-406b-9cd2-c0e458c79980" />

### LIMITATIONS
The data is incomplete as 2016 data is partial (marketplace launched mid-year) while the final month(s) of 2018 data show incomplete delivery status, affecting revenue trend at the tail end of the chart

### RECOMMENDATIONS

**1. Prioritize delivery reliability in high-delay regions and categories.**
Delays are not evenly distributed — certain cities (e.g., Armação dos Búzios at 
42.86%) and seller locations show delay rates several times higher than the 
platform average of 6.7%. Olist and its logistics partners should investigate 
carrier performance and fulfillment processes specifically in these high-delay 
areas, rather than applying a uniform improvement effort across the whole network.

**2. Treat on-time delivery as a customer satisfaction lever, not just an 
operations metric.**
Orders with delayed deliveries consistently received lower review scores than 
on-time orders. Since review scores likely influence repeat purchase behavior 
and seller reputation on the platform, reducing delays should be framed as a 
retention and satisfaction initiative, not solely a logistics KPI.

**3. Design targeted retention campaigns, since repeat customers are rare but 
valuable.**
Only 3% of customers placed more than one order, yet this group generated 5.82% 
of total revenue — a modestly disproportionate contribution. Given how small 
this segment is, even a small improvement in repeat-purchase rate (e.g., through 
post-purchase engagement, loyalty incentives, or improved delivery experience 
for first-time buyers) could meaningfully grow overall revenue.

**4. Review freight pricing for high freight-to-price categories.**
Some product categories carry a freight cost that represents a disproportionately 
high percentage of the item's price, which may discourage purchases or reduce 
perceived value in those categories. Sellers in these categories could explore 
consolidated shipping, regional warehousing, or freight subsidies to improve 
price competitiveness.

**5. Monitor seasonal revenue patterns for inventory and staffing planning.**
Revenue peaked around May across the dataset's active years. Olist and its 
sellers could use this pattern to anticipate demand, ensuring adequate seller 
stock levels and delivery capacity ahead of higher-volume periods, rather than 
reacting to demand after it occurs.








