USE HIS_Assignment
GO

CREATE VIEW ThongKeNhanVienPhongBan AS
SELECT 
    d.DepartmentID AS MaPhongBan,
    d.DepartmentName AS TenPhongBan,
    COUNT(e.EmployeeID) AS SoLuongNhanVien,
    (SELECT e2.EmployeeName 
     FROM Employee e2 
     WHERE e2.DepartmentID = d.DepartmentID AND e2.IsDepartmentHead = 1) AS TenTruongPhong,
    (SELECT e2.EmployeeID 
     FROM Employee e2 
     WHERE e2.DepartmentID = d.DepartmentID AND e2.IsDepartmentHead = 1) AS MaTruongPhong
FROM 
    Department d
LEFT JOIN 
    Employee e ON d.DepartmentID = e.DepartmentID
GROUP BY 
    d.DepartmentID, d.DepartmentName;
GO

--TEST
SELECT * FROM ThongKeNhanVienPhongBan