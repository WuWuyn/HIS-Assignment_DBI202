USE [master]
GO
/*******************************************************************************
   Drop database if it exists
********************************************************************************/
IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'HIS_Assignment')
BEGIN
	ALTER DATABASE [HIS_Assignment] SET OFFLINE WITH ROLLBACK IMMEDIATE;
	ALTER DATABASE [HIS_Assignment] SET ONLINE;
	DROP DATABASE [HIS_Assignment];
END
GO

CREATE DATABASE [HIS_Assignment]
GO

USE [HIS_Assignment]
GO

/*******************************************************************************
	Create Tables
*******************************************************************************/


/****** Table 1: Department ******/
CREATE TABLE Department (
    DepartmentID CHAR(3) NOT NULL PRIMARY KEY,
    DepartmentName NVARCHAR(100),
    [Location] NVARCHAR(100)
);
GO

/****** Table 2: Employee ******/
CREATE TABLE [Employee] (
    [EmployeeID] CHAR(12) NOT NULL PRIMARY KEY,
    [EmployeeName] NVARCHAR(100),
    [Gender] VARCHAR(1),
    [DateOfBirth] DATE,
    [Address] NVARCHAR(255),
    [Phone] VARCHAR(11),
    [Email] VARCHAR(100),
	DepartmentID CHAR(3),
	[IsDepartmentHead] BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID) ON UPDATE CASCADE
);
GO

/****** Table 3: Services ******/
CREATE TABLE [Services] (
    ServiceID INT NOT NULL PRIMARY KEY,
    ServiceName NVARCHAR(100),
    ServicePrice DECIMAL(18,0) CHECK (ServicePrice > 0)
);
GO

/****** Table 4: Doctor ******/
CREATE TABLE Doctor (
    DoctorID CHAR(12) NOT NULL PRIMARY KEY,
    JobTitle NVARCHAR(100),
    Qualification NVARCHAR(100),
    FOREIGN KEY (DoctorID) REFERENCES Employee(EmployeeID) ON UPDATE CASCADE ON DELETE CASCADE
);
GO

/****** Table 5: Patient ******/
CREATE TABLE Patient (
    PatientID CHAR(12) NOT NULL PRIMARY KEY,
    PatientName NVARCHAR(100),
    Gender VARCHAR(1),
    DateOfBirth DATE,
    [Address] NVARCHAR(255),
    Phone VARCHAR(15),
    Email VARCHAR(100)
);
GO

/****** Table 6: Appointment ******/
CREATE TABLE Appointment (
    AppointmentID INT NOT NULL PRIMARY KEY,
    PatientID CHAR(12),
    DoctorID CHAR(12),	-- Bác sĩ đặt lịch hẹn 
    AppointmentDate DATETIME,
    [Status] NVARCHAR(50),	-- Kiểm tra có trùng lịch không  -> Xác nhận / Đã hủy
    AppointmentType NVARCHAR(50),	-- Khám Bệnh / Điều Trị
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID) 
);
GO

/****** Table 7: Orders ******/
CREATE TABLE Orders (
    OrderID INT NOT NULL PRIMARY KEY,
    AppointmentID INT NOT NULL,
    DoctorID CHAR(12),	-- Bác sĩ chỉ định
	TechnicianID CHAR(12) NOT NULL,	-- ID Bác sĩ thực hiện xét nghiệm
    OrderStatus NVARCHAR(50),	-- Kiểm tra có trùng lịch không  -> Xác nhận / Hủy bỏ 
    ScheduledDateTime DATETIME,	-- Thời gian tới khám
	OrderType VARCHAR(20),	-- LabTest / Radiology / Treatment
	ServiceID INT,	-- Mã dịch vụ sử dụng
    Note NVARCHAR(255),
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (ServiceID) REFERENCES [Services](ServiceID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID) ON UPDATE CASCADE ON DELETE CASCADE,
);
GO

/****** Table 8: LabTests ******/
CREATE TABLE LabTests (
    TestID INT NOT NULL PRIMARY KEY,
    OrderID INT NOT NULL,
    TestResultDate DATETIME,	-- Ngày có kết quả
    SampleType NVARCHAR(100),	-- Mẫu test
    TestResult NVARCHAR(255),	-- Kết quả xét nghiệm
    LabValues NVARCHAR(255),	-- Chỉ số
    TestNote NVARCHAR(255),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON UPDATE CASCADE ON DELETE CASCADE
);
GO

