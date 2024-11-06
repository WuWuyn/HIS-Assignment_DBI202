CREATE PROCEDURE UpdateMedicineQuantityByBatch
    @BatchNumber VARCHAR(50),  -- Thay đổi kiểu dữ liệu nếu cần
    @MedicineID CHAR(5),
    @Quantity INT  -- Tham số số lượng thuốc cần trừ
AS
BEGIN
    -- Kiểm tra xem thuốc có tồn tại trong kho và đủ số lượng để trừ không
    IF EXISTS (
        SELECT 1
        FROM MedicineStorage ms
        WHERE ms.BatchNumber = @BatchNumber
          AND ms.ExpiryDate > GETDATE()
          AND ms.MedicineID = @MedicineID
          AND ms.Quantity >= @Quantity  -- Kiểm tra xem số lượng trong kho có đủ để trừ không
    )
    BEGIN
        -- Cập nhật số lượng thuốc trong kho
        UPDATE ms
        SET ms.Quantity = ms.Quantity - @Quantity  -- Trừ số lượng được chỉ định
        FROM MedicineStorage ms
        WHERE ms.BatchNumber = @BatchNumber
          AND ms.MedicineID = @MedicineID;

        PRINT N'Cập nhật số lượng thuốc thành công.';
    END
    ELSE
    BEGIN
        PRINT N'Không đủ số lượng thuốc trong kho hoặc thuốc đã hết hạn.';
    END
END;
GO

-- Gọi thủ tục với BatchNumber là 'L123', MedicalRecordID là 1, và Quantity là 10
EXEC UpdateMedicineQuantityByBatch @BatchNumber = 'BATCH001', @MedicineID = 'M001', @Quantity = 10;
GO

-- Kiểm tra lại số lượng thuốc trong kho
SELECT * FROM MedicineStorage;

