CREATE PROCEDURE GenerateBillForOrder
    @AppointmentID INT
AS
BEGIN
    DECLARE @BillID INT;
    DECLARE @TotalAmount DECIMAL(18,0);
	DECLARE @BillDetailID INT;
	DECLARE @PatientID CHAR(12);
	DECLARE @Status NVARCHAR(50);

    -- Bắt đầu transaction
    BEGIN TRANSACTION;

    BEGIN TRY
		
		SELECT @PatientID = PatientID, @Status = [Status]
        FROM Appointment
        WHERE AppointmentID = @AppointmentID;

		IF @Status = N'Đã hủy' 
		BEGIN
			PRINT N'Lịch hẹn đã bị hủy bỏ. Không thể tạo hoá đơn '
			RETURN
		END

        -- Tính tổng phí cho tất cả các dịch vụ trong Orders dựa trên AppointmentID
        SELECT @TotalAmount = SUM(s.ServicePrice)
        FROM Orders o
        INNER JOIN Services s ON o.ServiceID = s.ServiceID
        WHERE o.AppointmentID = @AppointmentID;

        -- Tạo mã BillID mới
        SELECT @BillID = ISNULL(MAX(BillID), 0) + 1 FROM Bill;

        -- Tạo hóa đơn tổng thể
		INSERT INTO Bill (BillID, PatientID, TotalFee, [DateTime], [Status], Note)
		VALUES (@BillID, @PatientID, @TotalAmount, GETDATE(), N'Đang chờ', N'Hóa đơn thanh toán các dịch vụ sử dụng');

        -- Thêm các chi tiết hóa đơn
        INSERT INTO BillDetails (BillDetailID, BillID, ServiceID, Quantity, FeePerService, TotalAmount)
        SELECT 
            ROW_NUMBER() OVER (ORDER BY o.OrderID) + ISNULL((SELECT MAX(BillDetailID) FROM BillDetails), 0), -- Tạo BillDetailID mới duy nhất,
            @BillID,
            o.ServiceID,
            1,  -- Giả sử số lượng mặc định là 1 cho mỗi dịch vụ
            s.ServicePrice,
            s.ServicePrice  -- Tổng tiền cho mỗi dịch vụ
        FROM Orders o
        INNER JOIN Services s ON o.ServiceID = s.ServiceID
        WHERE o.AppointmentID = @AppointmentID;

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

--TEST
-- Tạo Bill thành công 
EXEC GenerateBillForOrder @AppointmentID = 6;
-- Tạo Bill thất bại vì đã hủy lịch hẹn
EXEC GenerateBillForOrder @AppointmentID = 3;
