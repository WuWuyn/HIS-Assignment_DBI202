USE HIS_Assignment
GO
-- Thống kê số lượng cuộc hẹn theo trạng thái
SELECT A.Status, COUNT(A.AppointmentID) AS TotalAppointments
FROM Appointment A
GROUP BY A.Status;


-- Thống kê số lượng bệnh nhân nội trú theo phòng
SELECT RD.RoomNumber, COUNT(IT.PatientID) AS TotalPatients
FROM RoomDetail RD
LEFT JOIN InpatientTreatment IT ON RD.RoomID = IT.RoomID AND DischargeDate IS NULL
GROUP BY RD.RoomNumber;
GO

-- Truy vấn thống kê số lượng lịch hẹn của các bác sĩ
SELECT D.DoctorID, E.EmployeeName, COUNT(A.AppointmentID) AS TotalAppointments
FROM Doctor D
JOIN Employee E ON D.DoctorID = E.EmployeeID
JOIN Appointment A ON D.DoctorID = A.DoctorID
GROUP BY D.DoctorID, E.EmployeeName
ORDER BY TotalAppointments DESC
GO

-- Truy vấn để tìm các bác sĩ và số lượng dịch vụ họ đã thực hiện
SELECT D.DoctorID, E.EmployeeName, COUNT(O.OrderID) AS TotalServices
FROM Doctor D
JOIN Employee E ON D.DoctorID = E.EmployeeID
LEFT JOIN Orders O ON D.DoctorID = O.DoctorID
GROUP BY D.DoctorID, E.EmployeeName;

-- Thống kê tổng các chi phí hóa đơn của từng bệnh nhân
SELECT P.PatientID, P.PatientName, SUM(B.TotalFee) AS TotalBilling
FROM Patient P
JOIN Bill B ON P.PatientID = B.PatientID
GROUP BY P.PatientID, P.PatientName;


