CREATE TRIGGER CheckAppointmentConflict
ON Appointment
AFTER INSERT
AS
BEGIN
    DECLARE @DoctorID CHAR(12);
    DECLARE @AppointmentDate DATETIME;
    DECLARE @AppointmentID INT;

    -- Lấy thông tin từ bảng inserted
    SELECT 
        @DoctorID = DoctorID,
        @AppointmentDate = AppointmentDate,
        @AppointmentID = AppointmentID  -- Lấy AppointmentID để kiểm tra khi cập nhật
    FROM inserted;

    -- Kiểm tra trùng lặp cho cuộc hẹn mới
    IF EXISTS (
        SELECT 1
        FROM Appointment
        WHERE DoctorID = @DoctorID
        AND AppointmentDate = @AppointmentDate
        AND (AppointmentID <> @AppointmentID OR @AppointmentID IS NULL)  -- Nếu là cập nhật, không kiểm tra chính nó
    )
    BEGIN
        RAISERROR(N'Không thể đặt lịch. Cuộc hẹn với bác sĩ này đã có trong khoảng thời gian này.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Nếu không có trùng lặp, thực hiện hành động mặc định
    -- (Không cần phải thêm mã gì vì hành động mặc định sẽ được thực hiện)
END;
GO


-- TEST
-- Không thể insert một appointment, do bị trùng lịch
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, [Status], AppointmentType) VALUES
(7, 'P001', 'E005', '2024-10-23 08:30', N'Xác nhận', N'Khám Bệnh'); 

-- Insert thành công
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, [Status], AppointmentType) VALUES
(7, 'P001', 'E005', '2024-10-26 08:30', N'Xác nhận', N'Khám Bệnh'); 

select * from Appointment