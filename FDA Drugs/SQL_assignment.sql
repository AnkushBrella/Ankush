use sql_assginment;

select * from appdoc;
select * from appdoctype_lookup;
select * from application;
select * from chemtypelookup;
select * from doctype_lookup;
select * from product;
select * from product_tecode;
select * from regactiondate;
select * from reviewclass_lookup;

-- Task 1: Identifying Approval Trends

-- Year wise approvals of drugs
SELECT YEAR(DocDate) AS approval_year, COUNT(*) AS num_drugs_approved
FROM appdoc
GROUP BY YEAR(DocDate)
ORDER BY approval_year;

-- Top three years with highest approvals
SELECT YEAR(DocDate) AS approval_year, COUNT(*) AS num_drugs_approved
FROM appdoc
GROUP BY YEAR(DocDate)
ORDER BY num_drugs_approved DESC
LIMIT 3;

-- Top three years with lowest approvals
SELECT YEAR(DocDate) AS approval_year, COUNT(*) AS num_drugs_approved
FROM appdoc
GROUP BY YEAR(DocDate)
ORDER BY num_drugs_approved ASC
LIMIT 3;

-- approval trends over the years based on sponsors
SELECT SponsorApplicant, YEAR(DocDate) AS approval_year, COUNT(*) AS num_drugs_approved
FROM appdoc
INNER JOIN application ON appdoc.ApplNo = application.ApplNo
GROUP BY SponsorApplicant, YEAR(DocDate)
ORDER BY approval_year, SponsorApplicant;

-- approval trends over the years based on sponsors between year 1939 AND 1960
SELECT SponsorApplicant, YEAR(DocDate) AS approval_year, COUNT(*) AS num_drugs_approved
FROM appdoc
INNER JOIN application ON appdoc.ApplNo = application.ApplNo
WHERE YEAR(DocDate) BETWEEN 1939 AND 1960
GROUP BY SponsorApplicant, YEAR(DocDate)
ORDER BY approval_year, num_drugs_approved DESC;

-- Task 2: Segmentation Analysis Based on Drug MarketingStatus

-- products based on MarketingStatus
SELECT ProductMktStatus, COUNT(*) AS num_products
FROM product
GROUP BY ProductMktStatus;

--  total number of applications for each MarketingStatus year-wise after the year 2010.

SELECT YEAR(appdoc.DocDate) AS approval_year, product.ProductMktStatus, COUNT(*) AS num_applications
FROM appdoc
INNER JOIN product ON appdoc.ApplNo = product.ApplNo
WHERE YEAR(appdoc.DocDate) > 2010
GROUP BY approval_year, product.ProductMktStatus
ORDER BY approval_year, num_applications DESC;

--  top MarketingStatus with the maximum number of applications (productmktstatus =1) and its trend over the years

SELECT product.ProductMktStatus, YEAR(appdoc.DocDate) AS approval_year, COUNT(*) AS num_applications
FROM appdoc
INNER JOIN product ON appdoc.ApplNo = product.ApplNo
where product.ProductMktStatus = 
(SELECT product.ProductMktStatus
    FROM appdoc
    INNER JOIN Product  ON appdoc.ApplNo = Product.ApplNo
    GROUP BY Product.ProductMktstatus
    ORDER BY COUNT(*) DESC
    LIMIT 1)
GROUP BY product.ProductMktStatus, approval_year
ORDER BY num_applications;

-- Task 3: Analyzing Products

-- Categorize Products by dosage form and analyze their distribution
SELECT Form, COUNT(*) AS num_products
FROM product
GROUP BY Form;

--  total number of approvals for each dosage form and identify the most successful forms
SELECT Form, COUNT(*) AS num_approvals
FROM product
WHERE ProductMktStatus = 1
GROUP BY Form
ORDER BY num_approvals DESC;

-- yearly trends related to successful forms.
SELECT Form, YEAR(appdoc.DocDate) AS approval_year, COUNT(*) AS num_approvals
FROM product
INNER JOIN appdoc ON product.ApplNo = appdoc.ApplNo
WHERE product.ProductMktStatus = 1
GROUP BY Form, approval_year
ORDER BY Form, approval_year;

-- Task 4: Exploring Therapeutic Classes and Approval Trends

--  drug approvals based on therapeutic evaluation code (TE_Code)
SELECT TECode, COUNT(*) AS num_approvals
FROM product_tecode
GROUP BY TECode
ORDER BY num_approvals DESC;

--  the therapeutic evaluation code (TE_Code) with the highest number of Approvals in each year.
WITH ranked_te_codes AS (
    SELECT TECode, YEAR(DocDate) AS approval_year, COUNT(*) AS num_approvals,
           ROW_NUMBER() OVER (PARTITION BY YEAR(DocDate) ORDER BY COUNT(*) DESC) AS ranking
    FROM product_tecode
    INNER JOIN appdoc ON product_tecode.ApplNo = appdoc.ApplNo
    GROUP BY TECode, YEAR(DocDate)
)
SELECT TECode, approval_year, num_approvals
FROM ranked_te_codes
WHERE ranking = 1;
