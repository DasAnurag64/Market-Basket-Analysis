WITH ProductPairs AS (
    SELECT 
        p1.ProductName AS Product_A,
        p2.ProductName AS Product_B,
        p1.Category AS Category_A,
        p2.Category AS Category_B,
        COUNT(DISTINCT a.OrderID) AS Basket_Frequency
    FROM dbo.fact_order_details a
    JOIN dbo.fact_order_details b 
        ON a.OrderID = b.OrderID 
        AND a.ProductID < b.ProductID
    JOIN dbo.dim_products p1 ON a.ProductID = p1.ProductID
    JOIN dbo.dim_products p2 ON b.ProductID = p2.ProductID
    GROUP BY p1.ProductName, p2.ProductName, p1.Category, p2.Category
)
SELECT 
    Product_A,
    Product_B,
    Category_A,
    Category_B,
    Basket_Frequency,
    DENSE_RANK() OVER (ORDER BY Basket_Frequency DESC) AS Affinity_Rank
FROM ProductPairs
WHERE Basket_Frequency >= 25
ORDER BY Basket_Frequency DESC;








WITH TotalOrders AS (
   
    SELECT COUNT(DISTINCT OrderID) AS Total_Order_Count 
    FROM dbo.fact_order_details 
),
SingleProductFrequency AS (
    
    SELECT 
        ProductID,
        COUNT(DISTINCT OrderID) AS Product_Order_Count
    FROM dbo.fact_order_details
    GROUP BY ProductID
),
PairFrequency AS (
    
    SELECT 
        a.ProductID AS ProductA_ID,
        b.ProductID AS ProductB_ID,
        COUNT(DISTINCT a.OrderID) AS Pair_Count
    FROM dbo.fact_order_details a
    JOIN dbo.fact_order_details b 
        ON a.OrderID = b.OrderID 
        AND a.ProductID <> b.ProductID
    GROUP BY a.ProductID, b.ProductID
)
SELECT 
    pa.ProductName AS Product_A,
    pb.ProductName AS Product_B,
    pa.Category AS Category_A,
    pb.Category AS Category_B,
    pf.Pair_Count AS Co_Occurrences,
    
    CAST(pf.Pair_Count * 1.0 / t.Total_Order_Count AS DECIMAL(6, 4)) AS Support,
    
    CAST(pf.Pair_Count * 1.0 / fa.Product_Order_Count AS DECIMAL(6, 4)) AS Confidence,
    
    CAST((pf.Pair_Count * 1.0 / fa.Product_Order_Count) / (fb.Product_Order_Count * 1.0 / t.Total_Order_Count) AS DECIMAL(6, 2)) AS Lift
FROM PairFrequency pf
JOIN SingleProductFrequency fa ON pf.ProductA_ID = fa.ProductID
JOIN SingleProductFrequency fb ON pf.ProductB_ID = fb.ProductID
JOIN dbo.dim_products pa ON pf.ProductA_ID = pa.ProductID
JOIN dbo.dim_products pb ON pf.ProductB_ID = pb.ProductID
CROSS JOIN TotalOrders t
WHERE pf.Pair_Count >= 20
ORDER BY Lift DESC;