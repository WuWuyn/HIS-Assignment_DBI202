USE HIS_Assignment
GO

CREATE VIEW BenhNhanNoiTruHienTai AS
SELECT 
    it.InpatientID,
    it.PatientID,
    p.PatientName AS TenBenhNhan,
    it.RoomID,
    rd.RoomNumber AS SoPhong,
    it.AdmitDate AS NgayNhapVien,
    it.DischargeDate AS NgayRaVien
FROM 
    InpatientTreatment it
JOIN 
    Patient p ON it.PatientID = p.PatientID
JOIN 
    RoomDetail rd ON it.RoomID = rd.RoomID
WHERE 
    it.DischargeDate IS NULL;
GO

--TEST
SELECT * FROM BenhNhanNoiTruHienTai