/****** Table 9: RadiologyTests ******/
CREATE TABLE RadiologyTests (
    RadiologyID INT NOT NULL PRIMARY KEY,
    OrderID INT,
    TestResultDate DATETIME,	-- Ngày có kết quả
    TestResult NVARCHAR(255),	-- Kết quả
    TestNote NVARCHAR(255),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON UPDATE CASCADE ON DELETE CASCADE
);
GO

/****** Table 10: RadiologyImages ******/
CREATE TABLE RadiologyImages (
    ImageID INT NOT NULL PRIMARY KEY,
    RadiologyID INT,
    ImagePath VARCHAR(255),		-- Hình ảnh chuẩn đoán kèm theo
    CaptureDate DATETIME,
    ImageDescription NVARCHAR(255),
    FOREIGN KEY (RadiologyID) REFERENCES RadiologyTests(RadiologyID) ON UPDATE CASCADE ON DELETE CASCADE
);
GO

/****** Table 11: Bill ******/
CREATE TABLE Bill (
    BillID INT NOT NULL PRIMARY KEY,
    PatientID CHAR(12),
    TotalFee DECIMAL(18,0),
    [DateTime] DATETIME,
    [Status] NVARCHAR(50) DEFAULT 'Đang chờ',	--Đã Thanh Toán, Đã Hủy, Đang chờ
    Note NVARCHAR(255),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID) ON UPDATE CASCADE ON DELETE CASCADE
);
GO

/****** Table 12: BillDetails ******/
CREATE TABLE BillDetails (
    BillDetailID INT NOT NULL PRIMARY KEY,
    BillID INT,
    ServiceID CHAR(5),	-- ServiceID này sẽ được gán tương đương với dịch vụ sử dụng
    Quantity INT DEFAULT 1,
    FeePerService DECIMAL(18,0),
    TotalAmount DECIMAL(18,0),
    FOREIGN KEY (BillID) REFERENCES Bill(BillID) ON UPDATE CASCADE ON DELETE CASCADE
);
GO

/****** Table 13: RoomType ******/
CREATE TABLE RoomType (
    TypeID INT NOT NULL PRIMARY KEY,
    Capacity INT CHECK (Capacity > 0),
    RoomFee DECIMAL(18,0) CHECK (RoomFee > 0),
    Description VARCHAR(255)
);
GO

/****** Table 14: RoomDetail ******/
CREATE TABLE RoomDetail (
    RoomID CHAR(5) NOT NULL PRIMARY KEY,
    TypeID INT NOT NULL,
    RoomNumber NVARCHAR(10),
    BedsOccupied INT NOT NULL,
    FOREIGN KEY (TypeID) REFERENCES RoomType(TypeID) ON UPDATE CASCADE ON DELETE CASCADE
);
GO

/****** Table 15: InpatientTreatment ******/
CREATE TABLE InpatientTreatment (
    InpatientID INT NOT NULL PRIMARY KEY,
    PatientID CHAR(12) NOT NULL,
    RoomID CHAR(5) NOT NULL,
    AdmitDate DATETIME NOT NULL,
    DischargeDate DATETIME DEFAULT NULL,
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (RoomID) REFERENCES RoomDetail(RoomID) ON UPDATE CASCADE ON DELETE CASCADE
);
GO

/****** Table 16: NurseAssignment ******/
CREATE TABLE NurseAssignment (
    AssignmentID INT NOT NULL PRIMARY KEY,
    InpatientID INT NOT NULL,
    NurseID CHAR(12),
    ShiftStart DATETIME,
    ShiftEnd DATETIME,
    CareDescription NVARCHAR(255),
    FOREIGN KEY (InpatientID) REFERENCES InpatientTreatment(InpatientID),
    FOREIGN KEY (NurseID) REFERENCES Employee(EmployeeID) 
);
GO

/****** Table 17: MedicalRecord ******/
CREATE TABLE MedicalRecord (
    RecordID INT NOT NULL PRIMARY KEY,
    PatientID CHAR(12) NOT NULL,
    AppointmentID INT NOT NULL,
    InpatientID INT,
    RecordDate DATE,
    Summary NVARCHAR(255),
    Diagnosis NVARCHAR(255),
    RecordBy CHAR(12) NOT NULL,
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (InpatientID) REFERENCES InpatientTreatment(InpatientID),
    FOREIGN KEY (RecordBy) REFERENCES Doctor(DoctorID) 
);
GO

