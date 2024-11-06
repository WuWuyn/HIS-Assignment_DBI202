CREATE TRIGGER trg_CheckRoomCapacity
ON InpatientTreatment
FOR INSERT
AS
BEGIN
    DECLARE @RoomID CHAR(5);

    SELECT @RoomID = RoomID FROM inserted;

    IF (
        SELECT BedsOccupied
        FROM RoomDetail
        WHERE RoomID = @RoomID
    ) >= (
        SELECT Capacity
        FROM RoomType
        WHERE TypeID = (
            SELECT TypeID
            FROM RoomDetail
            WHERE RoomID = @RoomID
        )
    )
    BEGIN
        RAISERROR ('Phòng đã đạt sức chứa tối đa.', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        UPDATE RoomDetail
        SET BedsOccupied = BedsOccupied + 1
        WHERE RoomID = @RoomID;
    END
END;
GO

-- Test
-- Insert thất bại vì phòng đã đủ người
INSERT INTO InpatientTreatment (InpatientID, PatientID, RoomID, AdmitDate) VALUES
(3, 'P006', 'R001', '2024-10-24 12:00'); 

--Insert thành công 
INSERT INTO InpatientTreatment (InpatientID, PatientID, RoomID, AdmitDate) VALUES
(3, 'P006', 'R002', '2024-10-24 12:00'); 

select * from InpatientTreatment
