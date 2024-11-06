-- Tạo INDEX giúp cải thiện hiệu suất truy vấn các Appointment theo PatientID hoặc DoctorID để tìm kiếm các Appointment
CREATE INDEX IX_Appointment_PatientID ON Appointment(PatientID);
CREATE INDEX IX_Appointment_DoctorID ON Appointment(DoctorID);

-- Tạo INDEX giúp cải thiện hiệu suất truy vấn các InpatientTreatment theo PatientID
CREATE INDEX IX_InpatientTreatment_PatientID ON InpatientTreatment(PatientID);
