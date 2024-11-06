CREATE PROCEDURE GenerateInpatientBill
    @InpatientID INT
AS
BEGIN
    DECLARE @BillID INT;
    DECLARE @TotalAmount DECIMAL(18, 0);
    DECLARE @PatientID CHAR(12);
    DECLARE @RoomFee DECIMAL(18, 0);
    DECLARE @AdmitDate DATETIME;
    DECLARE @DischargeDate DATETIME;

    -- Bắt đầu transaction
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Lấy thông tin bệnh nhân, ngày nhập viện, ngày xuất viện và tiền phòng
        SELECT 
            @PatientID = PatientID,
            @AdmitDate = AdmitDate,
            @DischargeDate = DischargeDate,
            @RoomFee = rt.RoomFee
        FROM InpatientTreatment it
        INNER JOIN RoomDetail rd ON it.RoomID = rd.RoomID
        INNER JOIN RoomType rt ON rd.TypeID = rt.TypeID
        WHERE it.InpatientID = @InpatientID;

        -- Kiểm tra nếu không tìm thấy thông tin điều trị nội trú hoặc bệnh nhân chưa xuất viện
        IF @PatientID IS NULL OR @DischargeDate IS NULL
        BEGIN
            RAISERROR(N'Không thể tạo hóa đơn. Bệnh nhân không tồn tại hoặc chưa xuất viện cho InpatientID: %d', 16, 1, @InpatientID);
            RETURN;
        END

        -- Tính tổng số tiền
        SET @TotalAmount = DATEDIFF(DAY, @AdmitDate, @DischargeDate) * @RoomFee;

        -- Tạo mã BillID mới
        SELECT @BillID = ISNULL(MAX(BillID), 0) + 1 FROM Bill;

        -- Tạo hóa đơn tổng thể
        INSERT INTO Bill (BillID, PatientID, TotalFee, [DateTime], [Status], Note)
        VALUES (@BillID, @PatientID, @TotalAmount, GETDATE(), N'Đang chờ', N'Hóa đơn thanh toán điều trị nội trú');

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
EXEC GenerateInpatientBill @InpatientID = 1;
--Tạo hóa đơn thất bại
EXEC GenerateInpatientBill @InpatientID = 5;
