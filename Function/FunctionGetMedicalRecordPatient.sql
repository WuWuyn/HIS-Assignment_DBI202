CREATE FUNCTION GetMedicalRecordByPatientID
(
    @PatientID CHAR(12)
)
RETURNS TABLE
AS
RETURN 
(
   SELECT mr.RecordID, 
	   mr.RecordDate, 
	   mr.Summary, 
	   mr.Diagnosis, 
	   d.EmployeeID,
	   d.EmployeeName AS DoctorName
    FROM MedicalRecord mr
    JOIN Doctor doc ON mr.RecordBy = doc.DoctorID
    JOIN Employee d ON doc.DoctorID = d.EmployeeID
    WHERE mr.PatientID = @PatientID
);
GO

-- Test
SELECT * 
FROM GetMedicalRecordByPatientID('P001')
ORDER BY RecordDate DESC;
