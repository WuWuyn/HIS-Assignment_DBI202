CREATE TRIGGER trg_CheckTechnicianSchedule
ON Orders
AFTER INSERT
AS
BEGIN
    -- Kiểm tra xem có đơn hàng nào có cùng TechnicianID và ScheduledDateTime đã tồn tại không
    IF EXISTS (
        SELECT 1 
        FROM Orders o
        JOIN inserted i ON o.TechnicianID = i.TechnicianID 
                         AND o.ScheduledDateTime = i.ScheduledDateTime
        WHERE o.OrderID <> i.OrderID -- Tránh so sánh với chính nó
    )
    BEGIN
        RAISERROR('Bác sĩ thực hiện nghiệp vụ này đã có lịch vào thời gian này', 16, 1);
        ROLLBACK; 
    END
END;

-- TEST
-- Không thể insert được order do bị trùng lịch
INSERT INTO Orders (OrderID, AppointmentID, DoctorID, TechnicianID, OrderStatus, ScheduledDateTime, OrderType, ServiceID, Note) VALUES
(9, 6, 'E006', 'E004',  N'Xác nhận', '2024-10-25 15:55:00', 'RadiologyTest', 2, NULL);

-- Insert thành công
INSERT INTO Orders (OrderID, AppointmentID, DoctorID, TechnicianID, OrderStatus, ScheduledDateTime, OrderType, ServiceID, Note) VALUES
(9, 6, 'E006', 'E004',  N'Xác nhận', '2024-10-25 16:05:00', 'RadiologyTest', 2, NULL);