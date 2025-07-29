
DO $$ DECLARE
    r RECORD;
BEGIN
    -- Drop all tables
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;

    -- Drop all types (like ENUM)
    FOR r IN (SELECT n.nspname, t.typname
              FROM pg_type t
              JOIN pg_namespace n ON n.oid = t.typnamespace
              WHERE t.typtype = 'e' AND n.nspname = 'public') LOOP
        EXECUTE 'DROP TYPE IF EXISTS public.' || quote_ident(r.typname) || ' CASCADE';
    END LOOP;

    -- Drop all sequences
    FOR r IN (SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = 'public') LOOP
        EXECUTE 'DROP SEQUENCE IF EXISTS public.' || quote_ident(r.sequence_name) || ' CASCADE';
    END LOOP;

END $$;

SET TIME ZONE 'Asia/Ho_Chi_Minh';

-- grade
CREATE TABLE grade (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

INSERT INTO grade (name) VALUES
('khối 1'),
('khối 2'),
('khối 3'),
('khối 4'),
('khối 5');


-- class
CREATE TABLE class (
    id SERIAL PRIMARY KEY,
    grade_id INT REFERENCES grade(id),
    name VARCHAR(50) NOT NULL
);

-- Giả sử grade.id từ 1 đến 5 tương ứng với "khối 1" đến "khối 5"
INSERT INTO class (grade_id, name) VALUES
(1, 'lớp 1A'),
(1, 'lớp 1B'),
(2, 'lớp 2A'),
(2, 'lớp 2B'),
(3, 'lớp 3A'),
(3, 'lớp 3B'),
(4, 'lớp 4A'),
(4, 'lớp 4B'),
(5, 'lớp 5A'),
(5, 'lớp 5B');


--Admin
CREATE TABLE Admin (
  id SERIAL PRIMARY KEY,
  supabase_uid UUID UNIQUE,
  email VARCHAR(255) UNIQUE,
  name VARCHAR(255) not null,
  dob DATE not null,
  isMale BOOLEAN not null,
  address TEXT not null,
  phone_number VARCHAR(20),
  profile_img_url TEXT,
  email_confirmed BOOLEAN DEFAULT false not null,
  is_deleted BOOLEAN DEFAULT false not null,
  last_invitation_at TIMESTAMP DEFAULT null,
  created_at TIMESTAMP DEFAULT now()
);
-- start admin id from 100000
ALTER SEQUENCE admin_id_seq RESTART WITH 100000;

INSERT INTO Admin (
  supabase_uid,
  email,
  name,
  dob,
  isMale,
  address,
  phone_number,
  profile_img_url,
  email_confirmed,
  last_invitation_at,
  created_at
)
VALUES (
  '1cbb67d3-eaa9-48f4-a577-dcf6bfee9bbb',
  'mndkhanh@gmail.com',
  'Trần Văn Thánh',
  '1977-05-10',
  true,
  'Chung cư cao cấp Vinhomes, Hà nội',
  '0123456789',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg',
  true,
  '2025-06-14 07:26:19',
  '2025-06-14 07:26:19'
);


--Nurse
CREATE TABLE Nurse (
  id SERIAL PRIMARY KEY,
  supabase_uid UUID UNIQUE,
  email VARCHAR(255) UNIQUE,
  name VARCHAR(255) not null,
  dob DATE not null,
  isMale BOOLEAN not null,
  address TEXT not null,
  phone_number VARCHAR(20),
  profile_img_url TEXT,
  email_confirmed BOOLEAN DEFAULT false not null,
  is_deleted BOOLEAN DEFAULT false not null,
  last_invitation_at TIMESTAMP DEFAULT null,
  created_at TIMESTAMP DEFAULT now()
);
-- start nurse id from 100000
ALTER SEQUENCE nurse_id_seq RESTART WITH 100000;

-- Câu lệnh INSERT đầy đủ
INSERT INTO Nurse (
  supabase_uid,
  email,
  name,
  dob,
  isMale,
  address,
  phone_number,
  profile_img_url,
  email_confirmed,
  last_invitation_at,
  created_at
)
VALUES (
  '322526ca-3a47-494a-a0fa-4866f0af9477',
  'mndkhanh3@gmail.com',
  'Nguyễn Ngọc Quyên',
  '1977-05-10',
  false,
  'Chung cư Xài Bầu, Hà nội',
  '0123456789',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg',
  true,
  '2025-06-14 07:26:19',
  '2025-06-14 07:26:19'
);




-- Parent
CREATE TABLE Parent (
  id SERIAL PRIMARY KEY,
  supabase_uid UUID UNIQUE,
  email VARCHAR(255) UNIQUE,
  name VARCHAR(255) not null,
  dob DATE not null,
  isMale BOOLEAN not null,
  address TEXT not null,
  phone_number VARCHAR(20),
  profile_img_url TEXT,
  email_confirmed BOOLEAN DEFAULT false not null,
  is_deleted BOOLEAN DEFAULT false not null,
  last_invitation_at TIMESTAMP DEFAULT null,
  created_at TIMESTAMP DEFAULT now()
);

-- start parent id from 100000
ALTER SEQUENCE parent_id_seq RESTART WITH 100000;

INSERT INTO parent (
  supabase_uid, email, name, dob, isMale, address, phone_number, profile_img_url,
  email_confirmed, last_invitation_at, created_at
) VALUES
  (
    'be258789-4fe3-421c-baed-53ef3ed87f3b',
    'phamthanhqb2005@gmail.com',
    'Mai Nguyễn Duy Khánh',
    '1989-03-10',
    true,
    'Xóm trọ Cần Co, Hà Nội',
    '0123456789',
    'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg',
    true,
    '2025-06-14 07:26:19',
    '2025-06-14 07:26:19'
  ),
  (
    '3dfa7d35-7f0f-449f-afbf-bb6e420016d2',
    'dathtse196321@gmail.com',
    'Đinh Việt Hiếu',
    '1974-03-10',
    true,
    'Chợ Lớn, Hà Nội',
    '0123456789',
    'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg',
    true,
    '2025-06-14 07:26:19',
    '2025-06-14 07:26:19'
  ),
  (
    '00f7f4c0-4998-4593-b9c4-6b8d74596cd9',
    'mndkhanh.alt3@gmail.com',
    'Hoàng Tấn Đạt',
    '1980-05-09',
    true,
    'Chung cư Xóm Nhỏ, Quận Hoàn Kiếm, Hà Nội',
    '0123456789',
    'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg',
    true,
    '2025-06-14 07:26:19',
    '2025-06-14 07:26:19'
  ),
  (
    '81705d11-3052-4d70-82f2-1c11e8077dbe',
    'mndkhanh.alt@gmail.com',
    'Phạm Thành Phúc',
    '1985-05-22',
    true,
    'Vinhomes Smart City, Hồ Tây, Hà Nội',
    '0123321123',
    'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg',
    true,
    '2025-06-14 07:26:19',
    '2025-06-14 07:26:19'
  );

-- RESTART parent_id để bắt đầu từ 100004 nếu cần
ALTER SEQUENCE parent_id_seq RESTART WITH 100004;
INSERT INTO parent (
  name, dob, isMale, address, phone_number, profile_img_url, last_invitation_at, created_at
)
VALUES
('Nguyễn Văn An',  '1980-01-01', true,  'Hà Nội', '0900000001', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Trần Thị Bình',  '1982-02-02', false, 'Hà Nội', '0900000002', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Lê Văn Cường',  '1981-03-03', true,  'Hà Nội', '0900000003', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Phạm Thị Dung',  '1983-04-04', false, 'Hà Nội', '0900000004', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Vũ Văn Em',      '1979-05-05', true,  'Hà Nội', '0900000005', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Hoàng Thị Gấm',  '1981-06-06', false, 'Hà Nội', '0900000006', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Đào Văn Hưng',   '1980-07-07', true,  'Hà Nội', '0900000007', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Nguyễn Thị Hòa', '1982-08-08', false, 'Hà Nội', '0900000008', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Bùi Văn Khoa',   '1981-09-09', true,  'Hà Nội', '0900000009', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Lê Thị Lan',     '1984-10-10', false, 'Hà Nội', '0900000010', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Phạm Văn Minh',  '1980-11-11', true,  'Hà Nội', '0900000011', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Võ Thị Ngọc',    '1983-12-12', false, 'Hà Nội', '0900000012', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Trịnh Văn Quân', '1981-01-13', true,  'Hà Nội', '0900000013', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Mai Thị Quỳnh',  '1984-02-14', false, 'Hà Nội', '0900000014', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Ngô Văn Sơn',    '1980-03-15', true,  'Hà Nội', '0900000015', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Đinh Thị Trang', '1983-04-16', false, 'Hà Nội', '0900000016', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Trần Văn Út',    '1979-05-17', true,  'Hà Nội', '0900000017', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Vũ Thị Vân',     '1982-06-18', false, 'Hà Nội', '0900000018', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Hoàng Văn Xuân','1980-07-19', true,  'Hà Nội', '0900000019', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Đặng Thị Yến',   '1983-08-20', false, 'Hà Nội', '0900000020', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Phan Văn Đông',  '1981-09-21', true,  'Hà Nội', '0900000021', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Nguyễn Thị Hoa', '1984-10-22', false, 'Hà Nội', '0900000022', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Bùi Văn Nam',    '1980-11-23', true,  'Hà Nội', '0900000023', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Trần Thị Hà',    '1983-12-24', false, 'Hà Nội', '0900000024', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Lê Văn Dũng',    '1981-01-25', true,  'Hà Nội', '0900000025', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Phạm Thị Oanh',  '1984-02-26', false, 'Hà Nội', '0900000026', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Nguyễn Văn Trí','1980-03-27', true,  'Hà Nội', '0900000027', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Hoàng Thị Mai',  '1983-04-28', false, 'Hà Nội', '0900000028', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Đỗ Văn Toàn',    '1981-05-29', true,  'Hà Nội', '0900000029', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59'),
('Vũ Thị Thu',     '1984-06-30', false, 'Hà Nội', '0900000030', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files/anonymous-avatar.jpg', null, '2025-06-30 23:59:59');


--Student
CREATE TABLE student_code_counter (
  year_of_enrollment INT PRIMARY KEY,
  last_number INT DEFAULT 1000
);

insert into student_code_counter (year_of_enrollment, last_number) VALUES 
(2021, 1003); -- bắt đầu với 4 học sinh trong data mẫu 211000, 211001, 211002, 211003

CREATE TABLE Student (
      id varchar(10) PRIMARY KEY,
	    supabase_uid UUID unique,
      email VARCHAR(255) UNIQUE,
      name VARCHAR(255) not null,
      dob DATE not null,
      isMale BOOLEAN not null,
      address TEXT not null,
      phone_number VARCHAR(20),
      profile_img_url TEXT,
      year_of_enrollment int not null,
      email_confirmed BOOLEAN DEFAULT false not null,
      class_id INT REFERENCES class(id) not null,
      mom_id int REFERENCES parent(id),
      dad_id int REFERENCES parent(id),
  is_deleted BOOLEAN DEFAULT false not null,
  last_invitation_at TIMESTAMP DEFAULT null,
  created_at TIMESTAMP DEFAULT now()
);

INSERT INTO Student (
  id,
  supabase_uid,
  email,
  name,
  dob,
  isMale,
  address,
  phone_number,
  profile_img_url,
  year_of_enrollment,
  email_confirmed,
  class_id,
  mom_id,
  dad_id,
  last_invitation_at,
  created_at
)
VALUES 
(
  '211000',
  '550934ca-e6ee-456f-b40c-d7fdc173342b',
  'toannangcao3000@gmail.com',
  'Phạm Thành Kiến',
  '2015-05-10',
  true,
  'Vinhomes Smart City, Hồ Tây, Hà Nội',
  '0123456789',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg',
  2021,
  true,
  1,
  100003,
  NULL,
  '2025-06-15 12:00:00',
  '2025-06-15 12:00:00'
),
(
  '211001',
  'fc57f7ed-950e-46fb-baa5-7914798e9ae3',
  'dinhviethieu2910@gmail.com',
  'Hoàng Tấn Tạ Yến',
  '2014-02-10',
  false,
  'Chung cư Xóm Nhỏ, Quận Hoàn Kiếm, Hà Nội',
  '0123456789',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg',
  2021,
  true,
  2,
  100003,
  100002,
  '2025-06-15 12:00:00',
  '2025-06-15 12:00:00'
),
(
  '211002',
  '1519af26-f341-471b-8471-ab33a061b657',
  'thuandtse150361@fpt.edu.vn',
  'Mai Triệu Phú',
  '2013-02-10',
  true,
  'Xóm trọ Cần Co, Hà Nội',
  '0123456789',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg',
  2021,
  true,
  2,
  NULL,
  100000,
  '2025-06-15 12:00:00',
  '2025-06-15 12:00:00'
),
(
  '211003',
  'ab9f1dc3-8b35-4b0c-9327-f677c3247143',
  'coccamco.fpthcm@gmail.com',
  'Mai Thanh Trieu Phu',
  '2013-02-10',
  false,
  'Xóm trọ Cần Co, Hà Nội',
  '0123456789',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg',
  2021,
  true,
  2,
  100001,
  100000,
  '2025-06-15 12:00:00',
  '2025-06-15 12:00:00'
);

-- Cập nhật student_code_counter để phản ánh số học sinh mới
UPDATE student_code_counter
SET last_number = 1033
WHERE year_of_enrollment = 2021;

INSERT INTO student (
  id, name, dob, isMale, address, phone_number, profile_img_url,
  year_of_enrollment, class_id, mom_id, dad_id,
  last_invitation_at, created_at
)
VALUES
-- 15 học sinh lớp 1
('211004', 'Nguyễn An Khang', '2015-01-01', false, 'Hà Nội', '0901000001', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100005, 100004, NULL, '2025-06-30 23:59:59'),
('211005', 'Trần Gia Hưng', '2015-01-02', false, 'Hà Nội', '0901000002', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100007, 100006, NULL, '2025-06-30 23:59:59'),
('211006', 'Lê Ngọc Bảo', '2015-01-03', true, 'Hà Nội', '0901000003', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100009, 100008, NULL, '2025-06-30 23:59:59'),
('211007', 'Phạm Nhật Minh', '2015-01-04', true, 'Hà Nội', '0901000004', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100011, 100010, NULL, '2025-06-30 23:59:59'),
('211008', 'Vũ Tuệ Nhi', '2015-01-05', true, 'Hà Nội', '0901000005', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100013, 100012, NULL, '2025-06-30 23:59:59'),
('211009', 'Đào Hải Đăng', '2015-01-06', true, 'Hà Nội', '0901000006', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100015, 100014, NULL, '2025-06-30 23:59:59'),
('211010', 'Nguyễn Nhật Linh', '2015-01-07', true, 'Hà Nội', '0901000007', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100017, 100016, NULL, '2025-06-30 23:59:59'),
('211011', 'Bùi Hoàng Long', '2015-01-08', true, 'Hà Nội', '0901000008', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100019, 100018, NULL, '2025-06-30 23:59:59'),
('211012', 'Phạm Mai Chi', '2015-01-09', true, 'Hà Nội', '0901000009', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100021, 100020, NULL, '2025-06-30 23:59:59'),
('211013', 'Trịnh Minh Nhật', '2015-01-10', true, 'Hà Nội', '0901000010', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100023, 100022, NULL, '2025-06-30 23:59:59'),
('211014', 'Ngô Gia Bảo', '2015-01-11', true, 'Hà Nội', '0901000011', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100025, 100024, NULL, '2025-06-30 23:59:59'),
('211015', 'Đinh Hồng Anh', '2015-01-12', true, 'Hà Nội', '0901000012', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100027, 100026, NULL, '2025-06-30 23:59:59'),
('211016', 'Trần Quang Duy', '2015-01-13', true, 'Hà Nội', '0901000013', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100029, 100028, NULL, '2025-06-30 23:59:59'),
('211017', 'Vũ Thanh Trúc', '2015-01-14', true, 'Hà Nội', '0901000014', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100031, 100030, NULL, '2025-06-30 23:59:59'),
('211018', 'Hoàng Nhật Tân', '2015-01-15', true, 'Hà Nội', '0901000015', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 1, 100033, 100032, NULL, '2025-06-30 23:59:59'),

-- 15 học sinh lớp 2
('211019', 'Trần Gia Huy', '2014-01-01', true, 'Hà Nội', '0902000001', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100005, 100004, NULL, '2025-06-30 23:59:59'),
('211020', 'Vũ Hải Yến', '2014-01-02', true, 'Hà Nội', '0902000002', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100007, 100006, NULL, '2025-06-30 23:59:59'),
('211021', 'Hoàng Minh Khôi', '2014-01-03', false, 'Hà Nội', '0902000003', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100009, 100008, NULL, '2025-06-30 23:59:59'),
('211022', 'Đặng Ngọc Trinh', '2014-01-04', false, 'Hà Nội', '0902000004', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100011, 100010, NULL, '2025-06-30 23:59:59'),
('211023', 'Phan Đức Anh', '2014-01-05', false, 'Hà Nội', '0902000005', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100013, 100012, NULL, '2025-06-30 23:59:59'),
('211024', 'Nguyễn Minh Thư', '2014-01-06', false, 'Hà Nội', '0902000006', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100015, 100014, NULL, '2025-06-30 23:59:59'),
('211025', 'Bùi Nhật Hào', '2014-01-07', false, 'Hà Nội', '0902000007', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100017, 100016, NULL, '2025-06-30 23:59:59'),
('211026', 'Trần Khánh Vy', '2014-01-08', false, 'Hà Nội', '0902000008', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100019, 100018, NULL, '2025-06-30 23:59:59'),
('211027', 'Lê Hoàng Anh', '2014-01-09', true, 'Hà Nội', '0902000009', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100021, 100020, NULL, '2025-06-30 23:59:59'),
('211028', 'Phạm Thảo Nhi', '2014-01-10', true, 'Hà Nội', '0902000010', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100023, 100022, NULL, '2025-06-30 23:59:59'),
('211029', 'Nguyễn Minh Hiếu', '2014-01-11', true, 'Hà Nội', '0902000011', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100025, 100024, NULL, '2025-06-30 23:59:59'),
('211030', 'Trịnh Hồng Nhung', '2014-01-12', false, 'Hà Nội', '0902000012', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100027, 100026, NULL, '2025-06-30 23:59:59'),
('211031', 'Hoàng Thế Anh', '2014-01-13', true, 'Hà Nội', '0902000013', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100029, 100028, NULL, '2025-06-30 23:59:59'),
('211032', 'Ngô Ánh Tuyết', '2014-01-14', false, 'Hà Nội', '0902000014', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100031, 100030, NULL, '2025-06-30 23:59:59'),
('211033', 'Đào Khánh Duy', '2014-01-15', true, 'Hà Nội', '0902000015', 'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/public-files//anonymous-avatar.jpg', 2021, 2, 100033, 100032, NULL, '2025-06-30 23:59:59');




---------------------------------------------------------------------FLOW SEND MEDICATION REQUEST 
-------------------------------------------------------------------------------------------------

CREATE TYPE senddrugrequest_status AS ENUM (
    'PROCESSING',
    'ACCEPTED',
    'RECEIVED',
    'DONE',
    'CANCELLED',
    'REFUSED'
);

CREATE TABLE SendDrugRequest (
    id SERIAL PRIMARY KEY,
	  student_id varchar(10) references student(id), 
	  create_by int references parent(id),
    diagnosis TEXT NOT NULL,
    schedule_send_date DATE,
    receive_date DATE,
    intake_date DATE,
    note TEXT,
    prescription_img_urls TEXT[],
    status senddrugrequest_status NOT NULL
);

INSERT INTO SendDrugRequest (
    student_id, create_by, diagnosis, schedule_send_date, receive_date,
    intake_date, note, prescription_img_urls, status
) VALUES 
(
    '211000', -- student_id
    100003,   -- create_by
    'Viêm dạ dày cấp',
    '2025-06-10',
    NULL,
    '2025-06-11',
    'Cần gửi thuốc sớm',
    ARRAY['https://luatduonggia.vn/wp-content/uploads/2025/06/quy-dinh-ve-noi-dung-ke-don-thuoc1.jpg', 'https://cdn.lawnet.vn//uploads/NewsThumbnail/2019/02/26/0852441417662920-thuc-pham-chuc-nang.jpg'],
    'PROCESSING'
),
(
    '211002',
    100000,
    'TVCĐ',
    '2025-06-09',
    '2025-06-10',
    '2025-06-11',
    'Nhà trường giúp cháu uống thuốc đúng giờ',
    ARRAY['https://cdn.lawnet.vn//uploads/NewsThumbnail/2019/02/26/0852441417662920-thuc-pham-chuc-nang.jpg'],
    'DONE'
),
(
    '211001',
    100002,
    'Nhiễm trùng hô hấp trên cấp/ăn kém',
    '2025-06-08',
    NULL,
    '2025-06-09',
    'Gia đình muốn gửi thêm thuốc',
    ARRAY['https://static.tuoitre.vn/tto/i/s626/2011/04/12/2FiN0VCC.jpg'],
    'CANCELLED'
);



CREATE TABLE RequestItem (
    id SERIAL PRIMARY KEY,
    request_id INT NOT NULL REFERENCES SendDrugRequest(id),
    name VARCHAR(255),
    intake_template_time VARCHAR(255)[] NOT NULL,
    dosage_usage TEXT NOT NULL
);

INSERT INTO RequestItem (request_id, name, intake_template_time, dosage_usage) VALUES
(1, 'Amoxycilin 500mg (Upanmox)', ARRAY['Trước khi ăn sáng', 'Trước khi ăn tối'], 'mỗi lần 2 viên'),
(1, 'Metrodinazol 250mg/v', ARRAY['Trước khi ăn sáng', 'Trước khi ăn tối'], 'mỗi lần 2 viên'),
(2, 'Seotalac', ARRAY['Sau ăn trưa', 'Sau ăn tối'], 'mỗi lần 1 viên'),
(2, 'Độc hoạt TKS viên (Lọ/100v)', ARRAY['Sau ăn sáng', 'Sau ăn trưa', 'Sau ăn tối'], 'mỗi lần 3 viên'),
(2, 'Đại tần giao', ARRAY['Sau ăn sáng', 'Sau ăn trưa', 'Sau ăn tối'], 'mỗi lần 3 viên'),
(3, 'Bimoclar', ARRAY['Sau ăn sáng', 'Sau ăn trưa'], 'uống mỗi lần 8ml'),
(3, 'Rinofil', ARRAY['Sau ăn trưa'], 'uống mỗi lần 5ml');

--------------------------------------------------------------------------------------------------------------------------------End FLOW SEND MEDICATION REQUEST 

------------------------------------------------------------------------------------------------------------------------------------FLOW CHECKUP CAMPAIGN
----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TYPE campaign_status AS ENUM (
   'DRAFTED',
   'PREPARING',
    'UPCOMING',
    'CANCELLED',
    'DONE',
    'ONGOING'
);

CREATE TABLE CheckupCampaign (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    start_date DATE,
	end_date DATE,
    status campaign_status NOT NULL DEFAULT 'DRAFTED'
);

INSERT INTO CheckupCampaign (name, description, location, start_date, end_date, status) VALUES
('Khám sức khỏe định kỳ học sinh năm 2022', 'Chiến dịch khám sức khỏe tổng quát cho toàn bộ học sinh trong trường. Thời gian dự kiến: 8h sáng.', 'nhà đà năng tầng 4', '2022-08-01', '2022-08-02', 'DONE'),
('Khám sức khỏe định kỳ học sinh năm 2023', 'Chiến dịch khám sức khỏe tổng quát cho toàn bộ học sinh trong trường. Thời gian dự kiến: 8h sáng.', 'nhà đà năng tầng 4', '2023-8-05', '2023-08-06', 'DONE'),
('Khám sức khỏe định kỳ học sinh năm 2024', 'Chiến dịch khám sức khỏe tổng quát cho toàn bộ học sinh trong trường', 'nhà đa năng tầng 4', '2024-05-15', '2025-05-16', 'DONE'),
('Khám sức khỏe định kỳ học sinh năm 2025', 'Chiến dịch khám sức khỏe tổng quát cho toàn bộ học sinh trong trường', 'nhà đa năng tầng 4', '2025-08-15', '2025-08-26', 'DRAFTED');

CREATE TABLE SpecialistExamList (
	id serial primary key,
	name VARCHAR(100) NOT NULL,
  is_deleted BOOLEAN DEFAULT false,
    description TEXT
);

INSERT INTO SpecialistExamList (name, description) VALUES
('Khám sinh dục', 'Khám sinh dục nhằm đánh giá tình trạng phát triển cơ quan sinh dục ở trẻ em và thanh thiếu niên, phát hiện các dấu hiệu bất thường liên quan đến cơ quan sinh sản, dậy thì sớm hoặc muộn, và tư vấn các vấn đề vệ sinh cá nhân, phòng tránh các bệnh lây qua đường tình dục. Đây là bước quan trọng trong việc theo dõi sự phát triển toàn diện của học sinh.'),
('Khám tâm lý', 'Khám tâm lý học đường giúp phát hiện sớm các vấn đề liên quan đến tâm lý, cảm xúc và hành vi của học sinh như lo âu, trầm cảm, rối loạn hành vi, căng thẳng học tập hoặc xung đột với gia đình. Các chuyên gia tâm lý sẽ đánh giá và tư vấn các chiến lược hỗ trợ phù hợp để học sinh ổn định tâm lý, phát triển kỹ năng sống và học tập hiệu quả.'),
('Khám tâm thần', 'Khám tâm thần là quá trình đánh giá các triệu chứng liên quan đến rối loạn tâm thần như rối loạn cảm xúc, rối loạn lo âu, rối loạn phát triển, hoặc các vấn đề về hành vi có tính nghiêm trọng hơn. Bác sĩ chuyên khoa tâm thần sẽ tiến hành khai thác bệnh sử, đánh giá lâm sàng và có thể chỉ định điều trị hoặc can thiệp chuyên sâu khi cần thiết.'),
('Khám xâm lấn', 'Khám xâm lấn bao gồm các thủ thuật có tác động trực tiếp đến cơ thể như lấy máu để làm xét nghiệm, tiêm ngừa vaccine, hoặc thực hiện các thủ thuật chẩn đoán như sinh thiết. Các thủ thuật này đòi hỏi tuân thủ nghiêm ngặt quy trình vô trùng và an toàn y khoa, nhằm đảm bảo độ chính xác trong chẩn đoán cũng như hạn chế tối đa rủi ro cho học sinh.');

CREATE TABLE CampaignContainSpeExam (
    campaign_id INT NOT NULL,
    specialist_exam_id INT NOT NULL,
    PRIMARY KEY (campaign_id, specialist_exam_id),
    FOREIGN KEY (campaign_id) REFERENCES CheckupCampaign(id) ON DELETE CASCADE,
    FOREIGN KEY (specialist_exam_id) REFERENCES SpecialistExamList(id) ON DELETE CASCADE
);

INSERT INTO CampaignContainSpeExam (campaign_id, specialist_exam_id) VALUES
(1, 1), -- Khám sinh dục
(1, 3); -- Khám tâm thần


INSERT INTO CampaignContainSpeExam (campaign_id, specialist_exam_id) VALUES
(2, 2); -- Khám tâm lý (ví dụ, hoặc bạn có thể thêm các chuyên khoa khác nếu có)


INSERT INTO CampaignContainSpeExam (campaign_id, specialist_exam_id) VALUES
(3, 4);


CREATE TYPE register_status AS ENUM (
    'PENDING',
    'SUBMITTED',
    'CANCELLED'
);

CREATE TABLE CheckupRegister (
    id SERIAL PRIMARY KEY,
    campaign_id INT NOT NULL,
    student_id varchar(10) NOT NULL,
    submit_by int,
    submit_time TIMESTAMP,
    reason TEXT,
    status register_status NOT NULL DEFAULT 'PENDING',
    FOREIGN KEY (campaign_id) REFERENCES CheckupCampaign(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES Student(id) ON DELETE CASCADE,
    -- submit_by có thể là mẹ hoặc bố, nên FK không rõ ràng, bạn có thể không đặt FK hoặc tạo thêm bảng phụ huynh riêng
    -- nếu submit_by trỏ đến bảng Parent thì FK như sau:
    FOREIGN KEY (submit_by) REFERENCES Parent(id) ON DELETE CASCADE
);

---Campaign 1
-- 10 học sinh đã nộp
INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, status, reason) VALUES
(1, '211000', 100003, '2022-07-25 08:00:00', 'SUBMITTED', 'Đồng ý tham gia khám chuyên khoa'),
(1, '211001', 100003, '2022-07-26 08:00:00', 'SUBMITTED', 'Đồng ý'),
(1, '211002', 100000, '2022-07-25 08:00:00', 'SUBMITTED', 'Chấp nhận tham gia'),
(1, '211003', 100000, '2022-07-27 08:00:00', 'SUBMITTED', 'Đồng ý tham gia khám chuyên khoa'),
(1, '211004', 100005, '2022-07-28 08:00:00', 'SUBMITTED', 'Đồng ý'),
(1, '211005', 100007, '2022-07-25 08:00:00', 'SUBMITTED', 'Chấp nhận tham gia'),
(1, '211006', 100009, '2022-07-27 08:00:00', 'SUBMITTED', 'Đồng ý tham gia khám chuyên khoa'),
(1, '211007', 100011, '2022-07-28 08:00:00', 'SUBMITTED', 'Đồng ý'),
(1, '211008', 100013, '2022-07-29 08:00:00', 'SUBMITTED', 'Chấp nhận tham gia'),
(1, '211009', 100015, '2022-07-30 08:00:00', 'SUBMITTED', 'Đồng ý tham gia khám chuyên khoa');


-- 24 học sinh chưa nộp (PENDING)
INSERT INTO CheckupRegister (campaign_id, student_id, status) VALUES
(1, '211010', 'PENDING'),
(1, '211011', 'PENDING'),
(1, '211012', 'PENDING'),
(1, '211013', 'PENDING'),
(1, '211014', 'PENDING'),
(1, '211015', 'PENDING'),
(1, '211016', 'PENDING'),
(1, '211017', 'PENDING'),
(1, '211018', 'PENDING'),
(1, '211019', 'PENDING'),
(1, '211020', 'PENDING'),
(1, '211021', 'PENDING'),
(1, '211022', 'PENDING'),
(1, '211023', 'PENDING'),
(1, '211024', 'PENDING'),
(1, '211025', 'PENDING'),
(1, '211026', 'PENDING'),
(1, '211027', 'PENDING'),
(1, '211028', 'PENDING'),
(1, '211029', 'PENDING'),
(1, '211030', 'PENDING'),
(1, '211031', 'PENDING'),
(1, '211032', 'PENDING'),
(1, '211033', 'PENDING');


UPDATE CheckupRegister
SET status = 'CANCELLED'
WHERE status = 'PENDING' AND campaign_id = 1;

---Campaign 2
-- 24 bản ghi đầu: status = PENDING (mặc định)
INSERT INTO CheckupRegister (campaign_id, student_id)
VALUES
(2, '211000'),
(2, '211001'),
(2, '211002'),
(2, '211003'),
(2, '211004'),
(2, '211005'),
(2, '211006'),
(2, '211007'),
(2, '211008'),
(2, '211009'),
(2, '211010'),
(2, '211011'),
(2, '211012'),
(2, '211013'),
(2, '211014'),
(2, '211015'),
(2, '211016'),
(2, '211017'),
(2, '211018'),
(2, '211019'),
(2, '211020'),
(2, '211021'),
(2, '211022'),
(2, '211023');

UPDATE CheckupRegister
SET status = 'CANCELLED'
WHERE status = 'PENDING' AND campaign_id = 2;

-- 10 bản ghi cuối: status = SUBMITTED, submit_by = 1, submit_time từ 2023-06-01 đến 2023-06-07
INSERT INTO CheckupRegister (campaign_id, student_id, status, submit_by, submit_time, reason)
VALUES
(2, '211024', 'SUBMITTED', 100015, '2023-06-01 10:00:00', 'Đồng ý tham gia khám chuyên khoa'),
(2, '211025', 'SUBMITTED', 100017, '2023-06-02 11:15:00', 'Đồng ý'),
(2, '211026', 'SUBMITTED', 100019, '2023-06-02 14:30:00', 'Chấp nhận tham gia'),
(2, '211027', 'SUBMITTED', 100020, '2023-06-03 09:00:00', 'Đồng ý tham gia khám chuyên khoa'),
(2, '211028', 'SUBMITTED', 100023, '2023-06-04 08:45:00', 'Đồng ý'),
(2, '211029', 'SUBMITTED', 100024, '2023-06-04 15:10:00', 'Chấp nhận tham gia'),
(2, '211030', 'SUBMITTED', 100026, '2023-06-05 12:00:00', 'Đồng ý tham gia khám chuyên khoa'),
(2, '211031', 'SUBMITTED', 100028, '2023-06-06 13:30:00', 'Đồng ý'),
(2, '211032', 'SUBMITTED', 100030, '2023-06-06 16:45:00', 'Chấp nhận tham gia'),
(2, '211033', 'SUBMITTED', 100033, '2023-06-07 10:20:00', 'Đồng ý tham gia khám chuyên khoa');

---Campaign 3

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211000', 100003, '2024-05-07 07:36:00', 'Chấp thuận theo yêu cầu nhà trường', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211001', 100003, '2024-05-10 16:51:00', 'Đồng ý khám sức khỏe', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211002', 100000, '2024-05-09 15:13:00', 'Phụ huynh đồng thuận', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211003', 100000, '2024-05-07 20:33:00', 'Đã trao đổi với giáo viên', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211004', 100004, '2024-05-07 08:13:00', 'Chấp thuận theo yêu cầu nhà trường', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211005', 100006, '2024-05-09 01:37:00', 'Chấp thuận theo yêu cầu nhà trường', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211006', 100008, '2024-05-10 07:56:00', 'Phụ huynh xác nhận tham gia', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211007', 100010, '2024-05-07 13:55:00', 'Không có lý do đặc biệt, đồng ý', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211008', 100012, '2024-05-07 19:52:00', 'Chấp thuận theo yêu cầu nhà trường', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211009', 100014, '2024-05-10 08:11:00', 'Đồng ý tham gia', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211010', 100017, '2024-05-10 23:48:00', 'Sẵn sàng cho buổi khám', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211011', 100018, '2024-05-10 08:00:00', 'Đã trao đổi với giáo viên', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211012', 100020, '2024-05-07 12:46:00', 'Đã trao đổi với giáo viên', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211013', 100022, '2024-05-09 07:46:00', 'Sẵn sàng cho buổi khám', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211014', 100024, '2024-05-07 14:26:00', 'Đã trao đổi với giáo viên', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211015', 100026, '2024-05-08 04:52:00', 'Không có lý do đặc biệt, đồng ý', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211016', 100028, '2024-05-09 02:51:00', 'Không có lý do đặc biệt, đồng ý', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211017', 100030, '2024-05-08 20:35:00', 'Đồng ý khám sức khỏe', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211018', 100032, '2024-05-07 07:02:00', 'Được gia đình cho phép', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211019', 100005, '2024-05-10 19:58:00', 'Chấp thuận theo yêu cầu nhà trường', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211020', 100006, '2024-05-10 01:23:00', 'Chấp thuận theo yêu cầu nhà trường', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211021', 100009, '2024-05-08 18:09:00', 'Không có lý do đặc biệt, đồng ý', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211022', 100010, '2024-05-10 07:56:00', 'Sẵn sàng cho buổi khám', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211023', 100013, '2024-05-10 15:43:00', 'Đồng ý khám sức khỏe', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211024', 100014, '2024-05-07 21:05:00', 'Đã đăng ký qua giáo viên chủ nhiệm', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211025', 100017, '2024-05-07 10:27:00', 'Đã trao đổi với giáo viên', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211026', 100018, '2024-05-07 18:20:00', 'Chấp thuận theo yêu cầu nhà trường', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211027', 100021, '2024-05-09 01:34:00', 'Đã trao đổi với giáo viên', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211028', 100023, '2024-05-10 13:24:00', 'Chấp thuận theo yêu cầu nhà trường', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211029', 100025, '2024-05-09 03:50:00', 'Chấp thuận theo yêu cầu nhà trường', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211030', 100027, '2024-05-07 08:11:00', 'Phụ huynh đồng thuận', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211031', 100029, '2024-05-09 21:50:00', 'Không có lý do đặc biệt, đồng ý', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211032', 100031, '2024-05-09 14:19:00', 'Đồng ý khám sức khỏe', 'SUBMITTED');

INSERT INTO CheckupRegister (campaign_id, student_id, submit_by, submit_time, reason, status)
VALUES (3, '211033', 100033, '2024-05-10 11:01:00', 'Chấp thuận theo yêu cầu nhà trường', 'SUBMITTED');


create type health_record_status as enum ('CANCELLED','WAITING', 'DONE');
CREATE TABLE HealthRecord (
    id SERIAL PRIMARY KEY,
    register_id INT UNIQUE REFERENCES CheckupRegister(id) ON DELETE CASCADE,

    height VARCHAR(10),
    weight VARCHAR(10),
    blood_pressure VARCHAR(20),
    left_eye VARCHAR(10),
    right_eye VARCHAR(10),
    ear VARCHAR(50),
    nose VARCHAR(50),
    throat VARCHAR(50),
    teeth VARCHAR(50),
    gums VARCHAR(50),
    skin_condition VARCHAR(100),
    heart VARCHAR(100),
    lungs VARCHAR(100),
    spine VARCHAR(100),
    posture VARCHAR(100),
    record_url text DEFAULT NULL,
    final_diagnosis TEXT,
	date_record TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	is_checked BOOLEAN DEFAULT FALSE,
	status health_record_status NOT NULL DEFAULT 'WAITING'
);
---Campaign 1
INSERT INTO HealthRecord (
    register_id, height, weight, blood_pressure, left_eye, right_eye,
    ear, nose, throat, teeth, gums, skin_condition,
    heart, lungs, spine, posture,
    record_url, final_diagnosis, is_checked, status, date_record
) VALUES
(1, '145', '38', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Tốt', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Cong nhẹ', 'Hơi lệch', NULL, 'Thiếu cân, cận nhẹ', true, 'DONE', '2022-08-02 08:00:00'),
(2, '150', '43', '110/70', '10/10', '10/10', 'Bình thường', 'Viêm nhẹ', 'Ổn định', 'Không sâu', 'Bình thường', 'Da khô', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2022-08-02 08:00:00'),
(3, '155', '48', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Hơi đỏ', 'Không sâu', 'Bình thường', 'Không bệnh ngoài da', 'Bình thường', 'Tốt', 'Thẳng', 'Hơi lệch', NULL, 'Họng đỏ nhẹ', true, 'DONE', '2022-08-02 08:00:00'),
(4, '148', '40', '100/65', '10/10', '9/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Tốt', 'Không bệnh ngoài da', 'Tốt', 'Bình thường', 'Thẳng', 'Bình thường', NULL, 'Thị lực giảm nhẹ', true, 'DONE', '2022-08-02 08:00:00'),
(5, '160', '52', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Hơi khò khè', 'Không sâu', 'Tốt', 'Bình thường', 'Bình thường', 'Khò nhẹ', 'Thẳng', 'Bình thường', NULL, 'Khò nhẹ', true, 'DONE', '2022-08-02 08:00:00'),
(6, '142', '36', '90/60', '9/10', '9/10', 'Viêm tai', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da khô', 'Bình thường', 'Tốt', 'Thẳng', 'Lệch vai', NULL, 'Viêm tai giữa nhẹ', true, 'DONE', '2022-08-02 08:00:00'),
(7, '163', '58', '120/80', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Khỏe mạnh', true, 'DONE', '2022-08-02 08:00:00'),
(8, '155', '65', '120/80', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Viêm nhẹ', 'Sâu nặng', 'Viêm lợi', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Cong nặng', 'Lệch hông', NULL, 'Cần điều trị răng miệng', true, 'DONE', '2022-08-02 08:00:00'),
(9, '158', '46', '100/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Khỏe mạnh', true, 'DONE', '2022-08-02 08:00:00'),
(10, '150', '35', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Hơi gầy', true, 'DONE', '2022-08-02 08:00:00'),
(11, '165', '70', '120/80', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Tốt', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Thừa cân nhẹ', true, 'DONE', '2022-08-02 08:00:00'),
(12, '153', '44', '110/70', '10/10', '10/10', 'Viêm tai', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Thẳng', 'Lệch nhẹ', NULL, 'Cần theo dõi tai', true, 'DONE', '2022-08-02 08:00:00'),
(13, '160', '50', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Viêm lợi nhẹ', 'Da khô', 'Tốt', 'Tốt', 'Thẳng', 'Hơi gù', NULL, 'Cần đánh răng đều', true, 'DONE', '2022-08-02 08:00:00'),
(14, '149', '41', '100/65', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da mẫn cảm', 'Tốt', 'Tốt', 'Cong nhẹ', 'Lệch nhẹ', NULL, 'Viêm da dị ứng', true, 'DONE', '2022-08-02 08:00:00'),
(15, '152', '55', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2022-08-02 08:00:00'),
(16, '145', '38', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Tốt', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Cong nhẹ', 'Hơi lệch', NULL, 'Thiếu cân, cận nhẹ', true, 'DONE', '2022-08-02 08:00:00'),
(17, '150', '43', '110/70', '10/10', '10/10', 'Bình thường', 'Viêm nhẹ', 'Ổn định', 'Không sâu', 'Bình thường', 'Da khô', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2022-08-02 08:00:00'),
(18, '155', '48', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Hơi đỏ', 'Không sâu', 'Bình thường', 'Không bệnh ngoài da', 'Bình thường', 'Tốt', 'Thẳng', 'Hơi lệch', NULL, 'Họng đỏ nhẹ', true, 'DONE', '2022-08-02 08:00:00'),
(19, '148', '40', '100/65', '10/10', '9/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Tốt', 'Không bệnh ngoài da', 'Tốt', 'Bình thường', 'Thẳng', 'Bình thường', NULL, 'Thị lực giảm nhẹ', true, 'DONE', '2022-08-02 08:00:00'),
(20, '160', '52', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Hơi khò khè', 'Không sâu', 'Tốt', 'Bình thường', 'Bình thường', 'Khò nhẹ', 'Thẳng', 'Bình thường', NULL, 'Khò nhẹ', true, 'DONE', '2022-08-02 08:00:00'),
(21, '142', '36', '90/60', '9/10', '9/10', 'Viêm tai', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da khô', 'Bình thường', 'Tốt', 'Thẳng', 'Lệch vai', NULL, 'Viêm tai giữa nhẹ', true, 'DONE', '2022-08-02 08:00:00'),
(22, '163', '58', '120/80', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Khỏe mạnh', true, 'DONE', '2022-08-02 08:00:00'),
(23, '155', '65', '120/80', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Viêm nhẹ', 'Sâu nặng', 'Viêm lợi', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Cong nặng', 'Lệch hông', NULL, 'Cần điều trị răng miệng', true, 'DONE', '2022-08-02 08:00:00'),
(24, '158', '46', '100/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Khỏe mạnh', true, 'DONE', '2022-08-02 08:00:00'),
(25, '150', '35', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Hơi gầy', true, 'DONE', '2022-08-02 08:00:00'),
(26, '165', '70', '120/80', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Tốt', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Thừa cân nhẹ', true, 'DONE', '2022-08-02 08:00:00'),
(27, '153', '44', '110/70', '10/10', '10/10', 'Viêm tai', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Thẳng', 'Lệch nhẹ', NULL, 'Cần theo dõi tai', true, 'DONE', '2022-08-02 08:00:00'),
(28, '160', '50', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Viêm lợi nhẹ', 'Da khô', 'Tốt', 'Tốt', 'Thẳng', 'Hơi gù', NULL, 'Cần đánh răng đều', true, 'DONE', '2022-08-02 08:00:00'),
(29, '149', '41', '100/65', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da mẫn cảm', 'Tốt', 'Tốt', 'Cong nhẹ', 'Lệch nhẹ', NULL, 'Viêm da dị ứng', true, 'DONE', '2022-08-02 08:00:00'),
(30, '165', '70', '120/80', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Tốt', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Thừa cân nhẹ', true, 'DONE', '2022-08-02 08:00:00'),
(31, '153', '44', '110/70', '10/10', '10/10', 'Viêm tai', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Thẳng', 'Lệch nhẹ', NULL, 'Cần theo dõi tai', true, 'DONE', '2022-08-02 08:00:00'),
(32, '160', '50', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Viêm lợi nhẹ', 'Da khô', 'Tốt', 'Tốt', 'Thẳng', 'Hơi gù', NULL, 'Cần đánh răng đều', true, 'DONE', '2022-08-02 08:00:00'),
(33, '153', '44', '110/70', '10/10', '10/10', 'Viêm tai', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Thẳng', 'Lệch nhẹ', NULL, 'Cần theo dõi tai', true, 'DONE', '2022-08-02 08:00:00'),
(34, '160', '50', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Viêm lợi nhẹ', 'Da khô', 'Tốt', 'Tốt', 'Thẳng', 'Hơi gù', NULL, 'Cần đánh răng đều', true, 'DONE', '2022-08-02 08:00:00');


---Campaign 2
INSERT INTO HealthRecord (
    register_id, height, weight, blood_pressure, left_eye, right_eye,
    ear, nose, throat, teeth, gums, skin_condition,
    heart, lungs, spine, posture,
    record_url, final_diagnosis, is_checked, status, date_record
) VALUES
(35, '146', '39', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da bình thường',
 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Thiếu cân nhẹ', true, 'DONE', '2023-08-06'),
(36, '151', '45', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da thường',
 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', 'https://example.com/record36.pdf', 'Bình thường', true, 'DONE', '2023-08-06'),
(37, '156', '49', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Hơi đỏ', 'Không sâu', 'Tốt', 'Da thường',
 'Tốt', 'Tốt', 'Thẳng', 'Hơi lệch', NULL, 'Viêm họng nhẹ', true, 'DONE', '2023-08-06'),
(38, '149', '41', '100/65', '10/10', '9/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Tốt', 'Da bình thường',
 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Thị lực phải yếu nhẹ', true, 'DONE', '2023-08-06'),
(39, '161', '53', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Hơi khò khè', 'Không sâu', 'Tốt', 'Bình thường',
 'Bình thường', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Hô hấp nhẹ', true, 'DONE', '2023-08-06'),
(40, '143', '35', '90/60', '9/10', '9/10', 'Viêm tai nhẹ', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da khô',
 'Tốt', 'Tốt', 'Thẳng', 'Lệch vai nhẹ', 'https://example.com/record40.pdf', 'Viêm tai giữa nhẹ', true, 'DONE', '2023-08-06'),
(41, '164', '59', '120/80', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da thường',
 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Khỏe mạnh', true, 'DONE', '2023-08-06'),
(42, '156', '66', '120/80', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Viêm nhẹ', 'Sâu nặng', 'Viêm lợi',
 'Da khô', 'Tốt', 'Tốt', 'Cong nặng', 'Lệch hông', NULL, 'Cần điều trị răng lợi', true, 'DONE', '2023-08-06'),
(43, '159', '47', '100/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da thường',
 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(44, '152', '36', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường',
 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', 'https://example.com/record44.pdf', 'Hơi gầy', true, 'DONE', '2023-08-06'),
(45, '167', '72', '120/80', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Tốt', 'Da bình thường',
 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Thừa cân nhẹ', true, 'DONE', '2023-08-06'),
 (46, '155', '43', '110/70', '10/10', '10/10', 'Viêm tai nhẹ', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da khô',
 'Tốt', 'Tốt', 'Thẳng', 'Lệch nhẹ', NULL, 'Theo dõi tai', true, 'DONE', '2023-08-06'),
(47, '162', '51', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Viêm lợi nhẹ',
 'Da thường', 'Tốt', 'Tốt', 'Thẳng', 'Hơi gù', 'https://example.com/record47.pdf', 'Chăm sóc răng lợi', true, 'DONE', '2023-08-06'),
(48, '150', '42', '100/65', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da hơi nhạy',
 'Tốt', 'Tốt', 'Cong nhẹ', 'Lệch nhẹ', NULL, 'Viêm da nhẹ', true, 'DONE', '2023-08-06'),
(49, '153', '54', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da bình thường',
 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(50, '146', '38', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Tốt', 'Da thường',
 'Tốt', 'Tốt', 'Cong nhẹ', 'Hơi lệch', NULL, 'Cần theo dõi tư thế', true, 'DONE', '2023-08-06'),
(51, '151', '47', '110/70', '10/10', '10/10', 'Viêm tai nhẹ', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Da bình thường',
 'Tốt', 'Tốt', 'Thẳng', 'Lệch nhẹ', NULL, 'Nên tái khám tai', true, 'DONE', '2023-08-06'),
(52, '158', '49', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường',
 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', 'https://example.com/record52.pdf', 'Bình thường', true, 'DONE', '2023-08-06'),
(53, '150', '35', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Hơi đỏ', 'Không sâu', 'Tốt', 'Bình thường',
 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Họng đỏ nhẹ', true, 'DONE', '2023-08-06'),
(54, '165', '71', '120/80', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Tốt', 'Da thường',
 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Thừa cân nhẹ', true, 'DONE', '2023-08-06'),
(55, '153', '44', '110/70', '10/10', '10/10', 'Viêm tai', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường',
 'Tốt', 'Tốt', 'Thẳng', 'Lệch nhẹ', NULL, 'Cần theo dõi tai', true, 'DONE', '2023-08-06'),
(56, '165', '49', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Sâu nhẹ', 'Viêm lợi nhẹ', 'Da khô',
 'Tốt', 'Tốt', 'Thẳng', 'Hơi gù', NULL, 'Đánh răng đều', true, 'DONE', '2023-08-06'),
 (57, '162', '40', '100/65', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định',
 'Không sâu', 'Tốt', 'Da mẫn cảm', 'Tốt', 'Tốt', 'Cong nhẹ', 'Lệch nhẹ', NULL, 'Viêm da dị ứng', true, 'DONE', '2023-08-06'),
(58, '160', '56', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định',
 'Không sâu', 'Tốt', 'Da thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(59, '157', '39', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định',
 'Sâu nhẹ', 'Tốt', 'Da thường', 'Tốt', 'Tốt', 'Cong nhẹ', 'Hơi lệch', NULL, 'Thiếu cân, cận nhẹ', true, 'DONE', '2023-08-06'),
(60, '168', '44', '110/70', '10/10', '10/10', 'Bình thường', 'Viêm nhẹ', 'Ổn định',
 'Không sâu', 'Bình thường', 'Da khô', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', 'https://example.com/record60.pdf', 'Cần theo dõi viêm mũi', true, 'DONE', '2023-08-06'),
(61, '157', '49', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Hơi đỏ',
 'Không sâu', 'Bình thường', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Hơi lệch', NULL, 'Viêm họng nhẹ', true, 'DONE', '2023-08-06'),
(62, '165', '40', '100/65', '10/10', '9/10', 'Bình thường', 'Không viêm', 'Ổn định',
 'Sâu nhẹ', 'Tốt', 'Da thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Thị lực phải giảm nhẹ', true, 'DONE', '2023-08-06'),
(63, '155', '54', '110/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Hơi khò khè',
 'Không sâu', 'Tốt', 'Da thường', 'Tốt', 'Khò nhẹ', 'Thẳng', 'Bình thường', NULL, 'Cần theo dõi hô hấp', true, 'DONE', '2023-08-06'),
(64, '168', '37', '90/60', '9/10', '9/10', 'Viêm tai nhẹ', 'Không viêm', 'Ổn định',
 'Không sâu', 'Tốt', 'Da khô', 'Tốt', 'Tốt', 'Thẳng', 'Lệch vai nhẹ', NULL, 'Viêm tai giữa nhẹ', true, 'DONE', '2023-08-06'),
(65, '156', '59', '120/80', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định',
 'Không sâu', 'Tốt', 'Da thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', 'https://example.com/record65.pdf', 'Khỏe mạnh', true, 'DONE', '2023-08-06'),
(66, '162', '64', '120/80', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Viêm nhẹ',
 'Sâu nặng', 'Viêm lợi', 'Không bệnh ngoài da', 'Tốt', 'Tốt', 'Cong nặng', 'Lệch hông', NULL, 'Cần điều trị răng miệng', true, 'DONE', '2023-08-06'),
(67, '160', '46', '100/70', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định',
 'Không sâu', 'Tốt', 'Da bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Khỏe mạnh', true, 'DONE', '2023-08-06'),
(68, '163', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định',
 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Hơi gầy', true, 'DONE', '2023-08-06');

--Campaign 3
INSERT INTO HealthRecord (
    register_id, height, weight, blood_pressure, left_eye, right_eye,
    ear, nose, throat, teeth, gums, skin_condition,
    heart, lungs, spine, posture,
    record_url, final_diagnosis, is_checked, status, date_record
) VALUES
(69, '154', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(70, '154', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(71, '160', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(72, '154', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(73, '163', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(74, '155', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(75, '170', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(76, '163', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(77, '162', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(78, '161', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(79, '175', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(80, '162', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(81, '165', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(82, '163', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(83, '162', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(84, '164', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(85, '162', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(86, '163', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(87, '162', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(88, '164', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(89, '161', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(90, '167', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(91, '166', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(92, '162', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(93, '161', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(94, '173', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(95, '161', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(96, '168', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(97, '162', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(98, '172', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(99, '161', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(100, '166', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(101, '163', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06'),
(102, '164', '42', '100/60', '10/10', '10/10', 'Bình thường', 'Không viêm', 'Ổn định', 'Không sâu', 'Tốt', 'Bình thường', 'Tốt', 'Tốt', 'Thẳng', 'Bình thường', NULL, 'Bình thường', true, 'DONE', '2023-08-06');

CREATE TYPE specialist_exam_record_status AS ENUM ('CANNOT_ATTACH', 'WAITING', 'DONE');
CREATE TABLE specialistExamRecord (
    register_id INT NOT NULL,
    spe_exam_id INT NOT NULL,
    result TEXT,
    diagnosis TEXT,
    diagnosis_paper_urls TEXT[],
    is_checked BOOLEAN DEFAULT FALSE,
    dr_name VARCHAR(255) DEFAULT null,
    date_record TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status specialist_exam_record_status NOT NULL DEFAULT 'CANNOT_ATTACH',
    PRIMARY KEY (register_id, spe_exam_id),
    FOREIGN KEY (register_id) REFERENCES CheckupRegister(id),
    FOREIGN KEY (spe_exam_id) REFERENCES SpecialistExamList(id)
);

INSERT INTO specialistExamRecord (
    register_id, spe_exam_id, result, diagnosis, diagnosis_paper_urls, is_checked, dr_name, status, date_record
)
VALUES
(1, 1, 'Không phát hiện bất thường sinh dục.', 'Sinh dục bình thường.', ARRAY['https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/sinh-duc/sd_000.jpg'], TRUE, 'BS. Nguyễn Văn An', 'DONE', '2025-07-10 08:00:00'),
(1, 3, 'Không có dấu hiệu rối loạn tâm thần.', 'Tâm thần ổn định.', 
ARRAY[
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_000_1.jpg',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_000_2.jpg'
], TRUE, 'BS. Trần Thị Bích', 'DONE', '2025-07-10 08:05:00'),

(2, 1, 'Cơ quan sinh dục phát triển bình thường.', 'Không phát hiện dị tật.', ARRAY['https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/sinh-duc/sd_001.jpg'], TRUE, 'BS. Lê Minh Tuấn', 'DONE', '2025-07-10 08:10:00'),
(2, 3, 'Ứng xử phù hợp, không có dấu hiệu loạn thần.', 'Tâm thần trong giới hạn bình thường.', 
ARRAY[
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_001_1.jpg',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_001_2.jpg'
], TRUE, 'BS. Phạm Thị Hồng', 'DONE', '2025-07-10 08:15:00'),

(3, 1, 'Không có dấu hiệu bất thường bộ phận sinh dục.', 'Sinh dục ổn định.', ARRAY['https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/sinh-duc/sd_002.jpg'], TRUE, 'BS. Đỗ Văn Cường', 'DONE', '2025-07-10 08:20:00'),
(3, 3, 'Tâm trạng ổn định, không có hành vi bất thường.', 'Không phát hiện rối loạn tâm thần.', 
ARRAY[
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_002_1.jpg',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_002_2.jpg'
], TRUE, 'BS. Nguyễn Thị Mai', 'DONE', '2025-07-10 08:25:00'),

(4, 1, 'Kiểm tra sinh dục trong giới hạn bình thường.', 'Không có dấu hiệu bệnh lý.', ARRAY['https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/sinh-duc/sd_003.jpg'], TRUE, 'BS. Vũ Hoàng Nam', 'DONE', '2025-07-10 08:30:00'),
(4, 3, 'Không có dấu hiệu stress hay lo âu kéo dài.', 'Tâm lý ổn định.', 
ARRAY[
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_003_1.jpg',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_003_2.jpg'
], TRUE, 'BS. Lê Thị Thảo', 'DONE', '2025-07-10 08:35:00'),

(5, 1, 'Sinh dục không bị tổn thương.', 'Không phát hiện bất thường.', ARRAY['https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/sinh-duc/sd_004.jpg'], TRUE, 'BS. Trịnh Văn Hùng', 'DONE', '2025-07-10 08:40:00'),
(5, 3, 'Phản ứng cảm xúc phù hợp, giao tiếp tốt.', 'Tâm thần bình thường.', 
ARRAY[
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_004_1.jpg',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_004_2.jpg'
], TRUE, 'BS. Bùi Thị Lan', 'DONE', '2025-07-10 08:45:00'),

(6, 1, 'Bộ phận sinh dục phát triển theo độ tuổi.', 'Không có dấu hiệu bệnh lý.', ARRAY['https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/sinh-duc/sd_005.jpg'], TRUE, 'BS. Hồ Ngọc Hà', 'DONE', '2025-07-10 08:50:00'),
(6, 3, 'Nhận thức rõ ràng, trả lời câu hỏi phù hợp.', 'Tâm thần khỏe mạnh.', 
ARRAY[
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_005_1.jpg',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_005_2.jpg'
], TRUE, 'BS. Nguyễn Quốc Huy', 'DONE', '2025-07-10 08:55:00'),

(7, 1, 'Không phát hiện viêm nhiễm hoặc dị tật.', 'Khám sinh dục bình thường.', ARRAY['https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/sinh-duc/sd_006.jpg'], TRUE, 'BS. Đinh Thị Yến', 'DONE', '2025-07-10 09:00:00'),
(7, 3, 'Không có dấu hiệu rối loạn tâm trạng.', 'Tâm thần bình thường.', 
ARRAY[
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_006_1.jpg',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_006_2.jpg'
], TRUE, 'BS. Võ Minh Tâm', 'DONE', '2025-07-10 09:05:00'),

(8, 1, 'Sinh dục trong trạng thái khỏe mạnh.', 'Không có biểu hiện lâm sàng bất thường.', ARRAY['https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/sinh-duc/sd_007.jpg'], TRUE, 'BS. Hà Văn Quang', 'DONE', '2025-07-10 09:10:00'),
(8, 3, 'Không phát hiện bất ổn tâm lý.', 'Khám tâm thần trong giới hạn bình thường.', 
ARRAY[
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_007_1.jpg',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_007_2.jpg'
], TRUE, 'BS. Lý Thị Hạnh', 'DONE', '2025-07-10 09:15:00'),

(9, 1, 'Khám sinh dục không phát hiện bất thường.', 'Tình trạng sinh dục ổn định.', ARRAY['https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/sinh-duc/sd_008.jpg'], TRUE, 'BS. Nguyễn Hữu Tài', 'DONE', '2025-07-10 09:20:00'),
(9, 3, 'Tâm thần tỉnh táo, phản xạ nhanh.', 'Tâm thần tốt.', 
ARRAY[
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_008_1.jpg',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_000_1.jpg'
], TRUE, 'BS. Phan Thị Diễm', 'DONE', '2025-07-10 09:25:00'),

(10, 1, 'Không có dấu hiệu nhiễm trùng hay tổn thương.', 'Sinh dục trong giới hạn bình thường.', ARRAY['https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/sinh-duc/sd_009.jpg'], TRUE, 'BS. Tô Văn Khánh', 'DONE', '2025-07-10 09:30:00'),
(10, 3, 'Thái độ hợp tác tốt, không rối loạn hành vi.', 'Khám tâm thần bình thường.', 
ARRAY[
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_009_1.jpg',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/special-health-record/tam-than/tt_009_2.jpg'
], TRUE, 'BS. Trương Thị Thu', 'DONE', '2025-07-10 09:35:00');



----- FLOW VACCINATION CAMPAIGN
--disease
CREATE TABLE disease (
    id SERIAL PRIMARY KEY,
    disease_category TEXT CHECK (disease_category IN ('Bệnh mãn tính', 'Bệnh truyền nhiễm')),
    name TEXT NOT NULL,
    description TEXT,
    vaccine_need BOOLEAN,
    dose_quantity INT,
    CHECK (disease_category IN ('Bệnh truyền nhiễm', 'Bệnh mãn tính'))
);


-- Insert data into disease table
INSERT INTO disease (disease_category, name, description, vaccine_need) VALUES
-- Bệnh truyền nhiễm (giữ nguyên từ dữ liệu trước)
('Bệnh truyền nhiễm', 'Bạch hầu', 'Bệnh do vi khuẩn Corynebacterium diphtheriae gây ra, ảnh hưởng đến đường hô hấp', TRUE),
('Bệnh truyền nhiễm', 'Ho gà', 'Bệnh do vi khuẩn Bordetella pertussis gây ra, gây ho kéo dài', TRUE),
('Bệnh truyền nhiễm', 'Uốn ván', 'Bệnh do vi khuẩn Clostridium tetani gây ra, gây co cơ và co giật', TRUE),
('Bệnh truyền nhiễm', 'Bại liệt', 'Bệnh do virus polio gây ra, có thể gây liệt', TRUE),
('Bệnh truyền nhiễm', 'Viêm màng não mủ', 'Bệnh do vi khuẩn Haemophilus influenzae type b (Hib) hoặc não mô cầu gây ra', TRUE),
('Bệnh truyền nhiễm', 'Viêm phổi do Hib', 'Viêm phổi do vi khuẩn Haemophilus influenzae type b', TRUE),
('Bệnh truyền nhiễm', 'Viêm gan B', 'Bệnh do virus viêm gan B gây ra, ảnh hưởng đến gan', TRUE),
('Bệnh truyền nhiễm', 'Tiêu chảy cấp do Rota virus', 'Bệnh tiêu hóa do virus Rota gây ra, phổ biến ở trẻ em', TRUE),
('Bệnh truyền nhiễm', 'Các bệnh do phế cầu', 'Bệnh do vi khuẩn Streptococcus pneumoniae gây ra, bao gồm viêm phổi, viêm màng não', TRUE),
('Bệnh truyền nhiễm', 'Lao', 'Bệnh do vi khuẩn Mycobacterium tuberculosis gây ra, ảnh hưởng đến phổi', TRUE),
('Bệnh truyền nhiễm', 'Viêm màng não do não mô cầu', 'Bệnh do vi khuẩn Neisseria meningitidis gây ra', TRUE),
('Bệnh truyền nhiễm', 'Sởi', 'Bệnh do virus sởi gây ra, gây sốt và phát ban', TRUE),
('Bệnh truyền nhiễm', 'Quai bị', 'Bệnh do virus quai bị gây ra, gây sưng tuyến nước bọt', TRUE),
('Bệnh truyền nhiễm', 'Rubella', 'Bệnh do virus Rubella gây ra, gây phát ban và nguy hiểm cho thai nhi', TRUE),
('Bệnh truyền nhiễm', 'Thủy đậu', 'Bệnh do virus Varicella-zoster gây ra, gây phát ban và ngứa', TRUE),
('Bệnh truyền nhiễm', 'Zona thần kinh', 'Bệnh do virus Varicella-zoster tái hoạt động, gây đau và phát ban', TRUE),
('Bệnh truyền nhiễm', 'Cúm', 'Bệnh do virus cúm gây ra, ảnh hưởng đến đường hô hấp', TRUE),
('Bệnh mãn tính', 'Ung thư cổ tử cung do HPV', 'Ung thư do virus HPV gây ra, ảnh hưởng đến cổ tử cung', TRUE),
('Bệnh mãn tính', 'Ung thư hầu họng do HPV', 'Ung thư do virus HPV gây ra, ảnh hưởng đến hầu họng', TRUE),
('Bệnh mãn tính', 'Sùi mào gà do HPV', 'Bệnh do virus HPV gây ra, gây u nhú ở da và niêm mạc', TRUE),
('Bệnh truyền nhiễm', 'Sốt xuất huyết', 'Bệnh do virus Dengue gây ra, gây sốt cao và xuất huyết', TRUE),
('Bệnh truyền nhiễm', 'Viêm não Nhật Bản', 'Bệnh do virus viêm não Nhật Bản gây ra, ảnh hưởng đến não', TRUE),
('Bệnh truyền nhiễm', 'Dại', 'Bệnh do virus dại gây ra, gây tử vong nếu không điều trị', TRUE),
('Bệnh truyền nhiễm', 'Viêm gan A', 'Bệnh do virus viêm gan A gây ra, ảnh hưởng đến gan', TRUE),
('Bệnh truyền nhiễm', 'Thương hàn', 'Bệnh do vi khuẩn Salmonella Typhi gây ra, ảnh hưởng đến đường tiêu hóa', TRUE),
('Bệnh truyền nhiễm', 'Tả', 'Bệnh do vi khuẩn Vibrio cholerae gây ra, gây tiêu chảy cấp', TRUE),
('Bệnh truyền nhiễm', 'Sốt vàng', 'Bệnh do virus sốt vàng gây ra, ảnh hưởng đến gan và thận', TRUE),
-- Bệnh mãn tính (bổ sung thêm)
('Bệnh mãn tính', 'Tiểu đường type 1', 'Bệnh tự miễn làm tổn thương tế bào sản xuất insulin trong tuyến tụy', FALSE),
('Bệnh mãn tính', 'Tiểu đường type 2', 'Bệnh liên quan đến kháng insulin, thường gặp ở người lớn tuổi hoặc thừa cân', FALSE),
('Bệnh mãn tính', 'Tăng huyết áp', 'Tình trạng huyết áp cao kéo dài, gây nguy cơ đột quỵ và bệnh tim', FALSE),
('Bệnh mãn tính', 'Bệnh tim mạch', 'Các bệnh liên quan đến tim và mạch máu, bao gồm suy tim, nhồi máu cơ tim', FALSE),
('Bệnh mãn tính', 'Suy thận mạn', 'Suy giảm chức năng thận kéo dài, có thể dẫn đến dialysis', FALSE),
('Bệnh mãn tính', 'Viêm gan mạn tính không do virus', 'Viêm gan kéo dài do rượu, béo phì hoặc tự miễn, không do virus', FALSE),
('Bệnh mãn tính', 'Bệnh phổi tắc nghẽn mạn tính (COPD)', 'Bệnh phổi gây khó thở do tổn thương phế nang, thường do hút thuốc', FALSE),
('Bệnh mãn tính', 'Hen suyễn', 'Bệnh phổi mạn tính gây co thắt đường thở, dẫn đến khó thở', FALSE),
('Bệnh mãn tính', 'Viêm khớp dạng thấp', 'Bệnh tự miễn gây viêm và đau khớp kéo dài', FALSE),
('Bệnh mãn tính', 'Lupus ban đỏ hệ thống', 'Bệnh tự miễn ảnh hưởng đến nhiều cơ quan như da, khớp, thận', FALSE),
('Bệnh mãn tính', 'Ung thư phổi', 'Ung thư phát triển từ tế bào phổi, thường liên quan đến hút thuốc', FALSE),
('Bệnh mãn tính', 'Ung thư gan', 'Ung thư phát triển từ tế bào gan, thường liên quan đến viêm gan mạn hoặc xơ gan', FALSE),
('Bệnh mãn tính', 'Ung thư vú', 'Ung thư phát triển từ tế bào vú, phổ biến ở phụ nữ', FALSE),
('Bệnh mãn tính', 'Ung thư đại trực tràng', 'Ung thư phát triển từ đại tràng hoặc trực tràng', FALSE),
('Bệnh mãn tính', 'Bệnh Parkinson', 'Rối loạn thần kinh tiến triển gây run, cứng cơ và khó vận động', FALSE),
('Bệnh mãn tính', 'Bệnh Alzheimer', 'Bệnh thoái hóa thần kinh gây suy giảm trí nhớ và nhận thức', FALSE),
('Bệnh mãn tính', 'Loãng xương', 'Tình trạng xương mất mật độ, dễ gãy, thường gặp ở người lớn tuổi', FALSE),
('Bệnh mãn tính', 'Viêm loét dạ dày mạn tính', 'Viêm loét kéo dài ở niêm mạc dạ dày, thường do vi khuẩn HP hoặc stress', FALSE),
('Bệnh mãn tính', 'Bệnh gout', 'Bệnh do tích tụ axit uric gây viêm khớp, thường ở ngón chân cái', FALSE),
('Bệnh mãn tính', 'Động kinh', 'Rối loạn thần kinh gây co giật tái phát', FALSE),
('Bệnh mãn tính', 'Bệnh vảy nến', 'Bệnh tự miễn gây tổn thương da với các mảng đỏ, bong tróc', FALSE),
('Bệnh mãn tính', 'Bệnh Crohn', 'Bệnh viêm ruột mạn tính, ảnh hưởng đến đường tiêu hóa', FALSE),
('Bệnh mãn tính', 'Viêm đại tràng mạn tính', 'Viêm kéo dài ở đại tràng, gây tiêu chảy và đau bụng', FALSE),
('Bệnh mãn tính', 'Xơ gan', 'Tổn thương gan mạn tính do rượu, viêm gan hoặc các nguyên nhân khác', FALSE),
('Bệnh mãn tính', 'Suy giáp', 'Tuyến giáp hoạt động kém, gây mệt mỏi và tăng cân', FALSE),
('Bệnh mãn tính', 'Cường giáp', 'Tuyến giáp hoạt động quá mức, gây giảm cân và tim đập nhanh', FALSE);


--vaccine
CREATE TABLE vaccine (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    origin VARCHAR(100),
    description TEXT
);

-- Insert data into vaccine table
INSERT INTO vaccine (name, origin, description) VALUES
('Infanrix Hexa (6in1)', 'Bỉ', 'Vắc xin 6 trong 1 phòng bạch hầu, ho gà, uốn ván, bại liệt, viêm màng não mủ, viêm phổi do Hib, viêm gan B'),
('Hexaxim (6in1)', 'Pháp', 'Vắc xin 6 trong 1 phòng bạch hầu, ho gà, uốn ván, bại liệt, viêm màng não mủ, viêm phổi do Hib, viêm gan B'),
('Rotateq', 'Mỹ', 'Vắc xin uống phòng tiêu chảy cấp do Rota virus'),
('Rotarix', 'Bỉ', 'Vắc xin uống phòng tiêu chảy cấp do Rota virus'),
('Rotavin', 'Việt Nam', 'Vắc xin uống phòng tiêu chảy cấp do Rota virus'),
('Synflorix', 'Bỉ', 'Vắc xin phòng các bệnh do phế cầu khuẩn'),
('Prevenar 13', 'Bỉ', 'Vắc xin phòng 13 chủng phế cầu khuẩn'),
('Vaxneuvance', 'Ireland', 'Vắc xin phòng các bệnh do phế cầu khuẩn'),
('Prevenar 20', 'Bỉ', 'Vắc xin phòng 20 chủng phế cầu khuẩn'),
('Pneumovax 23', 'Mỹ', 'Vắc xin phòng 23 chủng phế cầu khuẩn'),
('BCG (lọ 1ml)', 'Việt Nam', 'Vắc xin phòng bệnh lao'),
('Gene Hbvax 1ml', 'Việt Nam', 'Vắc xin viêm gan B cho người lớn'),
('Heberbiovac 1ml', 'Cu Ba', 'Vắc xin viêm gan B cho người lớn'),
('Gene Hbvax 0.5ml', 'Việt Nam', 'Vắc xin viêm gan B cho trẻ em'),
('Heberbiovac 0.5ml', 'Cu Ba', 'Vắc xin viêm gan B cho trẻ em'),
('Bexsero', 'Ý', 'Vắc xin phòng viêm màng não do não mô cầu nhóm B'),
('VA-Mengoc-BC', 'Cu Ba', 'Vắc xin phòng viêm màng não do não mô cầu nhóm B, C'),
('MenQuadfi', 'Mỹ', 'Vắc xin phòng viêm màng não do não mô cầu nhóm A, C, Y, W-135'),
('Menactra', 'Mỹ', 'Vắc xin phòng viêm màng não do não mô cầu nhóm A, C, Y, W-135'),
('MVVac (Lọ 5ml)', 'Việt Nam', 'Vắc xin phòng bệnh sởi'),
('MVVac (Liều 0.5ml)', 'Việt Nam', 'Vắc xin phòng bệnh sởi'),
('MMR II (3 in 1)', 'Mỹ', 'Vắc xin 3 trong 1 phòng sởi, quai bị, rubella'),
('Priorix', 'Bỉ', 'Vắc xin 3 trong 1 phòng sởi, quai bị, rubella'),
('Varivax', 'Mỹ', 'Vắc xin phòng thủy đậu'),
('Varilrix', 'Bỉ', 'Vắc xin phòng thủy đậu'),
('Shingrix', 'Bỉ', 'Vắc xin phòng zona thần kinh'),
('Vaxigrip Tetra 0.5ml', 'Pháp', 'Vắc xin phòng cúm 4 chủng'),
('Influvac Tetra 0.5ml', 'Hà Lan', 'Vắc xin phòng cúm 4 chủng'),
('GC Flu Quadrivalent', 'Hàn Quốc', 'Vắc xin phòng cúm 4 chủng'),
('Ivacflu-S', 'Việt Nam', 'Vắc xin phòng cúm'),
('Gardasil 0.5ml', 'Mỹ', 'Vắc xin phòng các bệnh do HPV 4 chủng'),
('Gardasil 9 0.5ml', 'Mỹ', 'Vắc xin phòng các bệnh do HPV 9 chủng'),
('Qdenga', 'Đức', 'Vắc xin phòng sốt xuất huyết'),
('Vắc xin uốn ván hấp phụ (TT)', 'Việt Nam', 'Vắc xin phòng uốn ván'),
('Huyết thanh uốn ván (SAT)', 'Việt Nam', 'Huyết thanh phòng uốn ván'),
('Imojev', 'Thái Lan', 'Vắc xin phòng viêm não Nhật Bản'),
('Jeev 3mcg/0.5ml', 'Ấn Độ', 'Vắc xin phòng viêm não Nhật Bản'),
('Jevax 1ml', 'Việt Nam', 'Vắc xin phòng viêm não Nhật Bản'),
('Verorab 0.5ml (TB)', 'Pháp', 'Vắc xin phòng dại tiêm bắp'),
('Verorab 0.5ml (TTD)', 'Pháp', 'Vắc xin phòng dại tiêm trong da'),
('Abhayrab 0.5ml (TB)', 'Ấn Độ', 'Vắc xin phòng dại tiêm bắp'),
('Abhayrab 0.5ml (TTD)', 'Ấn Độ', 'Vắc xin phòng dại tiêm trong da'),
('Adacel', 'Canada', 'Vắc xin phòng bạch hầu, ho gà, uốn ván'),
('Boostrix', 'Bỉ', 'Vắc xin phòng bạch hầu, ho gà, uốn ván'),
('Tetraxim', 'Pháp', 'Vắc xin 4 trong 1 phòng bạch hầu, ho gà, uốn ván, bại liệt'),
('Uốn ván, bạch hầu hấp phụ (Td) – Lọ 0.5ml', 'Việt Nam', 'Vắc xin phòng bạch hầu, uốn ván'),
('Uốn ván, bạch hầu hấp phụ (Td) - Liều', 'Việt Nam', 'Vắc xin phòng bạch hầu, uốn ván'),
('Twinrix', 'Bỉ', 'Vắc xin phòng viêm gan A và B'),
('Havax 0.5ml', 'Việt Nam', 'Vắc xin phòng viêm gan A'),
('Avaxim 80U', 'Pháp', 'Vắc xin phòng viêm gan A'),
('Typhoid VI', 'Việt Nam', 'Vắc xin phòng thương hàn'),
('Typhim VI', 'Pháp', 'Vắc xin phòng thương hàn'),
('Quimi-Hib', 'Cu Ba', 'Vắc xin phòng các bệnh do Hib'),
('Morcvax', 'Việt Nam', 'Vắc xin uống phòng tả'),
('Stamaril', 'Pháp', 'Vắc xin phòng sốt vàng');

CREATE TABLE vaccine_disease (
     vaccine_id INT PRIMARY KEY,
    disease_id INT[] NOT NULL,
    dose_quantity INT NOT NULL DEFAULT 1,
    vnvc BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (vaccine_id) REFERENCES vaccine(id)
);

-- Insert data into vaccine_disease table
INSERT INTO vaccine_disease (vaccine_id, disease_id, dose_quantity, vnvc) VALUES
(1,  ARRAY[1,2,3,4,5,6,7], 5, TRUE),         -- Infanrix Hexa
(2,  ARRAY[1,2,3,4,5,6,7], 5, TRUE),         -- Hexaxim
(3,  ARRAY[8], 3, TRUE),                     -- Rotateq
(4,  ARRAY[8], 3, TRUE),                     -- Rotarix
(5,  ARRAY[8], 3, TRUE),                     -- Rotavin
(6,  ARRAY[9], 4, TRUE),                     -- Synflorix
(7,  ARRAY[9], 4, TRUE),                     -- Prevenar 13
(8,  ARRAY[9], 4, TRUE),                     -- Vaxneuvance
(9,  ARRAY[9], 4, TRUE),                     -- Prevenar 20
(10, ARRAY[9], 4, TRUE),                     -- Pneumovax 23
(11, ARRAY[10], 1, TRUE),                    -- BCG
(12, ARRAY[7], 2, TRUE),                     -- Gene Hbvax 1ml
(13, ARRAY[7], 2, TRUE),                       -- Heberbiovac 1ml
(14, ARRAY[7], 2, TRUE),                     -- Gene Hbvax 0.5ml
(15, ARRAY[7], 2, TRUE),                       -- Heberbiovac 0.5ml
(16, ARRAY[11], 2, TRUE),                    -- Bexsero
(17, ARRAY[11], 2, TRUE),                    -- VA-Mengoc-BC
(18, ARRAY[11], 2, TRUE),                    -- MenQuadfi
(19, ARRAY[11], 2, TRUE),                    -- Menactra
(20, ARRAY[12], 1, FALSE),                    -- MVVac (5ml)
(21, ARRAY[12], 2, FALSE),                    -- MVVac (0.5ml)
(22, ARRAY[12,13,14], 2, TRUE),              -- MMR II
(23, ARRAY[12,13,14], 2, TRUE),              -- Priorix
(24, ARRAY[15], 2, TRUE),                    -- Varivax
(25, ARRAY[15], 2, TRUE),                    -- Varilrix
(26, ARRAY[16], 1, FALSE),                   -- Shingrix
(27, ARRAY[17], 3, TRUE),                    -- Vaxigrip Tetra
(28, ARRAY[17], 3, TRUE),                    -- Influvac Tetra
(29, ARRAY[17], 3, TRUE),                    -- GC Flu Quadrivalent
(30, ARRAY[17], 3, TRUE),                    -- Ivacflu-S
(31, ARRAY[18,19,20], 3, TRUE),              -- Gardasil
(32, ARRAY[18,19,20], 3, TRUE),              -- Gardasil 9
(33, ARRAY[21], 2, TRUE),                    -- Qdenga
(34, ARRAY[3], 1, FALSE),                     -- Vắc xin uốn ván hấp phụ (TT)
(35, ARRAY[3], 1, FALSE),                     -- Huyết thanh uốn ván (SAT)
(36, ARRAY[22], 2, TRUE),                    -- Imojev
(37, ARRAY[22], 2, TRUE),                    -- Jeev
(38, ARRAY[22], 2, TRUE),                    -- Jevax
(39, ARRAY[23], 1, FALSE),                    -- Verorab (TB)
(40, ARRAY[23], 1, FALSE),                    -- Verorab (TTD)
(41, ARRAY[23], 1, FALSE),                    -- Abhayrab (TB)
(42, ARRAY[23], 1, FALSE),                    -- Abhayrab (TTD)
(43, ARRAY[1,2,3], 1, FALSE),                 -- Adacel
(44, ARRAY[1,2,3], 1, FALSE),                 -- Boostrix
(45, ARRAY[1,2,3,4], 1, FALSE),               -- Tetraxim
(46, ARRAY[1,3], 1, FALSE),                   -- Uốn ván, bạch hầu hấp phụ (Td) – Lọ
(47, ARRAY[1,3], 1, FALSE),                   -- Uốn ván, bạch hầu hấp phụ (Td) – Liều
(48, ARRAY[7,24], 2, TRUE),                  -- Twinrix
(49, ARRAY[24], 1, FALSE),                    -- Havax
(50, ARRAY[24], 1, FALSE),                    -- Avaxim 80U
(51, ARRAY[25], 1, FALSE),                    -- Typhoid VI
(52, ARRAY[25], 1, FALSE),                    -- Typhim VI
(53, ARRAY[5,6], 2, FALSE),                   -- Quimi-Hib
(54, ARRAY[26], 2, TRUE),                    -- Morcvax
(55, ARRAY[27], 1, FALSE);                    -- Stamaril

--vaccination_campaign
CREATE TABLE vaccination_campaign (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
	  disease_id INT[] NOT NULL,
    vaccine_id INT NOT NULL,
    description TEXT,
    location VARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('DRAFTED', 'PREPARING', 'UPCOMING', 'CANCELLED', 'ONGOING', 'COMPLETED')),
    FOREIGN KEY (vaccine_id) REFERENCES vaccine(id)
);

--vaccination_campaign_register
CREATE TABLE vaccination_campaign_register (
    id SERIAL PRIMARY KEY,
    student_id varchar(10) NOT NULL,
	  campaign_id int not null,
    reason TEXT,
    is_registered BOOLEAN NOT NULL DEFAULT false,
    submit_time TIMESTAMP,
    submit_by int, -- parent ID
	  FOREIGN KEY (campaign_id) REFERENCES vaccination_campaign(id),
    FOREIGN KEY (student_id) REFERENCES student(id),
    FOREIGN KEY (submit_by) REFERENCES parent(id)
);	

--vacination_record
CREATE TABLE vaccination_record (
    id SERIAL PRIMARY KEY,
    student_id varchar(10) NOT NULL,
    register_id INT, -- NULL nếu không đăng ký qua campaign
    -- campaign_id INT, -- NULL nếu không thuộc campaign khỏi lưu cái này cx đc
	  disease_id INT[] NOT NULL,
    vaccine_id INT, -- khác NULL nếu parent đăng ký tiêm ở chỗ khác mà không thông qua campaign nhà trường
    description TEXT,
    location VARCHAR(255),
    vaccination_date DATE,
    status VARCHAR(50) NOT NULL CHECK (status IN ('PENDING', 'COMPLETED', 'MISSED',  'CANCELLED')),
    pending VARCHAR(50) CHECK (pending IN ('PENDING', 'DONE', 'CANCELLED', NULL)),
    reason_by_nurse TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES student(id),
    FOREIGN KEY (register_id) REFERENCES vaccination_campaign_register(id),
    FOREIGN KEY (vaccine_id) REFERENCES vaccine(id),
    CONSTRAINT unique_student_vaccine_date UNIQUE (student_id, vaccine_id, register_id)
);


INSERT INTO vaccination_record (
  student_id,
  register_id,
  disease_id,
  vaccine_id,
  vaccination_date,
  description,
  location,
  status
)
VALUES
  (
    '211000',
    NULL,
    ARRAY[8],
    3,
    '2023-06-15',
    'Không có triệu chứng',
    'Trung tâm tiêm chủng VNVC (Tiêm ở ngoài trường)',
    'COMPLETED'
  ),
(
    '211002',
    NULL,
    ARRAY[8],
    5,
    '2025-06-20',
    'Không có triệu chứng',
    'Trung tâm tiêm chủng VNVC (Tiêm ở ngoài trường)',
    'COMPLETED'
  ),
  (
    '211001',
    NULL,
    ARRAY[8],
    4,
    '2025-06-22',
    'Không có triệu chứng',
    'Trung tâm tiêm chủng VNVC (Tiêm ở ngoài trường)',
    'COMPLETED'
  ),
  (
    '211003',
    NULL,
    ARRAY[9],
    7,
    '2025-06-25',
    'Không có triệu chứng',
    'Trung tâm tiêm chủng VNVC (Tiêm ở ngoài trường)',
    'COMPLETED'
  );


---SAMPLE DATA
-- Insert 3 vaccination campaigns in the past (already defined, kept as is)
INSERT INTO vaccination_campaign (disease_id, vaccine_id, title, description, location, start_date, end_date, status) VALUES
(
  ARRAY[12, 13, 14], -- Sởi, Quai bị, Rubella
  22, -- MMR II
  'Tiêm phòng bệnh Sởi, Quai bi, Rubella (MMR II) 2018',
  'THÔNG BÁO VỀ CHIẾN DỊCH TIÊM PHÒNG BỆNH SỞI (MMR II) 2018 
  Nhà trường phối hợp với Trung tâm Y tế tổ chức Chiến dịch tiêm phòng vắc xin MMR II để bảo vệ học sinh khỏi bệnh Sởi – một bệnh truyền nhiễm nguy hiểm gây sốt và phát ban. Chiến dịch nhằm tăng cường miễn dịch cho trẻ em trong độ tuổi tiểu học.
  
  Thông tin chi tiết:
  - Thời gian: Từ ngày 15/03/2018 đến ngày 17/03/2018 
  - Địa điểm: School Medix, Phòng Y tế Trường học 
  - Đối tượng: Học sinh lớp 1 và lớp 2 
  - Vắc xin: MMR II (sản xuất tại Mỹ, an toàn và hiệu quả) 
  
  Quý phụ huynh vui lòng đăng ký trước tại văn phòng nhà trường trước ngày 10/03/2018. 
  Trân trọng, 
  Ban Giám Hiệu',
  'School Medix',
  '2018-03-15',
  '2018-03-17',
  'COMPLETED'
),
(
  ARRAY[7], -- Viêm gan B
  12, -- Gene Hbvax 1ml
  'Tiêm phòng Viêm gan B (Gene Hbvax) 2020',
  'THÔNG BÁO VỀ CHIẾN DỊCH TIÊM PHÒNG VIÊM GAN B 2020 
  Nhà trường phối hợp với Trung tâm Y tế tổ chức Chiến dịch tiêm phòng vắc xin Gene Hbvax để bảo vệ học sinh khỏi bệnh Viêm gan B – một bệnh truyền nhiễm nguy hiểm ảnh hưởng đến gan. Chiến dịch tập trung vào học sinh chưa hoàn thành liều tiêm.
  
  Thông tin chi tiết:
  - Thời gian: Từ ngày 10/06/2020 đến ngày 12/06/2020 
  - Địa điểm: School Medix, Phòng Y tế Trường học 
  - Đối tượng: Học sinh lớp 1 và lớp 2 
  - Vắc xin: Gene Hbvax 1ml (sản xuất tại Việt Nam) 
  
  Quý phụ huynh vui lòng đăng ký trước tại văn phòng nhà trường trước ngày 05/06/2020. 
  Trân trọng, 
  Ban Giám Hiệu',
  'School Medix',
  '2020-06-10',
  '2020-06-12',
  'COMPLETED'
),
(
  ARRAY[15], -- Thủy đậu
  24, -- Varivax
  'Tiêm phòng Thủy đậu (Varivax) 2022',
  'THÔNG BÁO VỀ CHIẾN DỊCH TIÊM PHÒNG THỦY ĐẬU 2022 
  Nhà trường phối hợp với Trung tâm Y tế tổ chức Chiến dịch tiêm phòng vắc xin Varivax để bảo vệ học sinh khỏi bệnh Thủy đậu – một bệnh truyền nhiễm gây phát ban và ngứa. Chiến dịch nhằm tăng cường miễn dịch cho trẻ em.
  
  Thông tin chi tiết:
  - Thời gian: Từ ngày 20/09/2022 đến ngày 22/09/2022 
  - Địa điểm: School Medix, Phòng Y tế Trường học 
  - Đối tượng: Học sinh lớp 1 và lớp 2 
  - Vắc xin: Varivax (sản xuất tại Mỹ) 
  
  Quý phụ huynh vui lòng đăng ký trước tại văn phòng nhà trường trước ngày 15/09/2022. 
  Trân trọng, 
  Ban Giám Hiệu',
  'School Medix',
  '2022-09-20',
  '2022-09-22',
  'COMPLETED'
);

INSERT INTO vaccination_campaign (disease_id, vaccine_id, title, description, location, start_date, end_date, status) VALUES
(
  ARRAY[10],
  11, 
  'Tiêm phòng bệnh lao (BCG), tiêm sớm sau sinh', 
  'THÔNG BÁO VỀ CHIẾN DỊCH TIÊM PHÒNG BỆNH LAO (BCG) 
	Nhà trường phối hợp với Trung tâm Y tế tổ chức Chiến dịch tiêm phòng vắc xin BCG nhằm bảo vệ trẻ sơ sinh và trẻ nhỏ khỏi bệnh lao – một bệnh truyền nhiễm nguy hiểm do vi khuẩn Mycobacterium tuberculosis gây ra. Vắc xin BCG được khuyến cáo tiêm sớm sau sinh để tăng cường khả năng miễn dịch cho trẻ.
	
	Thông tin chi tiết:
	- Thời gian: Từ ngày 15/06/2025 đến ngày 17/06/2025 
	- Địa điểm: School Medix, Phòng Y tế Trường học 
	- Đối tượng: Trẻ sơ sinh và trẻ dưới 1 tháng tuổi (ưu tiên tiêm sớm sau sinh) 
	- Vắc xin: BCG (sản xuất tại Việt Nam, an toàn và hiệu quả) 
	
	Chiến dịch được thực hiện bởi đội ngũ y tế chuyên nghiệp, đảm bảo an toàn và tuân thủ các quy định y tế. Quý phụ huynh vui lòng đăng ký trước tại văn phòng nhà trường hoặc qua email health@schoolmedix.edu.vn trước ngày 10/06/2025 để sắp xếp lịch tiêm. 
	
	Để biết thêm chi tiết, vui lòng liên hệ Phòng Y tế qua số điện thoại: (+84) 123 456 789. 
	
	Trân trọng, 
	Ban Giám Hiệu',
  'School Medix', 
  '2025-10-15', 
  '2025-10-17',  
  'DRAFTED'
);

-- Insert vaccination campaign registrations for all students
INSERT INTO vaccination_campaign_register (student_id, campaign_id, reason, is_registered, submit_time, submit_by) VALUES
-- Campaign 1: Sởi 2018
('211000', 1, 'Đăng ký tiêm phòng Sởi cho con', TRUE, '2018-03-01 09:00:00', 100003),
('211001', 1, 'Đăng ký tiêm phòng Sởi để bảo vệ sức khỏe', TRUE, '2018-03-01 09:05:00', 100003),
('211002', 1, 'Đăng ký theo khuyến nghị y tế', TRUE, '2018-03-01 09:10:00', 100000),
('211003', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 09:15:00', 100001),
('211004', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 09:20:00', 100005),
('211005', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 09:25:00', 100007),
('211006', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 09:30:00', 100009),
('211007', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 09:35:00', 100011),
('211008', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 09:40:00', 100013),
('211009', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 09:45:00', 100015),
('211010', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 09:50:00', 100017),
('211011', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 09:55:00', 100019),
('211012', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 10:00:00', 100021),
('211013', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 10:05:00', 100023),
('211014', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 10:10:00', 100025),
('211015', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 10:15:00', 100027),
('211016', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 10:20:00', 100029),
('211017', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 10:25:00', 100031),
('211018', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 10:30:00', 100033),
('211019', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 10:35:00', 100005),
('211020', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 10:40:00', 100007),
('211021', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 10:45:00', 100009),
('211022', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 10:50:00', 100011),
('211023', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 10:55:00', 100013),
('211024', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 11:00:00', 100015),
('211025', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 11:05:00', 100017),
('211026', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 11:10:00', 100019),
('211027', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 11:15:00', 100021),
('211028', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 11:20:00', 100023),
('211029', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 11:25:00', 100025),
('211030', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 11:30:00', 100027),
('211031', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 11:35:00', 100029),
('211032', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 11:40:00', 100031),
('211033', 1, 'Đăng ký tiêm phòng Sởi', TRUE, '2018-03-01 11:45:00', 100033),
-- Campaign 2: Viêm gan B 2020
('211000', 2, 'Đăng ký tiêm liều bổ sung Viêm gan B', TRUE, '2020-06-01 09:00:00', 100003),
('211001', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 09:05:00', 100003),
('211002', 2, 'Đăng ký theo lịch tiêm chủng', TRUE, '2020-06-01 09:10:00', 100000),
('211003', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 09:15:00', 100001),
('211004', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 09:20:00', 100005),
('211005', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 09:25:00', 100007),
('211006', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 09:30:00', 100009),
('211007', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 09:35:00', 100011),
('211008', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 09:40:00', 100013),
('211009', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 09:45:00', 100015),
('211010', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 09:50:00', 100017),
('211011', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 09:55:00', 100019),
('211012', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 10:00:00', 100021),
('211013', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 10:05:00', 100023),
('211014', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 10:10:00', 100025),
('211015', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 10:15:00', 100027),
('211016', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 10:20:00', 100029),
('211017', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 10:25:00', 100031),
('211018', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 10:30:00', 100033),
('211019', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 10:35:00', 100005),
('211020', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 10:40:00', 100007),
('211021', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 10:45:00', 100009),
('211022', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 10:50:00', 100011),
('211023', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 10:55:00', 100013),
('211024', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 11:00:00', 100015),
('211025', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 11:05:00', 100017),
('211026', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 11:10:00', 100019),
('211027', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 11:15:00', 100021),
('211028', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 11:20:00', 100023),
('211029', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 11:25:00', 100025),
('211030', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 11:30:00', 100027),
('211031', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 11:35:00', 100029),
('211032', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 11:40:00', 100031),
('211033', 2, 'Đăng ký tiêm phòng Viêm gan B', TRUE, '2020-06-01 11:45:00', 100033),
-- Campaign 3: Thủy đậu 2022
('211000', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 09:00:00', 100003),
('211001', 3, 'Đăng ký để bảo vệ con khỏi Thủy đậu', TRUE, '2022-09-01 09:05:00', 100003),
('211002', 3, 'Đăng ký theo khuyến nghị trường', TRUE, '2022-09-01 09:10:00', 100000),
('211003', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 09:15:00', 100001),
('211004', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 09:20:00', 100005),
('211005', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 09:25:00', 100007),
('211006', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 09:30:00', 100009),
('211007', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 09:35:00', 100011),
('211008', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 09:40:00', 100013),
('211009', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 09:45:00', 100015),
('211010', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 09:50:00', 100017),
('211011', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 09:55:00', 100019),
('211012', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 10:00:00', 100021),
('211013', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 10:05:00', 100023),
('211014', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 10:10:00', 100025),
('211015', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 10:15:00', 100027),
('211016', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 10:20:00', 100029),
('211017', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 10:25:00', 100031),
('211018', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 10:30:00', 100033),
('211019', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 10:35:00', 100005),
('211020', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 10:40:00', 100007),
('211021', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 10:45:00', 100009),
('211022', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 10:50:00', 100011),
('211023', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 10:55:00', 100013),
('211024', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 11:00:00', 100015),
('211025', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 11:05:00', 100017),
('211026', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 11:10:00', 100019),
('211027', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 11:15:00', 100021),
('211028', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 11:20:00', 100023),
('211029', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 11:25:00', 100025),
('211030', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 11:30:00', 100027),
('211031', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 11:35:00', 100029),
('211032', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 11:40:00', 100031),
('211033', 3, 'Đăng ký tiêm phòng Thủy đậu', TRUE, '2022-09-01 11:45:00', 100033);

-- Insert vaccination records for all students
INSERT INTO vaccination_record (student_id, register_id, disease_id, vaccine_id, description, location, vaccination_date, status) VALUES
-- Campaign 1: Sởi 2018
('211000', 1, ARRAY[12], 22, 'Không có phản ứng sau tiêm', 'School Medix', '2018-03-15', 'COMPLETED'),
('211001', 2, ARRAY[12], 22, 'Sốt nhẹ 24h, đã được theo dõi', 'School Medix', '2018-03-15', 'COMPLETED'),
('211002', 3, ARRAY[12], 22, 'Phát ban nhẹ, đã hồi phục sau 2 ngày', 'School Medix', '2018-03-16', 'COMPLETED'),
('211003', 4, ARRAY[12], 22, 'Không có triệu chứng bất thường', 'School Medix', '2018-03-16', 'COMPLETED'),
('211004', 5, ARRAY[12], 22, 'Sốt nhẹ 12h, đã dùng paracetamol', 'School Medix', '2018-03-16', 'COMPLETED'),
('211005', 6, ARRAY[12], 22, 'Không có phản ứng sau tiêm', 'School Medix', '2018-03-17', 'COMPLETED'),
('211006', 7, ARRAY[12], 22, 'Mệt mỏi nhẹ 1 ngày', 'School Medix', '2018-03-17', 'COMPLETED'),
('211007', 8, ARRAY[12], 22, 'Sưng nhẹ tại vị trí tiêm', 'School Medix', '2018-03-15', 'COMPLETED'),
('211008', 9, ARRAY[12], 22, 'Không có phản ứng', 'School Medix', '2018-03-15', 'COMPLETED'),
('211009', 10, ARRAY[12], 22, 'Phát ban nhẹ, đã ổn định', 'School Medix', '2018-03-16', 'COMPLETED'),
('211010', 11, ARRAY[12], 22, 'Không có triệu chứng', 'School Medix', '2018-03-16', 'COMPLETED'),
('211011', 12, ARRAY[12], 22, 'Sốt nhẹ 24h', 'School Medix', '2018-03-17', 'COMPLETED'),
('211012', 13, ARRAY[12], 22, 'Không có phản ứng', 'School Medix', '2018-03-17', 'COMPLETED'),
('211013', 14, ARRAY[12], 22, 'Mệt mỏi nhẹ', 'School Medix', '2018-03-15', 'COMPLETED'),
('211014', 15, ARRAY[12], 22, 'Không có triệu chứng', 'School Medix', '2018-03-15', 'COMPLETED'),
('211015', 16, ARRAY[12], 22, 'Sốt nhẹ 12h', 'School Medix', '2018-03-16', 'COMPLETED'),
('211016', 17, ARRAY[12], 22, 'Không có phản ứng', 'School Medix', '2018-03-16', 'COMPLETED'),
('211017', 18, ARRAY[12], 22, 'Phát ban nhẹ', 'School Medix', '2018-03-17', 'COMPLETED'),
('211018', 19, ARRAY[12], 22, 'Không có triệu chứng', 'School Medix', '2018-03-17', 'COMPLETED'),
('211019', 20, ARRAY[12], 22, 'Sưng nhẹ tại vị trí tiêm', 'School Medix', '2018-03-15', 'COMPLETED'),
('211020', 21, ARRAY[12], 22, 'Không có phản ứng', 'School Medix', '2018-03-15', 'COMPLETED'),
('211021', 22, ARRAY[12], 22, 'Mệt mỏi nhẹ 1 ngày', 'School Medix', '2018-03-16', 'COMPLETED'),
('211022', 23, ARRAY[12], 22, 'Không có triệu chứng', 'School Medix', '2018-03-16', 'COMPLETED'),
('211023', 24, ARRAY[12], 22, 'Sốt nhẹ 24h', 'School Medix', '2018-03-17', 'COMPLETED'),
('211024', 25, ARRAY[12], 22, 'Không có phản ứng', 'School Medix', '2018-03-17', 'COMPLETED'),
('211025', 26, ARRAY[12], 22, 'Phát ban nhẹ', 'School Medix', '2018-03-15', 'COMPLETED'),
('211026', 27, ARRAY[12], 22, 'Không có triệu chứng', 'School Medix', '2018-03-15', 'COMPLETED'),
('211027', 28, ARRAY[12], 22, 'Sốt nhẹ 12h', 'School Medix', '2018-03-16', 'COMPLETED'),
('211028', 29, ARRAY[12], 22, 'Không có phản ứng', 'School Medix', '2018-03-16', 'COMPLETED'),
('211029', 30, ARRAY[12], 22, 'Mệt mỏi nhẹ', 'School Medix', '2018-03-17', 'COMPLETED'),
('211030', 31, ARRAY[12], 22, 'Không có triệu chứng', 'School Medix', '2018-03-17', 'COMPLETED'),
('211031', 32, ARRAY[12], 22, 'Sưng nhẹ tại vị trí tiêm', 'School Medix', '2018-03-15', 'COMPLETED'),
('211032', 33, ARRAY[12], 22, 'Không có phản ứng', 'School Medix', '2018-03-15', 'COMPLETED'),
('211033', 34, ARRAY[12], 22, 'Phát ban nhẹ', 'School Medix', '2018-03-16', 'COMPLETED'),
-- Campaign 2: Viêm gan B 2020
('211000', 35, ARRAY[7], 12, 'Không có phản ứng sau tiêm', 'School Medix', '2020-06-10', 'COMPLETED'),
('211001', 36, ARRAY[7], 12, 'Sốt nhẹ 24h, đã được theo dõi', 'School Medix', '2020-06-10', 'COMPLETED'),
('211002', 37, ARRAY[7], 12, 'Sưng nhẹ tại vị trí tiêm', 'School Medix', '2020-06-11', 'COMPLETED'),
('211003', 38, ARRAY[7], 12, 'Không có triệu chứng bất thường', 'School Medix', '2020-06-11', 'COMPLETED'),
('211004', 39, ARRAY[7], 12, 'Mệt mỏi nhẹ 1 ngày', 'School Medix', '2020-06-11', 'COMPLETED'),
('211005', 40, ARRAY[7], 12, 'Không có phản ứng', 'School Medix', '2020-06-12', 'COMPLETED'),
('211006', 41, ARRAY[7], 12, 'Sốt nhẹ 12h', 'School Medix', '2020-06-12', 'COMPLETED'),
('211007', 42, ARRAY[7], 12, 'Không có triệu chứng', 'School Medix', '2020-06-10', 'COMPLETED'),
('211008', 43, ARRAY[7], 12, 'Phát ban nhẹ, đã ổn định', 'School Medix', '2020-06-10', 'COMPLETED'),
('211009', 44, ARRAY[7], 12, 'Không có phản ứng', 'School Medix', '2020-06-11', 'COMPLETED'),
('211010', 45, ARRAY[7], 12, 'Sốt nhẹ 24h', 'School Medix', '2020-06-11', 'COMPLETED'),
('211011', 46, ARRAY[7], 12, 'Không có triệu chứng', 'School Medix', '2020-06-12', 'COMPLETED'),
('211012', 47, ARRAY[7], 12, 'Mệt mỏi nhẹ', 'School Medix', '2020-06-12', 'COMPLETED'),
('211013', 48, ARRAY[7], 12, 'Không có phản ứng', 'School Medix', '2020-06-10', 'COMPLETED'),
('211014', 49, ARRAY[7], 12, 'Sưng nhẹ tại vị trí tiêm', 'School Medix', '2020-06-10', 'COMPLETED'),
('211015', 50, ARRAY[7], 12, 'Không có triệu chứng', 'School Medix', '2020-06-11', 'COMPLETED'),
('211016', 51, ARRAY[7], 12, 'Sốt nhẹ 12h', 'School Medix', '2020-06-11', 'COMPLETED'),
('211017', 52, ARRAY[7], 12, 'Không có phản ứng', 'School Medix', '2020-06-12', 'COMPLETED'),
('211018', 53, ARRAY[7], 12, 'Phát ban nhẹ', 'School Medix', '2020-06-12', 'COMPLETED'),
('211019', 54, ARRAY[7], 12, 'Không có triệu chứng', 'School Medix', '2020-06-10', 'COMPLETED'),
('211020', 55, ARRAY[7], 12, 'Sốt nhẹ 24h', 'School Medix', '2020-06-10', 'COMPLETED'),
('211021', 56, ARRAY[7], 12, 'Không có phản ứng', 'School Medix', '2020-06-11', 'COMPLETED'),
('211022', 57, ARRAY[7], 12, 'Mệt mỏi nhẹ 1 ngày', 'School Medix', '2020-06-11', 'COMPLETED'),
('211023', 58, ARRAY[7], 12, 'Không có triệu chứng', 'School Medix', '2020-06-12', 'COMPLETED'),
('211024', 59, ARRAY[7], 12, 'Sưng nhẹ tại vị trí tiêm', 'School Medix', '2020-06-12', 'COMPLETED'),
('211025', 60, ARRAY[7], 12, 'Không có phản ứng', 'School Medix', '2020-06-10', 'COMPLETED'),
('211026', 61, ARRAY[7], 12, 'Sốt nhẹ 12h', 'School Medix', '2020-06-10', 'COMPLETED'),
('211027', 62, ARRAY[7], 12, 'Không có triệu chứng', 'School Medix', '2020-06-11', 'COMPLETED'),
('211028', 63, ARRAY[7], 12, 'Phát ban nhẹ', 'School Medix', '2020-06-11', 'COMPLETED'),
('211029', 64, ARRAY[7], 12, 'Không có phản ứng', 'School Medix', '2020-06-12', 'COMPLETED'),
('211030', 65, ARRAY[7], 12, 'Mệt mỏi nhẹ', 'School Medix', '2020-06-12', 'COMPLETED'),
('211031', 66, ARRAY[7], 12, 'Không có triệu chứng', 'School Medix', '2020-06-10', 'COMPLETED'),
('211032', 67, ARRAY[7], 12, 'Sốt nhẹ 24h', 'School Medix', '2020-06-10', 'COMPLETED'),
('211033', 68, ARRAY[7], 12, 'Không có phản ứng', 'School Medix', '2020-06-11', 'COMPLETED'),
-- Campaign 3: Thủy đậu 2022
('211000', 69, ARRAY[15], 24, 'Không có phản ứng sau tiêm', 'School Medix', '2022-09-20', 'COMPLETED'),
('211001', 70, ARRAY[15], 24, 'Sốt nhẹ 12h, đã dùng paracetamol', 'School Medix', '2022-09-20', 'COMPLETED'),
('211002', 71, ARRAY[15], 24, 'Phát ban nhẹ, đã hồi phục', 'School Medix', '2022-09-21', 'COMPLETED'),
('211003', 72, ARRAY[15], 24, 'Không có triệu chứng', 'School Medix', '2022-09-21', 'COMPLETED'),
('211004', 73, ARRAY[15], 24, 'Sưng nhẹ tại vị trí tiêm', 'School Medix', '2022-09-21', 'COMPLETED'),
('211005', 74, ARRAY[15], 24, 'Không có phản ứng', 'School Medix', '2022-09-22', 'COMPLETED'),
('211006', 75, ARRAY[15], 24, 'Mệt mỏi nhẹ 1 ngày', 'School Medix', '2022-09-22', 'COMPLETED'),
('211007', 76, ARRAY[15], 24, 'Sốt nhẹ 24h', 'School Medix', '2022-09-20', 'COMPLETED'),
('211008', 77, ARRAY[15], 24, 'Không có triệu chứng', 'School Medix', '2022-09-20', 'COMPLETED'),
('211009', 78, ARRAY[15], 24, 'Phát ban nhẹ', 'School Medix', '2022-09-21', 'COMPLETED'),
('211010', 79, ARRAY[15], 24, 'Không có phản ứng', 'School Medix', '2022-09-21', 'COMPLETED'),
('211011', 80, ARRAY[15], 24, 'Sốt nhẹ 12h', 'School Medix', '2022-09-22', 'COMPLETED'),
('211012', 81, ARRAY[15], 24, 'Không có triệu chứng', 'School Medix', '2022-09-22', 'COMPLETED'),
('211013', 82, ARRAY[15], 24, 'Mệt mỏi nhẹ', 'School Medix', '2022-09-20', 'COMPLETED'),
('211014', 83, ARRAY[15], 24, 'Không có phản ứng', 'School Medix', '2022-09-20', 'COMPLETED'),
('211015', 84, ARRAY[15], 24, 'Sưng nhẹ tại vị trí tiêm', 'School Medix', '2022-09-21', 'COMPLETED'),
('211016', 85, ARRAY[15], 24, 'Không có triệu chứng', 'School Medix', '2022-09-21', 'COMPLETED'),
('211017', 86, ARRAY[15], 24, 'Sốt nhẹ 24h', 'School Medix', '2022-09-22', 'COMPLETED'),
('211018', 87, ARRAY[15], 24, 'Không có phản ứng', 'School Medix', '2022-09-22', 'COMPLETED'),
('211019', 88, ARRAY[15], 24, 'Phát ban nhẹ', 'School Medix', '2022-09-20', 'COMPLETED'),
('211020', 89, ARRAY[15], 24, 'Không có triệu chứng', 'School Medix', '2022-09-20', 'COMPLETED'),
('211021', 90, ARRAY[15], 24, 'Mệt mỏi nhẹ 1 ngày', 'School Medix', '2022-09-21', 'COMPLETED'),
('211022', 91, ARRAY[15], 24, 'Không có phản ứng', 'School Medix', '2022-09-21', 'COMPLETED'),
('211023', 92, ARRAY[15], 24, 'Sốt nhẹ 12h', 'School Medix', '2022-09-22', 'COMPLETED'),
('211024', 93, ARRAY[15], 24, 'Không có triệu chứng', 'School Medix', '2022-09-22', 'COMPLETED'),
('211025', 94, ARRAY[15], 24, 'Sưng nhẹ tại vị trí tiêm', 'School Medix', '2022-09-20', 'COMPLETED'),
('211026', 95, ARRAY[15], 24, 'Không có phản ứng', 'School Medix', '2022-09-20', 'COMPLETED'),
('211027', 96, ARRAY[15], 24, 'Phát ban nhẹ', 'School Medix', '2022-09-21', 'COMPLETED'),
('211028', 97, ARRAY[15], 24, 'Không có triệu chứng', 'School Medix', '2022-09-21', 'COMPLETED'),
('211029', 98, ARRAY[15], 24, 'Sốt nhẹ 24h', 'School Medix', '2022-09-22', 'COMPLETED'),
('211030', 99, ARRAY[15], 24, 'Không có phản ứng', 'School Medix', '2022-09-22', 'COMPLETED'),
('211031', 100, ARRAY[15], 24, 'Mệt mỏi nhẹ', 'School Medix', '2022-09-20', 'COMPLETED'),
('211032', 101, ARRAY[15], 24, 'Không có triệu chứng', 'School Medix', '2022-09-20', 'COMPLETED'),
('211033', 102, ARRAY[15], 24, 'Sưng nhẹ tại vị trí tiêm', 'School Medix', '2022-09-21', 'COMPLETED');

---------------------------------------------------------------------------------------------------------------------------------------END FLOW VACCINATION



-----------------------------------------------------------------------------------------FLOW Quản lý thuốc, vật tư
CREATE TABLE MedicalItem (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    unit VARCHAR(100) NOT NULL,
    description TEXT,
    exp_date DATE NOT NULL,
    category VARCHAR(50) CHECK (category IN ('MEDICAL_SUPPLY', 'MEDICATION')),
    is_deleted BOOLEAN default false
);

INSERT INTO MedicalItem (name, unit, description, exp_date, category)
VALUES
-- Giảm đau - hạ sốt
('Paracetamol 500mg', 'viên', 'Giảm đau, hạ sốt', '2026-12-31', 'MEDICATION'),
('Ibuprofen 200mg', 'viên',  'Giảm đau, kháng viêm', '2026-10-01', 'MEDICATION'),
('Efferalgan 500mg', 'viên sủi', 'Paracetamol dạng sủi, dễ uống', '2025-11-30', 'MEDICATION'),

-- Kháng sinh
('Amoxicillin 500mg', 'viên',  'Kháng sinh phổ rộng nhóm penicillin', '2025-09-15', 'MEDICATION'),
('Azithromycin 250mg', 'viên', 'Kháng sinh nhóm macrolide', '2025-08-20', 'MEDICATION'),

-- Dị ứng - cảm cúm
('Loratadine 10mg', 'viên', 'Giảm dị ứng, mề đay', '2026-01-01', 'MEDICATION'),
('Cetirizine 10mg', 'viên', 'Chống dị ứng', '2026-03-15', 'MEDICATION'),

-- Tiêu hóa - đau dạ dày
('Omeprazole 20mg', 'viên', 'Giảm tiết axit dạ dày', '2027-05-05', 'MEDICATION'),
('Smecta', 'gói', 'Chống tiêu chảy, bảo vệ niêm mạc ruột', '2026-07-10', 'MEDICATION'),

-- Vitamin
('Vitamin C 500mg', 'viên', 'Tăng cường sức đề kháng', '2026-04-01', 'MEDICATION'),
('Centrum Adults', 'viên', 'Vitamin tổng hợp', '2027-01-01', 'MEDICATION'),

-- Kem chống ngứa
('Kem chống ngứa', 'tuýp', 'Bôi ngoài da, giảm mẩn đỏ', '2026-12-31', 'MEDICATION'),

-- Men tiêu hóa
('Men tiêu hóa gói', 'gói', 'Hỗ trợ tiêu hóa', '2026-11-30', 'MEDICATION');

INSERT INTO MedicalItem (name, unit, description, exp_date, category)
VALUES
-- Vật tư y tế thông dụng
('Khẩu trang y tế 3 lớp', 'hộp (50 cái)',  'Dùng trong phòng chống dịch, y tế thường ngày', '2026-12-31', 'MEDICAL_SUPPLY'),
('Găng tay y tế không bột', 'hộp (100 cái)', 'Găng tay cao su sử dụng 1 lần', '2026-09-30', 'MEDICAL_SUPPLY'),
('Bông y tế tiệt trùng', 'bịch (100g)',  'Dùng để cầm máu, vệ sinh vết thương', '2027-03-01', 'MEDICAL_SUPPLY'),
('Băng keo cá nhân', 'hộp (100 miếng)',  'Dán vết thương nhỏ', '2026-05-15', 'MEDICAL_SUPPLY'),
('Cồn 70 độ', 'chai (500ml)',  'Sát khuẩn vết thương, khử trùng', '2026-11-01', 'MEDICAL_SUPPLY'),
('Dung dịch sát khuẩn tay nhanh', 'chai (500ml)', 'Dùng khử khuẩn tay, nhanh khô', '2026-08-01', 'MEDICAL_SUPPLY'),
('Nhiệt kế điện tử', 'cái', 'Đo thân nhiệt chính xác', '2028-01-01', 'MEDICAL_SUPPLY'),
('Ống tiêm 5ml', 'hộp (100 cái)', 'Dùng để tiêm thuốc/liều lượng nhỏ', '2027-06-30', 'MEDICAL_SUPPLY');

CREATE TABLE TransactionPurpose(
  id serial primary key,
  title varchar(200),
  multiply_for INT CHECK (multiply_for IN (1, -1))
);

insert into TransactionPurpose (title, multiply_for) VALUES 
('Sử dụng cho nhân viên, học sinh', -1),
('Nhập hàng từ NCC', 1),
('Mua hàng bên ngoài', 1),
('Thuốc vật tư chất lượng không đảm bảo', -1), 
('Thuốc vật tư hết hạn sử dụng', -1), 
('Hoàn trả hàng', -1),
('Phụ huynh dặn thuốc', 1);


--- SUPPLIER
CREATE TABLE Supplier (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    address TEXT,
    email VARCHAR(100),
    phone VARCHAR(20),
    contact_person VARCHAR(100),
    tax_code VARCHAR(50),
    status VARCHAR(50) CHECK (status IN ('ACTIVE', 'INACTIVE', 'UNKNOWN')) DEFAULT 'ACTIVE',
    is_deleted BOOLEAN default false
);

INSERT INTO Supplier (
    name, description, address, email, phone, contact_person, tax_code, status
)
VALUES 
-- 1
('Công ty Dược Việt Nam', 'Chuyên cung cấp thuốc và vật tư y tế nội địa', 
 '123 Đường Lê Lợi, Quận 1, TP.HCM', 'duocvn@example.com', '0909123456', 'Nguyễn Văn A', '0301123234567', 'ACTIVE'),

-- 2
('MediSupply Co., Ltd.', 'Nhà cung cấp thiết bị y tế nhập khẩu', 
 '456 Nguyễn Văn Cừ, Quận 5, TP.HCM', 'contact@medisupply.vn', '02838445566', 'Trần Thị B', '0312345424678', 'ACTIVE'),

-- 3
('Thiết Bị Y Tế An Tâm', 'Phân phối thiết bị phòng khám và bệnh viện', 
 '789 Trường Chinh, Tân Bình, TP.HCM', 'info@antam.com', '0911223344', 'Lê Văn C', '0323456725789', 'ACTIVE'),

-- 4
('VietHealth Group', 'Tập đoàn cung ứng thuốc và hóa chất y tế toàn quốc', 
 '88 Hoàng Quốc Việt, Cầu Giấy, Hà Nội', 'support@viethealth.vn', '0988667788', 'Phạm Thị D', '0334265567890', 'ACTIVE'),

-- 5
('Y Dược Hồng Phát', 'Cung cấp thuốc theo đơn và không kê đơn', 
 '22 Hai Bà Trưng, Hoàn Kiếm, Hà Nội', 'hongphat@ydvn.com', '02439283928', 'Vũ Văn E', '03456631278901', 'ACTIVE'),

-- 6
('TBYT Miền Trung', 'Chuyên phân phối thiết bị y tế khu vực miền Trung', 
 '95 Hùng Vương, TP. Huế', 'contact@tbytmt.vn', '02343888999', 'Lê Thị F', '03513256789012', 'UNKNOWN'),

-- 7
('MedicalHub JSC', 'Đối tác cung ứng thuốc và thiết bị từ Nhật Bản và EU', 
 '15 Pasteur, Quận 3, TP.HCM', 'sales@medicalhub.vn', '0909001122', 'Trần Văn G', '03513256789012', 'ACTIVE'),

-- 8
('An Khang Pharma', 'Nhà phân phối độc quyền các dòng vitamin cao cấp', 
 '19 Lê Đại Hành, TP. Đà Nẵng', 'ankhang@pharma.vn', '02363667788', 'Ngô Thị H', '03513256789012', 'INACTIVE'),

-- 9
('Siêu Thị Thiết Bị Y Tế', 'Cung cấp thiết bị y tế gia đình và cá nhân', 
 '45 Võ Thị Sáu, TP. Biên Hòa', 'sieuthiyte@gmail.com', '0913666888', 'Phan Văn I', '03513256789012', 'ACTIVE'),

-- 10
('PharmaLink Việt Nam', 'Chuỗi cung ứng thuốc cho bệnh viện và phòng khám', 
 '200 Lý Thường Kiệt, Quận 10, TP.HCM', 'pharmalink@vn.com', '02838668888', 'Đỗ Thị K', '03513256789012', 'INACTIVE');


CREATE TABLE InventoryTransaction (
    id SERIAL PRIMARY KEY,
    purpose_id int,
    note TEXT,
    supplier_id INT default null,
    transaction_date DATE,
    FOREIGN KEY (supplier_id) REFERENCES Supplier(id),
    FOREIGN KEY (purpose_id) REFERENCES TransactionPurpose(id),
    is_deleted BOOLEAN default false
);

CREATE TABLE TransactionItems (
    transaction_id INT NOT NULL,
    medical_item_id INT NOT NULL,
    transaction_quantity INT NOT NULL,
    
    PRIMARY KEY (transaction_id, medical_item_id),
    FOREIGN KEY (transaction_id) REFERENCES InventoryTransaction(id),
    FOREIGN KEY (medical_item_id) REFERENCES MedicalItem(id)
);

insert into InventoryTransaction (purpose_id, note, transaction_date) VALUES
(1, 'Dùng cho học sinh bị chảy máu cam', '2025-07-05'),
(1, 'Hoc sinh bị đau mắt đỏ', '2025-07-01'),
(1, 'Hoc sinh ho, sổ mũi dịch nhầy', '2025-07-08'),
(1, 'hoc sinh đau răng', '2025-07-02'),
(1, 'học sinh té cầu thang', '2025-07-31'),
(1, 'học sinh sốt', '2025-07-07'),
(1, 'nổi mẩn đỏ', '2025-07-07'),
(1, 'học sinh tiêu chảy, khó tiêu', '2025-07-03');

insert into TransactionItems (transaction_id, medical_item_id, transaction_quantity) VALUES
(1, 15, -2),
(2, 7, -1),
(3, 1, -1),
(3, 13, -1),
(4, 17, -1),
(5, 16, -1),
(5, 18, -1),
(6, 1, -1),
(7, 12, -1),
(8, 13, -1);

----------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE daily_health_record (
    id SERIAL PRIMARY KEY,
    student_id VARCHAR(10) NOT NULL,
    detect_time DATE NOT NULL,
    record_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    diagnosis TEXT,
    on_site_treatment TEXT,
    transferred_to TEXT,
    items_usage TEXT,
    transaction_id INT,
    status VARCHAR(50) CHECK (status IN ('MILD', 'SERIOUS')),
    FOREIGN KEY (student_id) REFERENCES student(id),
    FOREIGN KEY (transaction_id) REFERENCES InventoryTransaction(id)
);

CREATE INDEX idx_daily_health_record_detect_time ON daily_health_record(detect_time);
CREATE INDEX idx_daily_health_record_status ON daily_health_record(status);

INSERT INTO daily_health_record (
    student_id, detect_time, diagnosis, on_site_treatment, transferred_to, items_usage, status, transaction_id
)
VALUES 
('211000', '2025-07-05', 'Chảy máu cam', 'Nằm nghỉ, nghiêng đầu về trước', NULL, 'Bông gòn', 'MILD', 1),
('211000', '2025-07-01', 'Đau mắt đỏ', 'Nhỏ mắt Natri Clorid 0.9%', NULL, 'Thuốc nhỏ mắt', 'MILD', 2),

('211001', '2025-07-08', 'Ho và sổ mũi', 'Uống thuốc ho thảo dược', NULL, 'Thuốc ho, giấy lau', 'MILD', 3),
('211001', '2025-07-02', 'Đau răng', 'Súc miệng nước muối, thông báo phụ huynh', NULL, 'Nước muối sinh lý', 'MILD', 4),

('211002', '2025-07-03', 'Ngã cầu thang nhẹ', 'Kiểm tra vết thương, theo dõi 15 phút', NULL, 'Băng dán, nước sát khuẩn', 'SERIOUS', 5),
('211002', '2025-07-31', 'Sốt 38.5°C', 'Đặt khăn lạnh, uống hạ sốt', NULL, 'Paracetamol 250mg', 'MILD', 6),

('211003', '2025-07-07', 'Nổi mẩn đỏ toàn thân', 'Thông báo phụ huynh, theo dõi phản ứng', 'Trạm Y tế Phường 3', 'Kem chống ngứa', 'SERIOUS', 7),
('211003', '2025-07-03', 'Khó tiêu', 'Uống men tiêu hóa', NULL, 'Men tiêu hóa gói', 'MILD', 8);



-----------------------------------------------------------------------------------------END FLOW DaiLyHealthRecord



-- Transaction 1: Nhập thuốc từ Công ty Dược Việt Nam (supplier_id = 1)
INSERT INTO InventoryTransaction (purpose_id, note, supplier_id, transaction_date)
VALUES 
(2, 'Nhập thuốc từ Công ty Dược Việt Nam', 1, '2025-07-01');  -- id = 1

-- Transaction 2: Nhập vật tư từ MediSupply (supplier_id = 2)
INSERT INTO InventoryTransaction (purpose_id, note, supplier_id, transaction_date)
VALUES 
(2, 'Nhập vật tư từ MediSupply', 2, '2025-07-02');     -- id = 2

-- Transaction 3: Tiêu hủy thuốc hết hạn
INSERT INTO InventoryTransaction (purpose_id, note, supplier_id, transaction_date)
VALUES 
(5, 'Thuốc quá hạn', NULL, '2025-07-05');       -- id = 3

-- Transaction 4: Hoàn hàng lỗi về MediSupply (supplier_id = 2)
INSERT INTO InventoryTransaction (purpose_id, note, supplier_id, transaction_date)
VALUES 
(6, 'Hoàn trả thuốc bị lỗi đóng gói', 2, '2025-07-10');   -- id = 4

-- Transaction 1: Nhập thuốc (IMPORT)
INSERT INTO TransactionItems (transaction_id, medical_item_id, transaction_quantity)
VALUES
(9, 1, 100),   -- Paracetamol 500mg
(9, 2, 50),
(9, 3, 50),
(9, 4, 50),
(9, 5, 50),
(9, 6, 50),
(9, 7, 50),
(9, 8, 50),
(9, 9, 50),
(9, 10, 50),
(9, 11, 200);  -- Vitamin C 500mg

-- Transaction 2: Nhập vật tư (IMPORT)
INSERT INTO TransactionItems (transaction_id, medical_item_id, transaction_quantity)
VALUES
(10, 12, 50),
(10, 13, 50),
(10, 14, 50),
(10, 15, 50),
(10, 16, 50),
(10, 17, 50),
(10, 18, 50),
(10, 19, 50),   -- Khẩu trang y tế
(10, 20, 30);   -- Găng tay y tế

-- Transaction 3: Tiêu hủy thuốc (DISPOSE)
INSERT INTO TransactionItems (transaction_id, medical_item_id, transaction_quantity)
VALUES
(11, 5, -20);   -- Azithromycin 250mg

-- Transaction 4: Hoàn hàng (REFUND)
INSERT INTO TransactionItems (transaction_id, medical_item_id, transaction_quantity)
VALUES
(12, 7, -10);   -- Cetirizine 10mg

-----------------------------------------------------------------------------------------FLOW GIÁM SÁT BỆNH MÃN TÍNH VÀ BỆNH TRUYỀN NHIỄM
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE disease_record (
    id SERIAL PRIMARY KEY,
    student_id VARCHAR(10) NOT NULL,
    disease_id INT NOT NULL,
    diagnosis TEXT,
    detect_date DATE,
    cure_date DATE,
    location_cure TEXT,
    transferred_to TEXT,
    status VARCHAR(50) CHECK (status IN ('RECOVERED', 'UNDER_TREATMENT')),
    pending VARCHAR(50) CHECK (pending IN ('PENDING', 'DONE', 'CANCELLED')),
    reason_by_nurse TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (student_id) REFERENCES student(id),
    FOREIGN KEY (disease_id) REFERENCES disease(id)
);

INSERT INTO disease_record (
    student_id, disease_id, diagnosis, detect_date, cure_date, location_cure, transferred_to, status
) 
VALUES
('211000', 1, 'Phát ban và sốt nhẹ', '2025-05-01', '2025-05-05', 'Trạm Y tế Quận 1', NULL, 'RECOVERED'),
('211001', 2, 'Ho và nổi mẩn nhẹ', '2025-04-10', NULL, 'Tự theo dõi tại nhà', NULL, 'UNDER_TREATMENT'),
('211002', 1, 'Sốt, viêm họng', '2025-03-15', '2025-03-20', 'Phòng khám Nhi', NULL, 'RECOVERED'),
('211003', 2, 'Cảm lạnh nhẹ', '2025-02-01', NULL, 'Nhà theo dõi', NULL, 'UNDER_TREATMENT'),
('211000', 3, 'Mụn nước toàn thân, ngứa', '2025-06-01', '2025-06-06', 'Bệnh viện Nhi Đồng 1', NULL, 'RECOVERED'),
('211001', 4, 'Phát ban tay chân, lở miệng', '2025-05-10', NULL, 'Nhà theo dõi', NULL, 'UNDER_TREATMENT'),
('211002', 5, 'Mệt mỏi, vàng da nhẹ', '2025-04-20', NULL, 'Trạm y tế phường 5', NULL, 'UNDER_TREATMENT'),
('211003', 6, 'Khó thở, đau họng nặng', '2025-03-25', '2025-04-01', 'Phòng khám chuyên khoa', NULL, 'RECOVERED'),
('211000', 7, 'Thở khò khè, cần dùng ống hít', '2025-01-12', NULL, 'Nhà theo dõi', NULL, 'UNDER_TREATMENT'),
('211001', 8, 'Cân nặng vượt chuẩn, bác sĩ tư vấn giảm cân', '2025-01-05', NULL, 'Bệnh viện dinh dưỡng', NULL, 'UNDER_TREATMENT');
    
-------------------------------------------------------------------------------------------------------------------------------------- OTP
CREATE TABLE otps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  target text, -- email, sdt,...
  otp TEXT,
  purpose TEXT,   
  is_used BOOLEAN DEFAULT FALSE,
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_otp_lookup ON otps (target, purpose, is_used);

-------------------------------------------------------------------------------------------------------------------------------------- Blog


CREATE TABLE BLOG_TYPE (
	ID SERIAL PRIMARY KEY,
	NAME TEXT,
	DESCRIPTION TEXT
);

INSERT INTO
	BLOG_TYPE (NAME, DESCRIPTION)
VALUES	
	(
		'Dinh Dưỡng',
		'Kiến thức về chế độ ăn, dinh dưỡng cho học sinh'
	),
	(
		'Hướng dẫn',
		'Các phương pháp, hoạt động giữ gìn và nâng cao sức khỏe cho học sinh'
	),
	(
		'Chia sẻ',
		'Chia sẻ, tư vấn về tâm lý lứa tuổi học sinh, cách vượt qua áp lực học tập'
	),
	(
		'Kiến thức',
		'Thông tin về phòng ngừa các bệnh thường gặp ở trường học'
);
	

-- 2. Bảng blog (có thumbnail_url)
CREATE TYPE BLOG_STATUS AS ENUM('DRAFTED', 'PUBLISHED');

CREATE TABLE BLOG (
	ID SERIAL PRIMARY KEY,
	TITLE VARCHAR(255) NOT NULL,
	CONTENT TEXT NOT NULL,
	THUMBNAIL_URL VARCHAR(255), -- ảnh đại diện
	CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	UPDATED_AT TIMESTAMP DEFAULT NULL,
	IS_DELETED BOOLEAN DEFAULT FALSE,
	STATUS BLOG_STATUS DEFAULT 'DRAFTED',
	BLOG_TYPE_ID INTEGER REFERENCES BLOG_TYPE (ID) ON DELETE SET NULL
);

----Blog 1 
INSERT INTO
	BLOG (TITLE, CONTENT, THUMBNAIL_URL, BLOG_TYPE_ID)
VALUES
	(
		'Tầm quan trọng của dinh dưỡng đối với học sinh',
		'<h2>I. Dinh dưỡng học đường là gì?</h2>
<p><strong>Dinh dưỡng học đường</strong> là chế độ ăn uống khoa học, hợp lý dành riêng cho trẻ em và thanh thiếu niên trong độ tuổi đến trường. Việc đảm bảo dinh dưỡng tốt không chỉ giúp học sinh phát triển thể chất mà còn nâng cao trí tuệ, phòng tránh bệnh tật.</p>

<h2>II. Tác động của dinh dưỡng đến sức khỏe và học tập</h2>
<ul>
  <li><strong>Phát triển chiều cao, cân nặng:</strong> Trẻ được ăn uống đầy đủ sẽ tăng trưởng tốt, phát triển đồng đều.</li>
  <li><strong>Cải thiện khả năng tập trung:</strong> Một số nghiên cứu cho thấy, học sinh ăn sáng đủ chất có khả năng tập trung và tiếp thu bài tốt hơn.</li>
  <li><strong>Tăng sức đề kháng:</strong> Chế độ ăn cân đối giúp trẻ phòng tránh được nhiều bệnh vặt như cảm cúm, nhiễm trùng.</li>
  <li><strong>Hạn chế nguy cơ mắc các bệnh mãn tính:</strong> Béo phì, tiểu đường, suy dinh dưỡng,... đều có thể phòng tránh nhờ ăn uống lành mạnh.</li>
</ul>

<h2>III. Những sai lầm phổ biến trong dinh dưỡng học đường</h2>
<ul>
  <li><strong>Bỏ bữa sáng:</strong> Nhiều học sinh do dậy muộn hoặc không đói nên bỏ qua bữa sáng, làm giảm năng lượng học tập đầu ngày.</li>
  <li><strong>Ăn vặt quá nhiều:</strong> Thực phẩm như bánh snack, nước ngọt, trà sữa chứa nhiều đường, chất béo xấu gây béo phì.</li>
  <li><strong>Bữa ăn thiếu rau xanh và trái cây:</strong> Nhiều em chỉ thích ăn thịt cá, bỏ qua nhóm vitamin và khoáng chất.</li>
</ul>

<h2>IV. Gợi ý thực đơn lành mạnh cho học sinh</h2>
<ul>
  <li><strong>Bữa sáng:</strong> Cháo thịt, bánh mì trứng, sữa tươi hoặc ngũ cốc.</li>
  <li><strong>Bữa trưa:</strong> Cơm, thịt/cá, canh rau củ, trái cây tráng miệng.</li>
  <li><strong>Bữa xế:</strong> Sữa chua, trái cây, một ít hạt (hạnh nhân, óc chó...)</li>
  <li><strong>Bữa tối:</strong> Cơm, tôm/thịt nạc, rau luộc/xào, canh.</li>
</ul>
<p><img src="https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/blog-images//bua-an-dinh-duong.jpg" alt="Bữa ăn học đường" style="max-width:100%"></p>

<h2>V. Lời khuyên từ chuyên gia dinh dưỡng</h2>
<blockquote>
  “<strong>Dinh dưỡng hợp lý là nền tảng cho sự phát triển thể chất và tinh thần của trẻ.</strong> Cha mẹ, nhà trường cần phối hợp để xây dựng bữa ăn đa dạng, đủ 4 nhóm chất: bột đường, đạm, béo, vitamin và khoáng chất. Hạn chế đồ ăn nhanh, thức uống có ga.”
</blockquote>
<p><em><strong>Lưu ý:</strong> Học sinh nên uống đủ nước (1,5–2 lít/ngày), tránh bỏ bữa, không ăn quá mặn hoặc quá ngọt.</em></p>
',
'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/blog-images//thap-dinh-duong-cho-tre-em.jpg',
		1
	);

----Blog 2

INSERT INTO BLOG (TITLE, CONTENT, THUMBNAIL_URL, BLOG_TYPE_ID)
VALUES (
  'Những thói quen ăn uống lành mạnh cho học sinh tiểu học',
  '<h2>I. Vì sao cần hình thành thói quen ăn uống từ nhỏ?</h2>
<p>Giai đoạn tiểu học là thời điểm cơ thể và trí não trẻ phát triển mạnh mẽ. Thiết lập <strong>thói quen ăn uống lành mạnh</strong> từ sớm giúp trẻ:</p>
<ul>
  <li>Hình thành nền tảng sức khỏe tốt lâu dài.</li>
  <li>Phòng ngừa các bệnh dinh dưỡng: béo phì, suy dinh dưỡng, thiếu vi chất.</li>
  <li>Tăng khả năng học tập, tập trung và sáng tạo.</li>
</ul>

<h2>II. Những thói quen ăn uống tốt nên rèn luyện</h2>
<ul>
  <li><strong>Ăn đủ 3 bữa chính và 1–2 bữa phụ mỗi ngày:</strong> Đảm bảo cung cấp đủ năng lượng và dưỡng chất.</li>
  <li><strong>Không bỏ bữa sáng:</strong> Đây là bữa ăn quan trọng giúp não bộ hoạt động hiệu quả.</li>
  <li><strong>Ưu tiên thực phẩm tươi sạch, tự nhiên:</strong> Hạn chế đồ chế biến sẵn, chiên rán.</li>
  <li><strong>Bổ sung đủ rau xanh và trái cây:</strong> Cung cấp vitamin, khoáng chất và chất xơ cho hệ tiêu hóa khỏe mạnh.</li>
  <li><strong>Uống đủ nước:</strong> Trẻ nên uống 1,5–2 lít nước/ngày, tránh các loại nước ngọt có gas.</li>
</ul>

<h2>III. Những thực phẩm nên tránh cho học sinh</h2>
<ul>
  <li>Đồ ăn nhanh: gà rán, khoai tây chiên, mì gói...</li>
  <li>Đồ ngọt nhiều đường: kẹo, bánh quy, nước ngọt, trà sữa.</li>
  <li>Đồ uống có caffein: trà đặc, cà phê, nước tăng lực.</li>
  <li>Món ăn quá mặn hoặc cay: ảnh hưởng tiêu hóa và thận.</li>
</ul>

<h2>IV. Gợi ý hộp cơm học đường cân bằng dinh dưỡng</h2>
<ul>
  <li><strong>Protein:</strong> Thịt nạc, cá, trứng, đậu hũ.</li>
  <li><strong>Tinh bột:</strong> Cơm gạo lứt, bánh mì nguyên cám, khoai lang.</li>
  <li><strong>Rau củ:</strong> Cà rốt, cải xanh, đậu que, súp lơ.</li>
  <li><strong>Trái cây:</strong> Chuối, táo, dưa hấu, cam.</li>
</ul>
<p><img src="https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/blog-images//hopcom4ngan.jpg" alt="Hộp cơm học đường" style="max-width:100%"></p>

<h2>V. Vai trò của phụ huynh và nhà trường</h2>
<blockquote>
  “<strong>Sự phối hợp giữa gia đình và nhà trường</strong> là yếu tố then chốt trong việc hình thành thói quen ăn uống tốt. Phụ huynh nên chuẩn bị bữa ăn sạch – đủ – đúng, đồng thời nhà trường cần giáo dục trẻ về dinh dưỡng qua hoạt động ngoại khóa, bài giảng lồng ghép.”
</blockquote>

<p><em><strong>Lưu ý:</strong> Hãy để trẻ tham gia vào quá trình chuẩn bị bữa ăn để tăng hứng thú, giáo dục trẻ chọn thực phẩm tốt và xây dựng thói quen ăn chậm, nhai kỹ.</em></p>',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/blog-images//hopcom.jpg',
  1
);

----Blog 3
INSERT INTO BLOG (TITLE, CONTENT, THUMBNAIL_URL, BLOG_TYPE_ID)
VALUES (
  'Chăm sóc sức khỏe học đường – Phương pháp & hoạt động thiết thực',
  '<h2>I. Sức khỏe học đường là gì?</h2>
<p><strong>Sức khỏe học đường</strong> là tổng hòa các yếu tố liên quan đến thể chất, tinh thần và môi trường sống của học sinh trong trường học. Một môi trường học đường lành mạnh giúp học sinh phát triển toàn diện, học tập hiệu quả và phòng ngừa bệnh tật.</p>

<h2>II. Vai trò của chăm sóc sức khỏe trong nhà trường</h2>
<ul>
  <li><strong>Phòng tránh bệnh tật:</strong> Kiểm tra sức khỏe định kỳ giúp phát hiện sớm các vấn đề như cận thị, sâu răng, thiếu máu, suy dinh dưỡng...</li>
  <li><strong>Đảm bảo vệ sinh môi trường học:</strong> Trường lớp sạch sẽ, đủ ánh sáng, thông thoáng giúp giảm nguy cơ lây nhiễm bệnh.</li>
  <li><strong>Giáo dục thể chất và tinh thần:</strong> Các hoạt động thể thao, ngoại khóa giúp học sinh phát triển thể lực và kỹ năng sống.</li>
</ul>

<h2>III. Các phương pháp chăm sóc sức khỏe cho học sinh</h2>
<ul>
  <li><strong>Khám sức khỏe định kỳ:</strong> Mỗi học kỳ nên tổ chức kiểm tra mắt, răng miệng, chiều cao, cân nặng cho học sinh.</li>
  <li><strong>Tiêm chủng đầy đủ:</strong> Đảm bảo học sinh được tiêm các vaccine cơ bản như sởi, quai bị, rubella, viêm gan B...</li>
  <li><strong>Giữ vệ sinh cá nhân:</strong> Hướng dẫn rửa tay đúng cách, đánh răng sau ăn, giữ vệ sinh thân thể.</li>
  <li><strong>Chế độ dinh dưỡng hợp lý:</strong> Kết hợp bữa ăn học đường đầy đủ 4 nhóm chất và thực phẩm an toàn.</li>
</ul>

<h2>IV. Hoạt động thực tế trong chăm sóc sức khỏe học đường</h2>
<ul>
  <li>Tổ chức ngày hội sức khỏe, tuyên truyền vệ sinh cá nhân.</li>
  <li>Lồng ghép bài học kỹ năng sống về chăm sóc bản thân.</li>
  <li>Thi đua thể thao giữa các lớp nhằm khuyến khích vận động.</li>
  <li>Bố trí cán bộ y tế học đường túc trực, xử lý tình huống y tế cơ bản.</li>
</ul>
<p><img src="https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/blog-images//chamsocsuskhoe.jpg" alt="Hoạt động sức khỏe học đường" style="max-width:100%"></p>

<h2>V. Gợi ý cho phụ huynh và nhà trường</h2>
<blockquote>
  “<strong>Sức khỏe học sinh là ưu tiên hàng đầu</strong>. Phụ huynh và nhà trường cần phối hợp chặt chẽ trong việc xây dựng lối sống lành mạnh, tạo môi trường học tập tích cực, an toàn cho trẻ.”
</blockquote>

<p><em><strong>Lưu ý:</strong> Ngoài sức khỏe thể chất, cần quan tâm đến sức khỏe tâm lý học đường: phòng chống bạo lực học đường, áp lực học tập, trầm cảm học sinh...</em></p>',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/blog-images//chamsocs.jpg',
  2
);

---Blog 4
INSERT INTO BLOG (TITLE, CONTENT, THUMBNAIL_URL, BLOG_TYPE_ID)
VALUES (
  'Tâm lý học đường – Hiểu và vượt qua áp lực tuổi học trò',
  '<h2>I. Tâm lý học đường là gì?</h2>
<p><strong>Tâm lý học đường</strong> là những cảm xúc, suy nghĩ, hành vi của học sinh trong môi trường học tập. Đây là giai đoạn các em hình thành nhân cách, dễ chịu ảnh hưởng bởi bạn bè, kỳ vọng của gia đình, áp lực học hành và cả mạng xã hội.</p>

<h2>II. Nguyên nhân gây áp lực tâm lý ở học sinh</h2>
<ul>
  <li><strong>Áp lực học tập:</strong> Kỳ vọng điểm cao, thi cử căng thẳng, bài tập nhiều dễ khiến học sinh mệt mỏi.</li>
  <li><strong>Sự so sánh:</strong> So sánh với bạn bè về điểm số, ngoại hình, khả năng khiến các em tự ti.</li>
  <li><strong>Mâu thuẫn với phụ huynh, thầy cô:</strong> Khi không được lắng nghe, học sinh dễ bị tổn thương tinh thần.</li>
  <li><strong>Bắt nạt học đường hoặc cô lập xã hội:</strong> Dễ gây trầm cảm, lo âu, sợ đến trường.</li>
</ul>

<h2>III. Dấu hiệu học sinh gặp vấn đề tâm lý</h2>
<ul>
  <li>Thường xuyên mệt mỏi, mất ngủ hoặc ngủ quá nhiều.</li>
  <li>Giảm hứng thú học tập, bỏ bê việc học, dễ cáu gắt.</li>
  <li>Thu mình, không muốn giao tiếp hoặc thay đổi hành vi bất thường.</li>
  <li>Xuất hiện suy nghĩ tiêu cực hoặc hành vi tự làm tổn thương bản thân.</li>
</ul>

<h2>IV. Cách hỗ trợ học sinh vượt qua áp lực tâm lý</h2>
<ul>
  <li><strong>Lắng nghe và thấu hiểu:</strong> Hãy để học sinh được nói ra suy nghĩ mà không bị phán xét.</li>
  <li><strong>Giúp các em quản lý thời gian:</strong> Lên lịch học tập – nghỉ ngơi hợp lý, tránh học dồn ép.</li>
  <li><strong>Khuyến khích vận động và giải trí lành mạnh:</strong> Thể thao, âm nhạc, hội họa giúp giải tỏa căng thẳng.</li>
  <li><strong>Kết nối với chuyên gia tâm lý học đường:</strong> Khi có dấu hiệu bất ổn, cần tư vấn chuyên môn kịp thời.</li>
</ul>
<p><img src="https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/blog-images//tamlyhocduong.jpg" alt="Tư vấn tâm lý học đường" style="max-width:100%"></p>

<h2>V. Thông điệp dành cho phụ huynh và nhà trường</h2>
<blockquote>
  “<strong>Một học sinh khỏe mạnh không chỉ là khỏe về thể chất mà còn ổn định về mặt tinh thần.</strong> Mỗi em đều cần được yêu thương, lắng nghe và tôn trọng trong hành trình trưởng thành.”
</blockquote>

<p><em><strong>Lưu ý:</strong> Đừng xem nhẹ những biểu hiện tâm lý ở học sinh. Việc đồng hành, chia sẻ đúng lúc có thể giúp trẻ vượt qua khủng hoảng và phát triển tích cực hơn.</em></p>',
  'https://mwbzaadpjjoqtwnmfrnm.supabase.co/storage/v1/object/public/blog-images//aplkuc.jpg',
  3
);
---Blog 5