/****** Table 18: Medicine ******/
CREATE TABLE Medicine (
    MedicineID CHAR(5) NOT NULL PRIMARY KEY,
    MedicineName NVARCHAR(100),
	MedicinePrice DECIMAL(18,0) CHECK (MedicinePrice > 0),
    DosageForm NVARCHAR(100),
    RouteOfAdministration NVARCHAR(100)
);
GO

/****** Table 19: MedicineStorage ******/
CREATE TABLE MedicineStorage (
    IndexID INT NOT NULL PRIMARY KEY,
    MedicineID CHAR(5) NOT NULL,
    ProductionDate DATE,
    ExpiryDate DATE,
    Manufacturer NVARCHAR(100),
    Quantity INT CHECK (Quantity >= 0),
    BatchNumber VARCHAR(50),
    FOREIGN KEY (MedicineID) REFERENCES Medicine(MedicineID) ON UPDATE CASCADE ON DELETE CASCADE
);
GO

/****** Table 20: Prescription ******/
CREATE TABLE Prescription (
    PrescriptionID INT NOT NULL PRIMARY KEY,
    RecordID INT NOT NULL,
    MedicineID CHAR(5) NOT NULL,
    [DateTime] DATETIME,
    Quantity INT CHECK (Quantity > 0),
    UsageDuration NVARCHAR(100) NOT NULL,
    FOREIGN KEY (RecordID) REFERENCES MedicalRecord(RecordID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (MedicineID) REFERENCES Medicine(MedicineID) ON UPDATE CASCADE ON DELETE CASCADE
);
GO

------------------------------------------------------------------------------------------------------

/****** INSERT VALUES FOR DEPARTMENT TABLE ******/
INSERT INTO Department (DepartmentID, DepartmentName, [Location]) VALUES
('K01', N'Khoa Khám Bệnh', N'Tầng 1'),
('K03', N'Khoa Nội', N'Tầng 1'),
('K19', N'Khoa Ngoại', N'Tầng 1'),
('K36', N'Khoa Huyết Học', N'Tầng 2'),
('K44', N'Khoa Dược', N'Tầng 2'),
('K00', N'Khoa Điều Dưỡng', N'Tầng 3');
GO

/****** INSERT VALUES FOR EMPLOYEE TABLE ******/
INSERT INTO Employee (EmployeeID, EmployeeName, Gender, DateOfBirth, [Address], Phone, Email, DepartmentID, IsDepartmentHead) VALUES
('E001', N'Nguyễn Văn A', 'M', '1980-01-15', N'Hà Nội', '0123456789', 'a.nguyen@email.com', 'K03', 1),
('E002', N'Trần Thị B', 'F', '1985-02-20', N'Hà Nội', '0123456790', 'b.tran@email.com', 'K03', 0),
('E003', N'Phạm Văn C', 'M', '1990-03-25', N'Quảng Ninh', '0123456791', 'c.pham@email.com', 'K03', 0),
('E004', N'Lê Thị D', 'F', '1988-04-30', N'Hải Phòng', '0123456792', 'd.le@email.com', 'K03', 0),
('E005', N'Nguyễn Văn E', 'M', '1975-05-05', N'Hà Nội', '0123456793', 'e.nguyen@email.com', 'K01', 1),
('E006', N'Trần Thị F', 'F', '1992-06-10', N'Hải Phòng', '0123456794', 'f.tran@email.com', 'K01', 0),
('E007', N'Phạm Văn G', 'M', '1983-07-15', N'Bắc Ninh', '0123456795', 'g.pham@email.com', 'K01', 0),
('E008', N'Lê Thị H', 'F', '1986-08-20', N'Quảng Ninh', '0123456796', 'h.le@email.com', 'K01', 0),
('E009', N'Nguyễn Văn I', 'M', '1981-09-25', N'Hà Nội', '0123456797', 'i.nguyen@email.com', 'K19', 1),
('E010', N'Trần Thị J', 'F', '1993-10-30', N'Hà Nội', '0123456798', 'j.tran@email.com','K19', 0),
('E011', N'Phạm Văn K', 'M', '1980-11-15', N'Hà Nội', '0123456799', 'k.pham@email.com','K19', 0),
('E012', N'Lê Thị L', 'F', '1985-12-20', N'Hải Phòng', '0123456800', 'l.le@email.com', 'K36', 0),
('E013', N'Nguyễn Văn M', 'M', '1987-01-05', N'Hải Phòng', '0123456801', 'm.nguyen@email.com', 'K36', 1),
('E014', N'Trần Thị N', 'F', '1989-02-15', N'Hà Nội', '0123456802', 'n.tran@email.com', 'K36', 0),
('E015', N'Phạm Văn O', 'M', '1991-03-20', N'Hà Nam', '0123456803', 'o.pham@email.com', 'K36', 0),
('E016', N'Lê Thị P', 'F', '1994-04-25', N'Bắc Ninh', '0123456804', 'p.le@email.com', 'K44', 0),
('E017', N'Nguyễn Văn Q', 'M', '1990-05-30', N'Hà Nội', '0123456805', 'q.nguyen@email.com', 'K44', 0),
('E018', N'Trần Thị R', 'F', '1988-06-15', N'Hải Phòng', '0123456806', 'r.tran@email.com', 'K44', 1),
('E019', N'Phạm Văn S', 'M', '1983-07-20', N'Hà Nội', '0123456807', 's.pham@email.com', 'K44', 0),
('E020', N'Lê Thị T', 'F', '1985-08-25', N'Ninh Bình', '0123456808', 't.le@email.com', 'K00', 1),
('E021', N'Nguyễn Văn U', 'M', '1991-09-30', N'Hải Phòng', '0123456809', 'u.nguyen@email.com', 'K00', 0),
('E022', N'Trần Thị V', 'F', '1992-10-15', N'Hà Nội', '0123456810', 'v.tran@email.com', 'K00', 0),
('E023', N'Phạm Văn W', 'M', '1986-11-20', N'Quảng Ninh', '0123456811', 'w.pham@email.com', 'K00', 0);
GO

/****** INSERT VALUES FOR SERVICE TABLE ******/
INSERT INTO [Services] (ServiceID, ServiceName, ServicePrice) VALUES
(1, N'Nội soi phế quản dưới gây mê', 200000),
(2, N'Siêu âm ổ bụng', 500000),
(3, N'Siêu âm tim 4D', 300000),
(4, N'Thăm khám bệnh lý nội tiết', 250000),
(5, N'Lấy xét nghiệm tế bào học dịch khớp', 600000),
(6, N'Nội soi đường ruột', 250000),
(7, N'Xét nghiệm da', 300000),
(8, N'Laser điều trị da', 700000),
(9, N'Thẩm mỹ nâng cơ mặt', 800000),
(10, N'Khâu vết thương hở', 300000),
(11, N'Khám ngoại khoa', 300000),
(12, N'Phẫu thuật cắt ruột thừa', 1000000),
(13, N'Chăm sóc và thay băng vết thương', 200000),
(14, N'Siêu âm cơ xương khớp', 500000),
(15, N'Xét nghiệm sinh hóa', 400000),
(16, N'Xét nghiệm lipid máu', 300000),
(17, N'Xét nghiệm máu tổng quát', 500000),
(18, N'Chẩn đoán huyết học', 400000),
(19, N'Điều trị nội khoa huyết học', 600000),
(20, N'Xét nghiệm đông máu', 250000);
GO

/****** INSERT VALUES FOR DOCTOR TABLE ******/
INSERT INTO Doctor (DoctorID, JobTitle, Qualification) VALUES
('E001', N'Trưởng Khoa', N'Tiến sĩ'),
('E002', N'Bác sĩ', N'Thạc sĩ'),
('E003', N'Bác sĩ', N'Đại học'),
('E004', N'Thực tập sinh', N'Đại học'),
('E005', N'Trưởng Khoa', N'Thạc sĩ'),
('E006', N'Thực tập sinh', N'Đại học'),
('E007', N'Bác sĩ', N'Đại học'),
('E008', N'Bác sĩ', N'Đại học'),
('E009', N'Trưởng Khoa', N'Tiến sĩ'),
('E010', N'Bác sĩ', N'Đại học'),
('E011', N'Bác sĩ', N'Thạc sĩ'),
('E012', N'Bác sĩ', N'Thạc sĩ'),
('E013', N'Trưởng Khoa', N'Thạc sĩ'),
('E014', N'Bác sĩ', N'Đại học'),
('E015', N'Bác sĩ', N'Thạc sĩ');
GO

/****** INSERT VALUES FOR PATIENT TABLE ******/
INSERT INTO Patient (PatientID, PatientName, Gender, DateOfBirth, [Address], Phone, Email) VALUES
('P001', N'Nguyễn Văn A', 'M', '1980-01-15', N'Hà Nội', '0123456789', 'a.nguyen@email.com'),
('P002', N'Trần Thị B', 'F', '1985-02-20', N'Hà Nội', '0123456790', 'b.tran@email.com'),
('P003', N'Phạm Văn C', 'M', '1990-03-25', N'Quảng Ninh', '0123456791', 'c.pham@email.com'),
('P004', N'Lê Thị D', 'F', '1988-04-30', N'Hải Phòng', '0123456792', 'd.le@email.com'),
('P005', N'Nguyễn Văn E', 'M', '1975-05-05', N'Hà Nội', '0123456793', 'e.nguyen@email.com'),
('P006', N'Trần Thị F', 'F', '1992-06-10', N'Hải Phòng', '0123456794', 'f.tran@email.com'),
('P007', N'Phạm Văn G', 'M', '1983-07-15', N'Bắc Ninh', '0123456795', 'g.pham@email.com'),
('P008', N'Lê Thị H', 'F', '1986-08-20', N'Quảng Ninh', '0123456796', 'h.le@email.com'),
('P009', N'Nguyễn Văn I', 'M', '1981-09-25', N'Hà Nội', '0123456797', 'i.nguyen@email.com'),
('P010', N'Trần Thị J', 'F', '1993-10-30', N'Hà Nội', '0123456798', 'j.tran@email.com');
GO

/****** INSERT VALUES FOR APPOINTMENT TABLE ******/
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, [Status], AppointmentType) VALUES
(1, 'P001', 'E005', '2024-10-23 08:30', N'Xác nhận', N'Khám Bệnh'); 
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, [Status], AppointmentType) VALUES
(2, 'P002', 'E006', '2024-10-23 10:15', N'Xác nhận', N'Điều Trị');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, [Status], AppointmentType) VALUES
(3, 'P003', 'E007', '2024-10-24 09:00', N'Đã hủy', N'Khám Bệnh');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, [Status], AppointmentType) VALUES
(4, 'P004', 'E008', '2024-10-24 11:00', N'Xác nhận', N'Khám Bệnh');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, [Status], AppointmentType) VALUES
(5, 'P005', 'E005', '2024-10-25 13:45', N'Xác nhận', N'Điều Trị');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, [Status], AppointmentType) VALUES
(6, 'P006', 'E006', '2024-10-25 15:30', N'Xác nhận', N'Khám Bệnh');
GO

