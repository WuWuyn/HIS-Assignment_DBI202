USE HIS_Assignment
GO 

CREATE VIEW ThongKeSuDungDichVu AS
SELECT 
    s.ServiceID AS MaDichVu,
    s.ServiceName AS TenDichVu,
    COUNT(o.OrderID) AS SoLanSuDung,
    SUM(bd.Quantity) AS TongSoLuongSuDung,
    SUM(bd.TotalAmount) AS TongDoanhThu
FROM 
    Services s
LEFT JOIN 
    Orders o ON s.ServiceID = o.ServiceID
LEFT JOIN 
    BillDetails bd ON s.ServiceID =  TRY_CAST(bd.ServiceID AS INT) 
GROUP BY 
    s.ServiceID, s.ServiceName;

GO

SELECT * FROM ThongKeSuDungDichVu