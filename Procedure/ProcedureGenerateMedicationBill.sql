CREATE PROCEDURE GenerateMedicationBill
    @MedicalRecordID INT
AS
BEGIN
    DECLARE @BillID INT;
    DECLARE @TotalAmount DECIMAL(18,0) = 0;
    DECLARE @PatientID CHAR(12);

    -- Bắt đầu transaction
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Lấy PatientID từ MedicalRecord
        SELECT @PatientID = PatientID FROM MedicalRecord WHERE RecordID = @MedicalRecordID;

        -- Kiểm tra xem có Prescription nào cho MedicalRecordID này không
		IF NOT EXISTS (SELECT 1 FROM Prescription WHERE RecordID = @MedicalRecordID)
        BEGIN
            RAISERROR(N'Không có Prescription cho Medical Record ID: %d', 16, 1, @MedicalRecordID);
            RETURN;
        END

        -- Tạo mã BillID mới
        SELECT @BillID = ISNULL(MAX(BillID), 0) + 1 FROM Bill;

        -- Tính tổng phí cho tất cả các loại thuốc trong kho
        SELECT @TotalAmount = SUM(m.MedicinePrice * p.Quantity)
        FROM Prescription p
        INNER JOIN Medicine m ON p.MedicineID = m.MedicineID
        INNER JOIN MedicineStorage ms ON m.MedicineID = ms.MedicineID
        WHERE ms.ExpiryDate > GETDATE() AND p.Quantity <= ms.Quantity
          AND p.RecordID = @MedicalRecordID;

        -- Kiểm tra nếu không có thuốc hợp lệ
        IF @TotalAmount <= 0
        BEGIN
            RAISERROR(N'Không có thuốc hợp lệ hoặc hết hàng', 16, 1);
            RETURN;
        END

        -- Tạo hóa đơn tổng thể
        INSERT INTO Bill (BillID, PatientID, TotalFee, [DateTime], [Status], Note)
        VALUES (@BillID, @PatientID, @TotalAmount, GETDATE(), N'Đang chờ', N'Hóa đơn thanh toán tiền thuốc');

        -- Thêm các chi tiết hóa đơn cho từng loại thuốc
        INSERT INTO BillDetails (BillDetailID, BillID, ServiceID, Quantity, FeePerService, TotalAmount)
        SELECT 
            ROW_NUMBER() OVER (ORDER BY p.PrescriptionID) + ISNULL((SELECT MAX(BillDetailID) FROM BillDetails), 0),
            @BillID,
            p.MedicineID,  -- Mã thuốc
            p.Quantity,     -- Số lượng thuốc
            m.MedicinePrice, -- Giá mỗi loại thuốc
            (m.MedicinePrice * p.Quantity)  -- Tổng tiền cho loại thuốc
        FROM Prescription p
        INNER JOIN Medicine m ON p.MedicineID = m.MedicineID
        INNER JOIN MedicineStorage ms ON m.MedicineID = ms.MedicineID
        WHERE ms.ExpiryDate > GETDATE() AND p.Quantity <= ms.Quantity
          AND p.RecordID = @MedicalRecordID
        GROUP BY p.MedicineID, p.Quantity, m.MedicinePrice, p.PrescriptionID;

        -- Commit transaction nếu không có lỗi
        COMMIT TRANSACTION;
        
        PRINT N'Hóa đơn đã được tạo thành công với BillID: ' + CAST(@BillID AS NVARCHAR(20));
        
    END TRY
    BEGIN CATCH
        -- Rollback transaction nếu có lỗi
        ROLLBACK TRANSACTION;
        
        PRINT N'Lỗi: Không thể tạo hóa đơn. ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- TEST

-- Tạo hóa đơn thành công 
EXEC GenerateMedicationBill @MedicalRecordID = 1;
-- Không tạo hóa đơn
EXEC GenerateMedicationBill @MedicalRecordID = 0;

