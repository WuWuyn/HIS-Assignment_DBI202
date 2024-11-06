CREATE PROCEDURE UpdateDischargeDate
    @InpatientID INT
AS
BEGIN
    DECLARE @RoomID CHAR(5);
	DECLARE @DischargeDate DATETIME;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Lấy RoomID của bệnh nhân từ InpatientTreatment
        SELECT @RoomID = RoomID, @DischargeDate = DischargeDate
        FROM InpatientTreatment
        WHERE InpatientID = @InpatientID;

        -- Kiểm tra nếu RoomID tồn tại và DischargeDate mới khác NULL
        IF @RoomID IS NOT NULL AND @DischargeDate IS NULL
        BEGIN
			SET @DischargeDate = GETDATE();

            -- Cập nhật DischargeDate cho bệnh nhân
            UPDATE InpatientTreatment
            SET DischargeDate = @DischargeDate
            WHERE InpatientID = @InpatientID;

            -- Giảm BedsOccupied trong RoomDetail
            UPDATE RoomDetail
            SET BedsOccupied = BedsOccupied - 1
            WHERE RoomID = @RoomID
              AND BedsOccupied > 0; -- Đảm bảo không giảm quá mức
			COMMIT TRANSACTION;
        END
    END TRY

    BEGIN CATCH
        -- Xử lý lỗi nếu có và rollback
		RAISERROR('Bệnh nhân đã rời phòng hoặc phòng không hợp lệ', 16, 1);
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- TEST
-- Failed
EXEC UpdateDischargeDate @InpatientID = 1;
GO
-- Success
EXEC UpdateDischargeDate @InpatientID = 2;

SELECT * FROM InpatientTreatment