/****** INSERT VALUES FOR ORDERS TABLE ******/
INSERT INTO Orders (OrderID, AppointmentID, DoctorID, TechnicianID, OrderStatus, ScheduledDateTime, OrderType, ServiceID, Note) VALUES
(1, 1, 'E005', 'E014', N'Xác nhận', '2024-10-23 09:00:00', 'LabTest', 15, NULL); 
INSERT INTO Orders (OrderID, AppointmentID, DoctorID, TechnicianID, OrderStatus, ScheduledDateTime, OrderType, ServiceID, Note) VALUES
(2, 1, 'E005', 'E014',N'Xác nhận', '2024-10-23 09:30:00', 'LabTest', 20, NULL); 
INSERT INTO Orders (OrderID, AppointmentID, DoctorID, TechnicianID, OrderStatus, ScheduledDateTime, OrderType, ServiceID, Note) VALUES
(3, 2, 'E006', 'E010',N'Xác nhận', '2024-10-23 10:15:00', 'Treatment', 10, NULL); 
INSERT INTO Orders (OrderID, AppointmentID, DoctorID, TechnicianID, OrderStatus, ScheduledDateTime, OrderType, ServiceID, Note) VALUES
(4, 4, 'E008', 'E004', N'Xác nhận', '2024-10-24 11:25:00', 'RadiologyTest', 1, NULL); 
INSERT INTO Orders (OrderID, AppointmentID, DoctorID, TechnicianID, OrderStatus, ScheduledDateTime, OrderType, ServiceID, Note) VALUES
(5, 5, 'E005', 'E011',N'Xác nhận', '2024-10-25 15:00:00', 'Treatment', 12, NULL); 
INSERT INTO Orders (OrderID, AppointmentID, DoctorID, TechnicianID, OrderStatus, ScheduledDateTime, OrderType, ServiceID, Note) VALUES
(6, 5, 'E005', 'E003',N'Xác nhận', '2024-10-25 14:00:00', 'RadiologyTest', 6, NULL); 
INSERT INTO Orders (OrderID, AppointmentID, DoctorID, TechnicianID, OrderStatus, ScheduledDateTime, OrderType, ServiceID, Note) VALUES
(7, 6, 'E006','E003', N'Xác nhận', '2024-10-25 15:45:00', 'LabTest', 5, NULL); 
INSERT INTO Orders (OrderID, AppointmentID, DoctorID, TechnicianID, OrderStatus, ScheduledDateTime, OrderType, ServiceID, Note) VALUES
(8, 6, 'E006', 'E004',  N'Xác nhận', '2024-10-25 15:55:00', 'RadiologyTest', 2, NULL); 
GO

