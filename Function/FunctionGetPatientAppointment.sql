CREATE FUNCTION GetPatientAppointments (@PatientID CHAR(12))
RETURNS TABLE
AS
RETURN
(
    SELECT A.AppointmentID, A.AppointmentDate, A.Status, A.AppointmentType, D.EmployeeName AS DoctorName
    FROM Appointment A
    JOIN Doctor Doc ON A.DoctorID = Doc.DoctorID
    JOIN Employee D ON Doc.DoctorID = D.EmployeeID
    WHERE A.PatientID = @PatientID
);
GO

-- Sẽ lấy ra tất cả các lịch khám bệnh của bệnh nhân
SELECT *
FROM GetPatientAppointments('P001');