/****** INSERT VALUES FOR LabTests TABLE ******/
INSERT INTO LabTests (TestID, OrderID, TestResultDate, SampleType, TestResult, LabValues, TestNote) VALUES
(1, 1, '2024-10-23', N'Mẫu máu', N'Kết quả cao vượt mức', N'Cholesterol: 5.2', NULL),  -- OrderID 1
(2, 2, '2024-10-23', N'Mẫu máu', N'Bình thường', N'PT: 11s, INR: 0.9', N'Kết quả ổn định'),  -- OrderID 2
(3, 7, '2024-10-26', N'Dịch khớp', N'Bình thường', N'Không có tế bào bất thường', N'Kết quả ổn định'); -- OrderID 7
GO

/****** INSERT VALUES FOR RadiologyTests TABLE ******/
INSERT INTO RadiologyTests (RadiologyID, OrderID, TestResultDate, TestResult, TestNote) VALUES
(1, 4, '2024-10-24', N'Kết quả bình thường', N'Nội soi phế quản không phát hiện bất thường'), -- OrderID 4
(2, 5, '2024-10-24', N'Ruột thừa bị tổn thương nặng', N'Nhiều vết viêm loét lớn và rộng'), -- OrderID 5
(3, 8, '2024-10-25', N'Không phát hiện bất thường', N'Siêu âm ổ bụng bình thường'); -- OrderID 8
GO

/****** INSERT VALUES FOR RadiologyImages TABLE ******/
INSERT INTO RadiologyImages (ImageID, RadiologyID, ImagePath, CaptureDate, ImageDescription) VALUES
(1, 1, '/images/bronchoscopy_result_1.jpg', '2024-10-24', N'Hình ảnh nội soi phế quản dưới 1'),	-- RadiologyID 1
(2, 1, '/images/bronchoscopy_result_2.jpg', '2024-10-24', N'Hình ảnh nội soi phế quản dưới 2'),	-- RadiologyID 1
(3, 2, '/images/ruotthua_result_1.jpg', '2024-10-24', N'Hình ảnh nội soi ruột thừa 1'),	-- RadiologyID 1
(4, 2, '/images/ruotthua_result_2.jpg', '2024-10-24', N'Hình ảnh nội soi ruột thừa 2'),	-- RadiologyID 1
(5, 3, '/images/abdominal_ultrasound_result_1.jpg', '2024-10-25', N'Hình ảnh siêu âm ổ bụng 1'), -- RadiologyID 3
(6, 3, '/images/abdominal_ultrasound_result_2.jpg', '2024-10-25', N'Hình ảnh siêu âm ổ bụng 2'),	-- RadiologyID 3
(7, 3, '/images/abdominal_ultrasound_result_3.jpg', '2024-10-25', N'Hình ảnh siêu âm ổ bụng 3');	-- RadiologyID 3
GO

/****** INSERT VALUES FOR Bill TABLE ******/ 
INSERT INTO Bill (BillID, PatientID, TotalFee, [DateTime], [Status], Note) VALUES
(1, 'P001', 650000, '2024-10-23 09:00', N'Đã thanh toán', N'Hóa đơn thanh toán các dịch vụ sử dụng'),
(2, 'P002', 300000, '2024-10-23 11:00', N'Đã thanh toán', N'Hóa đơn thanh toán các dịch vụ sử dụng'),
(4, 'P004', 200000, '2024-10-24 12:00', N'Đã thanh toán', N'Hóa đơn thanh toán các dịch vụ sử dụng'),
(5, 'P005', 1000000, '2024-10-24 12:00', N'Đã thanh toán', N'Hóa đơn thanh toán các dịch vụ sử dụng');
-- TEST CREATE BILL AND BILL DETAILS WITH APPOINTMENT 6
-- TEST CREATE BILL AFTER FINISH INPATIENT TREATMENT WITH INPATIENT TREATMENT ID 1
GO

/****** INSERT VALUES FOR BillDetails TABLE ******/ --FIXXXXXXXXXX
INSERT INTO BillDetails (BillDetailID, BillID, ServiceID, Quantity, FeePerService, TotalAmount) VALUES
(1, 1, 15, 1, 400000, 400000),  -- Xét nghiệm sinh hóa
(2, 1, 20, 1, 250000, 250000), -- Xét nghiệm đông máu
(3, 2, 10, 1, 300000, 300000),  -- Khâu vết thương hở
(5, 4, 1, 1, 200000, 200000),   -- Nội soi phế quản dưới gây mê
(6, 5, 12, 1, 1000000, 1000000);  -- Phẫu thuật cắt ruột thừa
GO

/****** INSERT VALUES FOR RoomType TABLE ******/
INSERT INTO RoomType (TypeID, Capacity, RoomFee, [Description]) VALUES
(1, 1, 2000000, 'Loại 1'),
(2, 2, 1500000, 'Loại 2'),
(3, 4, 1000000, 'Loại 3'),
(4, 6, 800000, 'Loại4');
GO

/****** INSERT VALUES FOR RoomDetail TABLE ******/
INSERT INTO RoomDetail (RoomID, TypeID, RoomNumber, BedsOccupied) VALUES
('R001', 1, '101', 1),
('R002', 2, '102', 0),
('R003', 3, '201', 0),
('R004', 4, '202', 0),
('R005', 1, '203', 0);
GO

/****** INSERT VALUES FOR InpatientTreatment TABLE ******/
INSERT INTO InpatientTreatment (InpatientID, PatientID, RoomID, AdmitDate, DischargeDate) VALUES
(1, 'P002', 'R003', '2024-10-23 12:00:00', '2024-10-25 12:00:00'),  -- Bệnh nhân P002, đã xuất viện từ R003
(2, 'P005', 'R001', '2024-10-24 12:00:00', NULL);  -- Bệnh nhân P005 đang điều trị
GO


/****** INSERT VALUES FOR NurseAssignment TABLE ******/ 
INSERT INTO NurseAssignment (AssignmentID, InpatientID, NurseID, ShiftStart, ShiftEnd, CareDescription) VALUES
(1, 1, 'E020', '2024-10-23 12:00:00', '2024-10-23 22:00:00', N'Kiểm tra huyết áp, tiêm thuốc theo chỉ định.'),  -- Bệnh nhân P002
(2, 1, 'E021', '2024-10-24 08:00:00', '2024-10-23 22:00:00', N'Theo dõi tình trạng sức khỏe, thay băng vết thương.'), -- Bệnh nhân P002
(3, 2, 'E022', '2024-10-24 12:00:00', '2024-10-24 22:00:00', N'Theo dõi, đánh giá tình trạng bệnh nhân.'),  -- Bệnh nhân P005
(4, 1, 'E023', '2024-10-24 16:00:00', '2024-10-24 20:00:00', N'Dấu hiệu chuyển biến tích cực, chuẩn bị xuất viện'), -- Bệnh nhân P002
(5, 2, 'E020', '2024-10-25 08:00:00', '2024-10-25 16:00:00', N'Theo dõi, đánh giá tình trạng bệnh nhân.');  -- Bệnh nhân P005
GO


/****** INSERT VALUES FOR MedicalRecord TABLE ******/ 
INSERT INTO MedicalRecord (RecordID, PatientID, AppointmentID,InpatientID, RecordDate, Summary, Diagnosis, RecordBy) VALUES
(1, 'P001', 1, NULL, '2024-10-23', N'Bệnh nhân có triệu chứng thường xuyên chảy máu cam, và các xét nghiệm đều cho kết quả không tốt', N'Máu khó đông cấp độ 1', 'E005'),
(2, 'P002', 2, 1, '2024-10-23', N'Gót chân bị rách, cần phải khâu vết thương', N'Vết thương hở', 'E006'),
(3, 'P004', 4, NULL, '2024-10-24', N'Cổ họng đỏ rát, hơi sưng tấy, điều trị bằng thuốc trong vài ngày', N'Bình thường', 'E008'),
(4, 'P005', 5, 1, '2024-10-25', N'Bệnh nhân nhập viện trong tình trạng đau bụng dữ dội, sau khi kiểm tra ruột bị viêm loét nặng cần cắt bỏ', N'Viêm ruột thừa', 'E005'),
(5, 'P006', 6, NULL, '2024-10-25', N'Các kết quả không có dấu hiệu bất thường, chướng bụng do tiêu hóa', N'Bình thường', 'E006');
GO

/****** INSERT VALUES FOR Medicine TABLE ******/ 
INSERT INTO Medicine (MedicineID, MedicineName, MedicinePrice, DosageForm, RouteOfAdministration) VALUES
('M001', N'Paracetamol', 15000, N'Viên nén', N'Uống'),
('M002', N'Ibuprofen', 25000, N'Viên nén', N'Uống'),
('M003', N'Amoxicillin', 30000, N'Viên nang', N'Uống'),
('M004', N'Cetirizine', 20000, N'Viên nén', N'Uống'),
('M005', N'Loratadine', 22000, N'Viên nén', N'Uống'),
('M006', N'Omeprazole', 40000, N'Viên nén', N'Uống'),
('M007', N'Metformin', 35000, N'Viên nén', N'Uống');
GO

/****** INSERT VALUES FOR MedicineStorage TABLE ******/ 
INSERT INTO MedicineStorage (IndexID, MedicineID, ProductionDate, ExpiryDate, Manufacturer, Quantity, BatchNumber) VALUES
(1, 'M001', '2024-01-15', '2026-01-15', N'Công ty A', 100, 'BATCH001'),
(2, 'M002', '2023-05-10', '2025-05-10', N'Công ty B', 50, 'BATCH002'),
(3, 'M003', '2024-03-20', '2026-03-20', N'Công ty C', 200, 'BATCH003'),
(4, 'M004', '2023-11-15', '2025-11-15', N'Công ty D', 80, 'BATCH004'),
(5, 'M005', '2024-02-10', '2026-02-10', N'Công ty E', 120, 'BATCH005'),
(6, 'M006', '2024-04-25', '2026-04-25', N'Công ty F', 60, 'BATCH006'),
(7, 'M007', '2023-09-30', '2025-09-30', N'Công ty G', 150, 'BATCH007'),
(8, 'M001', '2024-05-15', '2026-05-15', N'Công ty H', 90, 'BATCH008'),
(9, 'M002', '2024-03-05', '2026-03-05', N'Công ty I', 200, 'BATCH009'),
(10, 'M003', '2023-12-01', '2025-12-01', N'Công ty J', 75, 'BATCH010');
GO

/****** INSERT VALUES FOR Prescription TABLE ******/ 
INSERT INTO Prescription (PrescriptionID, RecordID, MedicineID, [DateTime], Quantity, UsageDuration) VALUES
(1, 1, 'M001', '2024-10-24 09:00:00', 30, N'1 viên 2 lần/ngày trong 10 ngày'),
(2, 1, 'M002', '2024-10-24 09:30:00', 15, N'1 viên 3 lần/ngày trong 7 ngày'),
(3, 2, 'M003', '2024-10-24 10:15:00', 20, N'2 viên 1 lần/ngày trong 5 ngày'),
(4, 3, 'M004', '2024-10-24 11:00:00', 10, N'1 viên 1 lần/ngày trong 14 ngày'),
(5, 4, 'M005', '2024-10-24 13:45:00', 25, N'1 viên 1 lần/ngày trong 7 ngày'),
(6, 4, 'M006', '2024-10-24 15:30:00', 40, N'2 viên 2 lần/ngày trong 10 ngày'),
(7, 4, 'M005', '2024-10-24 13:45:00', 25, N'1 viên 1 lần/ngày trong 7 ngày'),
(8, 5, 'M006', '2024-10-24 15:30:00', 8, N'2 viên 2 lần/ngày trong 2 ngày');
GO
