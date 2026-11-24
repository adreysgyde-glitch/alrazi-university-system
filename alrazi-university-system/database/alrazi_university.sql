-- =====================================================================
-- AL-RAZI UNIVERSITY MANAGEMENT PLATFORM (ACADEMIC DEMO DATABASE)
-- Designed by: Idris Mohammed Saleh Ali Sharafuddin
-- Engine: MySQL 8.0+ | Charset: utf8mb4
-- IMPORTANT: Independent academic demo. Not an official university database.
-- All sample people and transactions below are fictional test data.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS alrazi_university
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE alrazi_university;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP VIEW IF EXISTS v_student_academic_summary;
DROP VIEW IF EXISTS v_course_enrollment_summary;
DROP VIEW IF EXISTS v_invoice_balances;

DROP TABLE IF EXISTS audit_logs, notifications, announcements,
  cafeteria_order_items, cafeteria_orders, cafeteria_products, cafeteria_outlets,
  parking_permits, parking_zones, inventory_transactions, inventory_items,
  installment_payments, installment_plans,
  transport_subscriptions, vehicles, transport_routes,
  dorm_assignments, dorm_rooms, dorm_buildings,
  activity_registrations, activities, student_clubs,
  lab_reservations, labs,
  library_loans, book_copies, library_books,
  scholarship_awards, scholarships, payments, invoices,
  attendance_records, attendance_sessions, grades, assessments,
  enrollments, class_sessions, sections, classrooms,
  course_prerequisites, courses, instructors, students,
  programs, academic_terms, departments,
  user_roles, roles, users;

CREATE TABLE departments (
  department_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  department_code VARCHAR(20) NOT NULL UNIQUE,
  department_name VARCHAR(150) NOT NULL,
  faculty_name VARCHAR(150) NOT NULL,
  head_name VARCHAR(150) NULL,
  office_phone VARCHAR(30) NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE programs (
  program_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  department_id BIGINT UNSIGNED NOT NULL,
  program_code VARCHAR(30) NOT NULL UNIQUE,
  program_name VARCHAR(160) NOT NULL,
  degree_level ENUM('Diploma','Bachelor','Master','Doctorate') NOT NULL DEFAULT 'Bachelor',
  duration_years TINYINT UNSIGNED NOT NULL DEFAULT 4,
  total_credit_hours SMALLINT UNSIGNED NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_program_department FOREIGN KEY (department_id) REFERENCES departments(department_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE academic_terms (
  term_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  term_code VARCHAR(30) NOT NULL UNIQUE,
  term_name VARCHAR(100) NOT NULL,
  academic_year VARCHAR(20) NOT NULL,
  starts_on DATE NOT NULL,
  ends_on DATE NOT NULL,
  registration_open BOOLEAN NOT NULL DEFAULT FALSE,
  is_current BOOLEAN NOT NULL DEFAULT FALSE,
  CHECK (ends_on >= starts_on)
) ENGINE=InnoDB;

CREATE TABLE users (
  user_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(160) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  phone VARCHAR(30) NULL,
  account_status ENUM('Active','Suspended','Pending') NOT NULL DEFAULT 'Pending',
  last_login_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE roles (
  role_id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_code VARCHAR(40) NOT NULL UNIQUE,
  role_name VARCHAR(100) NOT NULL,
  description VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE user_roles (
  user_id BIGINT UNSIGNED NOT NULL,
  role_id SMALLINT UNSIGNED NOT NULL,
  assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE students (
  student_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NULL UNIQUE,
  student_number VARCHAR(30) NOT NULL UNIQUE,
  program_id BIGINT UNSIGNED NOT NULL,
  admission_term_id BIGINT UNSIGNED NOT NULL,
  first_name VARCHAR(80) NOT NULL,
  middle_name VARCHAR(80) NULL,
  last_name VARCHAR(80) NOT NULL,
  date_of_birth DATE NULL,
  gender ENUM('Male','Female','Unspecified') NOT NULL DEFAULT 'Unspecified',
  email VARCHAR(190) NULL,
  phone VARCHAR(30) NULL,
  address VARCHAR(255) NULL,
  enrollment_status ENUM('Active','Suspended','Graduated','Withdrawn') NOT NULL DEFAULT 'Active',
  admission_date DATE NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_student_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
  CONSTRAINT fk_student_program FOREIGN KEY (program_id) REFERENCES programs(program_id) ON DELETE RESTRICT,
  CONSTRAINT fk_student_term FOREIGN KEY (admission_term_id) REFERENCES academic_terms(term_id) ON DELETE RESTRICT,
  INDEX idx_students_name (last_name, first_name),
  INDEX idx_students_status (enrollment_status)
) ENGINE=InnoDB;

CREATE TABLE instructors (
  instructor_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NULL UNIQUE,
  department_id BIGINT UNSIGNED NOT NULL,
  employee_number VARCHAR(30) NOT NULL UNIQUE,
  full_name VARCHAR(160) NOT NULL,
  academic_rank ENUM('Teaching Assistant','Lecturer','Assistant Professor','Associate Professor','Professor') NOT NULL DEFAULT 'Lecturer',
  specialty VARCHAR(150) NULL,
  email VARCHAR(190) NULL,
  phone VARCHAR(30) NULL,
  employment_status ENUM('Active','On Leave','Inactive') NOT NULL DEFAULT 'Active',
  CONSTRAINT fk_instructor_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
  CONSTRAINT fk_instructor_department FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE RESTRICT,
  INDEX idx_instructor_department (department_id)
) ENGINE=InnoDB;

CREATE TABLE courses (
  course_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  department_id BIGINT UNSIGNED NOT NULL,
  course_code VARCHAR(30) NOT NULL UNIQUE,
  course_name VARCHAR(160) NOT NULL,
  description TEXT NULL,
  credit_hours TINYINT UNSIGNED NOT NULL,
  course_level TINYINT UNSIGNED NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_course_department FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE RESTRICT,
  CHECK (credit_hours > 0 AND credit_hours <= 8)
) ENGINE=InnoDB;

CREATE TABLE course_prerequisites (
  course_id BIGINT UNSIGNED NOT NULL,
  prerequisite_course_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (course_id, prerequisite_course_id),
  CONSTRAINT fk_prereq_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
  CONSTRAINT fk_prereq_required FOREIGN KEY (prerequisite_course_id) REFERENCES courses(course_id) ON DELETE RESTRICT,
  CHECK (course_id <> prerequisite_course_id)
) ENGINE=InnoDB;

CREATE TABLE classrooms (
  classroom_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  building VARCHAR(100) NOT NULL,
  room_code VARCHAR(30) NOT NULL UNIQUE,
  capacity SMALLINT UNSIGNED NOT NULL,
  room_type ENUM('Lecture','Computer Lab','Science Lab','Exam Hall','Other') NOT NULL DEFAULT 'Lecture',
  is_available BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE sections (
  section_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  course_id BIGINT UNSIGNED NOT NULL,
  term_id BIGINT UNSIGNED NOT NULL,
  instructor_id BIGINT UNSIGNED NOT NULL,
  section_code VARCHAR(20) NOT NULL,
  max_students SMALLINT UNSIGNED NOT NULL DEFAULT 40,
  section_status ENUM('Open','Full','Closed','Completed') NOT NULL DEFAULT 'Open',
  UNIQUE KEY uq_section_term (course_id, term_id, section_code),
  CONSTRAINT fk_section_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE RESTRICT,
  CONSTRAINT fk_section_term FOREIGN KEY (term_id) REFERENCES academic_terms(term_id) ON DELETE RESTRICT,
  CONSTRAINT fk_section_instructor FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE class_sessions (
  session_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  section_id BIGINT UNSIGNED NOT NULL,
  classroom_id BIGINT UNSIGNED NOT NULL,
  day_of_week ENUM('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') NOT NULL,
  starts_at TIME NOT NULL,
  ends_at TIME NOT NULL,
  session_kind ENUM('Lecture','Lab','Tutorial') NOT NULL DEFAULT 'Lecture',
  CONSTRAINT fk_session_section FOREIGN KEY (section_id) REFERENCES sections(section_id) ON DELETE CASCADE,
  CONSTRAINT fk_session_room FOREIGN KEY (classroom_id) REFERENCES classrooms(classroom_id) ON DELETE RESTRICT,
  CHECK (ends_at > starts_at),
  INDEX idx_sessions_day_time (day_of_week, starts_at, ends_at)
) ENGINE=InnoDB;

CREATE TABLE enrollments (
  enrollment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  student_id BIGINT UNSIGNED NOT NULL,
  section_id BIGINT UNSIGNED NOT NULL,
  enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  enrollment_status ENUM('Enrolled','Dropped','Completed','Failed') NOT NULL DEFAULT 'Enrolled',
  UNIQUE KEY uq_student_section (student_id, section_id),
  CONSTRAINT fk_enrollment_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE RESTRICT,
  CONSTRAINT fk_enrollment_section FOREIGN KEY (section_id) REFERENCES sections(section_id) ON DELETE RESTRICT,
  INDEX idx_enrollment_status (enrollment_status)
) ENGINE=InnoDB;

CREATE TABLE assessments (
  assessment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  section_id BIGINT UNSIGNED NOT NULL,
  assessment_name VARCHAR(140) NOT NULL,
  assessment_type ENUM('Quiz','Midterm','Final','Project','Practical','Other') NOT NULL,
  scheduled_at DATETIME NULL,
  max_score DECIMAL(6,2) NOT NULL,
  weight_percent DECIMAL(5,2) NOT NULL,
  CONSTRAINT fk_assessment_section FOREIGN KEY (section_id) REFERENCES sections(section_id) ON DELETE CASCADE,
  CHECK (max_score > 0 AND weight_percent >= 0 AND weight_percent <= 100)
) ENGINE=InnoDB;

CREATE TABLE grades (
  grade_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  assessment_id BIGINT UNSIGNED NOT NULL,
  enrollment_id BIGINT UNSIGNED NOT NULL,
  score DECIMAL(6,2) NOT NULL,
  graded_at DATETIME NULL,
  feedback VARCHAR(500) NULL,
  UNIQUE KEY uq_grade_assessment_enrollment (assessment_id, enrollment_id),
  CONSTRAINT fk_grade_assessment FOREIGN KEY (assessment_id) REFERENCES assessments(assessment_id) ON DELETE CASCADE,
  CONSTRAINT fk_grade_enrollment FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
  CHECK (score >= 0)
) ENGINE=InnoDB;

CREATE TABLE attendance_sessions (
  attendance_session_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  section_id BIGINT UNSIGNED NOT NULL,
  session_date DATE NOT NULL,
  topic VARCHAR(180) NULL,
  created_by BIGINT UNSIGNED NULL,
  UNIQUE KEY uq_attendance_section_date (section_id, session_date),
  CONSTRAINT fk_attendance_session_section FOREIGN KEY (section_id) REFERENCES sections(section_id) ON DELETE CASCADE,
  CONSTRAINT fk_attendance_created_by FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE attendance_records (
  attendance_record_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  attendance_session_id BIGINT UNSIGNED NOT NULL,
  enrollment_id BIGINT UNSIGNED NOT NULL,
  attendance_status ENUM('Present','Absent','Late','Excused') NOT NULL,
  notes VARCHAR(255) NULL,
  UNIQUE KEY uq_attendance_enrollment (attendance_session_id, enrollment_id),
  CONSTRAINT fk_attendance_record_session FOREIGN KEY (attendance_session_id) REFERENCES attendance_sessions(attendance_session_id) ON DELETE CASCADE,
  CONSTRAINT fk_attendance_record_enrollment FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE invoices (
  invoice_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  student_id BIGINT UNSIGNED NOT NULL,
  term_id BIGINT UNSIGNED NULL,
  invoice_number VARCHAR(40) NOT NULL UNIQUE,
  fee_type ENUM('Tuition','Registration','Student Activities','ID Card','Lab','Housing','Transport','Library Fine','Other') NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  issued_on DATE NOT NULL,
  due_on DATE NOT NULL,
  invoice_status ENUM('Unpaid','Partially Paid','Paid','Cancelled','Overdue') NOT NULL DEFAULT 'Unpaid',
  notes VARCHAR(500) NULL,
  CONSTRAINT fk_invoice_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE RESTRICT,
  CONSTRAINT fk_invoice_term FOREIGN KEY (term_id) REFERENCES academic_terms(term_id) ON DELETE SET NULL,
  CHECK (amount >= 0 AND due_on >= issued_on),
  INDEX idx_invoice_student_status (student_id, invoice_status)
) ENGINE=InnoDB;

CREATE TABLE payments (
  payment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  invoice_id BIGINT UNSIGNED NOT NULL,
  receipt_number VARCHAR(40) NOT NULL UNIQUE,
  paid_amount DECIMAL(12,2) NOT NULL,
  payment_method ENUM('Cash','Bank Transfer','Card','Online','Other') NOT NULL,
  paid_at DATETIME NOT NULL,
  reference_note VARCHAR(150) NULL,
  received_by BIGINT UNSIGNED NULL,
  CONSTRAINT fk_payment_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE RESTRICT,
  CONSTRAINT fk_payment_user FOREIGN KEY (received_by) REFERENCES users(user_id) ON DELETE SET NULL,
  CHECK (paid_amount > 0),
  INDEX idx_payments_paid_at (paid_at)
) ENGINE=InnoDB;

CREATE TABLE installment_plans (
  installment_plan_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  invoice_id BIGINT UNSIGNED NOT NULL UNIQUE,
  number_of_installments TINYINT UNSIGNED NOT NULL,
  approved_at DATE NOT NULL,
  plan_status ENUM('Active','Completed','Cancelled','Defaulted') NOT NULL DEFAULT 'Active',
  CONSTRAINT fk_installment_plan_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE RESTRICT,
  CHECK (number_of_installments > 0)
) ENGINE=InnoDB;

CREATE TABLE installment_payments (
  installment_payment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  installment_plan_id BIGINT UNSIGNED NOT NULL,
  installment_number TINYINT UNSIGNED NOT NULL,
  due_on DATE NOT NULL,
  amount_due DECIMAL(12,2) NOT NULL,
  amount_paid DECIMAL(12,2) NOT NULL DEFAULT 0,
  paid_at DATETIME NULL,
  installment_status ENUM('Pending','Paid','Overdue','Partially Paid') NOT NULL DEFAULT 'Pending',
  UNIQUE KEY uq_installment_number (installment_plan_id, installment_number),
  CONSTRAINT fk_installment_payment_plan FOREIGN KEY (installment_plan_id) REFERENCES installment_plans(installment_plan_id) ON DELETE CASCADE,
  CHECK (amount_due >= 0 AND amount_paid >= 0 AND amount_paid <= amount_due)
) ENGINE=InnoDB;

CREATE TABLE scholarships (
  scholarship_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  scholarship_name VARCHAR(150) NOT NULL,
  scholarship_type ENUM('Merit','Need Based','Excellence','Other') NOT NULL,
  coverage_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  CHECK (coverage_percent >= 0 AND coverage_percent <= 100)
) ENGINE=InnoDB;

CREATE TABLE scholarship_awards (
  award_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  scholarship_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  term_id BIGINT UNSIGNED NOT NULL,
  approved_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  award_status ENUM('Pending','Approved','Rejected','Withdrawn') NOT NULL DEFAULT 'Pending',
  UNIQUE KEY uq_scholarship_student_term (scholarship_id, student_id, term_id),
  CONSTRAINT fk_award_scholarship FOREIGN KEY (scholarship_id) REFERENCES scholarships(scholarship_id) ON DELETE RESTRICT,
  CONSTRAINT fk_award_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE RESTRICT,
  CONSTRAINT fk_award_term FOREIGN KEY (term_id) REFERENCES academic_terms(term_id) ON DELETE RESTRICT,
  CHECK (approved_amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE library_books (
  book_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  isbn VARCHAR(30) NULL UNIQUE,
  title VARCHAR(220) NOT NULL,
  author VARCHAR(180) NULL,
  publisher VARCHAR(160) NULL,
  category VARCHAR(100) NULL,
  publication_year YEAR NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE book_copies (
  copy_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  book_id BIGINT UNSIGNED NOT NULL,
  accession_number VARCHAR(40) NOT NULL UNIQUE,
  copy_status ENUM('Available','On Loan','Reserved','Maintenance','Lost') NOT NULL DEFAULT 'Available',
  shelf_location VARCHAR(80) NULL,
  CONSTRAINT fk_copy_book FOREIGN KEY (book_id) REFERENCES library_books(book_id) ON DELETE RESTRICT,
  INDEX idx_copy_status (copy_status)
) ENGINE=InnoDB;

CREATE TABLE library_loans (
  loan_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  copy_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  borrowed_at DATE NOT NULL,
  due_at DATE NOT NULL,
  returned_at DATE NULL,
  loan_status ENUM('Borrowed','Returned','Overdue','Lost') NOT NULL DEFAULT 'Borrowed',
  fine_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_loan_copy FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE RESTRICT,
  CONSTRAINT fk_loan_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE RESTRICT,
  CHECK (due_at >= borrowed_at AND fine_amount >= 0),
  INDEX idx_loan_student_status (student_id, loan_status)
) ENGINE=InnoDB;

CREATE TABLE labs (
  lab_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  lab_code VARCHAR(30) NOT NULL UNIQUE,
  lab_name VARCHAR(150) NOT NULL,
  building VARCHAR(100) NOT NULL,
  capacity SMALLINT UNSIGNED NOT NULL,
  supervisor_instructor_id BIGINT UNSIGNED NULL,
  lab_status ENUM('Available','Maintenance','Unavailable') NOT NULL DEFAULT 'Available',
  CONSTRAINT fk_lab_supervisor FOREIGN KEY (supervisor_instructor_id) REFERENCES instructors(instructor_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE lab_reservations (
  reservation_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  lab_id BIGINT UNSIGNED NOT NULL,
  section_id BIGINT UNSIGNED NULL,
  requested_by BIGINT UNSIGNED NULL,
  reservation_date DATE NOT NULL,
  starts_at TIME NOT NULL,
  ends_at TIME NOT NULL,
  purpose VARCHAR(255) NOT NULL,
  reservation_status ENUM('Requested','Approved','Rejected','Completed','Cancelled') NOT NULL DEFAULT 'Requested',
  CONSTRAINT fk_lab_reservation_lab FOREIGN KEY (lab_id) REFERENCES labs(lab_id) ON DELETE RESTRICT,
  CONSTRAINT fk_lab_reservation_section FOREIGN KEY (section_id) REFERENCES sections(section_id) ON DELETE SET NULL,
  CONSTRAINT fk_lab_reservation_user FOREIGN KEY (requested_by) REFERENCES users(user_id) ON DELETE SET NULL,
  CHECK (ends_at > starts_at)
) ENGINE=InnoDB;

CREATE TABLE student_clubs (
  club_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  club_name VARCHAR(150) NOT NULL UNIQUE,
  description VARCHAR(500) NULL,
  advisor_instructor_id BIGINT UNSIGNED NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_club_advisor FOREIGN KEY (advisor_instructor_id) REFERENCES instructors(instructor_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE activities (
  activity_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  club_id BIGINT UNSIGNED NULL,
  activity_name VARCHAR(180) NOT NULL,
  activity_description TEXT NULL,
  starts_at DATETIME NOT NULL,
  ends_at DATETIME NULL,
  location VARCHAR(180) NULL,
  max_participants SMALLINT UNSIGNED NULL,
  activity_status ENUM('Draft','Open','Full','Completed','Cancelled') NOT NULL DEFAULT 'Draft',
  CONSTRAINT fk_activity_club FOREIGN KEY (club_id) REFERENCES student_clubs(club_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE activity_registrations (
  activity_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  attendance_status ENUM('Registered','Attended','Absent','Cancelled') NOT NULL DEFAULT 'Registered',
  PRIMARY KEY (activity_id, student_id),
  CONSTRAINT fk_activity_reg_activity FOREIGN KEY (activity_id) REFERENCES activities(activity_id) ON DELETE CASCADE,
  CONSTRAINT fk_activity_reg_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE dorm_buildings (
  dorm_building_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  building_name VARCHAR(120) NOT NULL UNIQUE,
  address VARCHAR(255) NULL,
  supervisor_name VARCHAR(150) NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE dorm_rooms (
  room_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  dorm_building_id BIGINT UNSIGNED NOT NULL,
  room_number VARCHAR(20) NOT NULL,
  capacity TINYINT UNSIGNED NOT NULL,
  room_status ENUM('Available','Full','Maintenance') NOT NULL DEFAULT 'Available',
  UNIQUE KEY uq_dorm_room (dorm_building_id, room_number),
  CONSTRAINT fk_room_building FOREIGN KEY (dorm_building_id) REFERENCES dorm_buildings(dorm_building_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE dorm_assignments (
  assignment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  room_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  starts_on DATE NOT NULL,
  ends_on DATE NULL,
  assignment_status ENUM('Active','Ended','Cancelled') NOT NULL DEFAULT 'Active',
  CONSTRAINT fk_dorm_assignment_room FOREIGN KEY (room_id) REFERENCES dorm_rooms(room_id) ON DELETE RESTRICT,
  CONSTRAINT fk_dorm_assignment_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE RESTRICT,
  CHECK (ends_on IS NULL OR ends_on >= starts_on),
  INDEX idx_dorm_assignment_student (student_id, assignment_status)
) ENGINE=InnoDB;

CREATE TABLE transport_routes (
  route_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  route_name VARCHAR(150) NOT NULL UNIQUE,
  origin_name VARCHAR(150) NOT NULL,
  destination_name VARCHAR(150) NOT NULL,
  departure_time TIME NULL,
  route_status ENUM('Active','Suspended') NOT NULL DEFAULT 'Active'
) ENGINE=InnoDB;

CREATE TABLE vehicles (
  vehicle_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  route_id BIGINT UNSIGNED NULL,
  plate_number VARCHAR(30) NOT NULL UNIQUE,
  vehicle_type VARCHAR(80) NOT NULL,
  capacity SMALLINT UNSIGNED NOT NULL,
  driver_name VARCHAR(150) NULL,
  vehicle_status ENUM('Active','Maintenance','Inactive') NOT NULL DEFAULT 'Active',
  CONSTRAINT fk_vehicle_route FOREIGN KEY (route_id) REFERENCES transport_routes(route_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE transport_subscriptions (
  subscription_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  route_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  term_id BIGINT UNSIGNED NOT NULL,
  subscription_status ENUM('Active','Pending','Cancelled','Expired') NOT NULL DEFAULT 'Pending',
  UNIQUE KEY uq_transport_student_term (student_id, term_id),
  CONSTRAINT fk_transport_route FOREIGN KEY (route_id) REFERENCES transport_routes(route_id) ON DELETE RESTRICT,
  CONSTRAINT fk_transport_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE RESTRICT,
  CONSTRAINT fk_transport_term FOREIGN KEY (term_id) REFERENCES academic_terms(term_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE parking_zones (
  parking_zone_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  zone_name VARCHAR(120) NOT NULL UNIQUE,
  location_description VARCHAR(255) NULL,
  total_spaces SMALLINT UNSIGNED NOT NULL,
  zone_status ENUM('Open','Full','Closed') NOT NULL DEFAULT 'Open'
) ENGINE=InnoDB;

CREATE TABLE parking_permits (
  parking_permit_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  parking_zone_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NULL,
  user_id BIGINT UNSIGNED NULL,
  permit_number VARCHAR(40) NOT NULL UNIQUE,
  vehicle_plate VARCHAR(30) NOT NULL,
  valid_from DATE NOT NULL,
  valid_until DATE NOT NULL,
  permit_status ENUM('Active','Expired','Suspended','Revoked') NOT NULL DEFAULT 'Active',
  CONSTRAINT fk_parking_permit_zone FOREIGN KEY (parking_zone_id) REFERENCES parking_zones(parking_zone_id) ON DELETE RESTRICT,
  CONSTRAINT fk_parking_permit_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE SET NULL,
  CONSTRAINT fk_parking_permit_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
  CHECK (valid_until >= valid_from)
) ENGINE=InnoDB;

CREATE TABLE inventory_items (
  inventory_item_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  item_code VARCHAR(40) NOT NULL UNIQUE,
  item_name VARCHAR(180) NOT NULL,
  warehouse_name VARCHAR(120) NOT NULL,
  unit_name VARCHAR(40) NOT NULL,
  quantity_on_hand DECIMAL(12,2) NOT NULL DEFAULT 0,
  reorder_level DECIMAL(12,2) NOT NULL DEFAULT 0,
  item_status ENUM('Available','Low Stock','Out of Stock','Discontinued') NOT NULL DEFAULT 'Available',
  CHECK (quantity_on_hand >= 0 AND reorder_level >= 0)
) ENGINE=InnoDB;

CREATE TABLE inventory_transactions (
  inventory_transaction_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  inventory_item_id BIGINT UNSIGNED NOT NULL,
  transaction_type ENUM('Receipt','Issue','Adjustment','Transfer') NOT NULL,
  quantity DECIMAL(12,2) NOT NULL,
  transaction_at DATETIME NOT NULL,
  reference_code VARCHAR(60) NULL,
  handled_by BIGINT UNSIGNED NULL,
  notes VARCHAR(500) NULL,
  CONSTRAINT fk_inventory_transaction_item FOREIGN KEY (inventory_item_id) REFERENCES inventory_items(inventory_item_id) ON DELETE RESTRICT,
  CONSTRAINT fk_inventory_transaction_user FOREIGN KEY (handled_by) REFERENCES users(user_id) ON DELETE SET NULL,
  CHECK (quantity > 0),
  INDEX idx_inventory_transaction_date (transaction_at)
) ENGINE=InnoDB;

CREATE TABLE cafeteria_outlets (
  cafeteria_outlet_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  outlet_name VARCHAR(140) NOT NULL UNIQUE,
  location VARCHAR(180) NOT NULL,
  manager_name VARCHAR(150) NULL,
  outlet_status ENUM('Open','Closed','Maintenance') NOT NULL DEFAULT 'Open'
) ENGINE=InnoDB;

CREATE TABLE cafeteria_products (
  cafeteria_product_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cafeteria_outlet_id BIGINT UNSIGNED NOT NULL,
  product_name VARCHAR(160) NOT NULL,
  category VARCHAR(80) NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  is_available BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_cafeteria_product_outlet FOREIGN KEY (cafeteria_outlet_id) REFERENCES cafeteria_outlets(cafeteria_outlet_id) ON DELETE RESTRICT,
  CHECK (unit_price >= 0)
) ENGINE=InnoDB;

CREATE TABLE cafeteria_orders (
  cafeteria_order_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cafeteria_outlet_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NULL,
  order_number VARCHAR(40) NOT NULL UNIQUE,
  ordered_at DATETIME NOT NULL,
  order_status ENUM('Pending','Preparing','Ready','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_cafeteria_order_outlet FOREIGN KEY (cafeteria_outlet_id) REFERENCES cafeteria_outlets(cafeteria_outlet_id) ON DELETE RESTRICT,
  CONSTRAINT fk_cafeteria_order_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE SET NULL,
  CHECK (total_amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE cafeteria_order_items (
  cafeteria_order_item_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cafeteria_order_id BIGINT UNSIGNED NOT NULL,
  cafeteria_product_id BIGINT UNSIGNED NOT NULL,
  quantity SMALLINT UNSIGNED NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_cafeteria_order_item_order FOREIGN KEY (cafeteria_order_id) REFERENCES cafeteria_orders(cafeteria_order_id) ON DELETE CASCADE,
  CONSTRAINT fk_cafeteria_order_item_product FOREIGN KEY (cafeteria_product_id) REFERENCES cafeteria_products(cafeteria_product_id) ON DELETE RESTRICT,
  CHECK (quantity > 0 AND unit_price >= 0)
) ENGINE=InnoDB;

CREATE TABLE announcements (
  announcement_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  body TEXT NOT NULL,
  audience ENUM('All','Students','Instructors','Staff','Department') NOT NULL DEFAULT 'All',
  department_id BIGINT UNSIGNED NULL,
  publish_at DATETIME NULL,
  expires_at DATETIME NULL,
  announcement_status ENUM('Draft','Published','Archived') NOT NULL DEFAULT 'Draft',
  created_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_announcement_department FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
  CONSTRAINT fk_announcement_user FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE notifications (
  notification_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  message VARCHAR(700) NOT NULL,
  notification_type ENUM('Info','Success','Warning','Urgent') NOT NULL DEFAULT 'Info',
  read_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  INDEX idx_notification_user_read (user_id, read_at)
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
  audit_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NULL,
  action_name VARCHAR(100) NOT NULL,
  entity_name VARCHAR(100) NOT NULL,
  entity_id BIGINT UNSIGNED NULL,
  ip_address VARCHAR(45) NULL,
  details JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
  INDEX idx_audit_entity (entity_name, entity_id),
  INDEX idx_audit_created (created_at)
) ENGINE=InnoDB;

-- Useful reporting views
CREATE VIEW v_student_academic_summary AS
SELECT s.student_id, s.student_number,
       CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
       p.program_name, d.department_name, s.enrollment_status,
       COUNT(DISTINCT CASE WHEN e.enrollment_status='Enrolled' THEN e.enrollment_id END) AS active_courses
FROM students s
JOIN programs p ON p.program_id=s.program_id
JOIN departments d ON d.department_id=p.department_id
LEFT JOIN enrollments e ON e.student_id=s.student_id
GROUP BY s.student_id, s.student_number, s.first_name, s.middle_name, s.last_name,
         p.program_name, d.department_name, s.enrollment_status;

CREATE VIEW v_course_enrollment_summary AS
SELECT c.course_code, c.course_name, t.term_name, sec.section_code,
       i.full_name AS instructor_name,
       COUNT(CASE WHEN e.enrollment_status='Enrolled' THEN 1 END) AS enrolled_students,
       sec.max_students
FROM sections sec
JOIN courses c ON c.course_id=sec.course_id
JOIN academic_terms t ON t.term_id=sec.term_id
JOIN instructors i ON i.instructor_id=sec.instructor_id
LEFT JOIN enrollments e ON e.section_id=sec.section_id
GROUP BY c.course_code, c.course_name, t.term_name, sec.section_code, i.full_name, sec.max_students;

CREATE VIEW v_invoice_balances AS
SELECT inv.invoice_id, inv.invoice_number, inv.student_id, inv.fee_type,
       inv.amount AS invoice_amount, COALESCE(SUM(pay.paid_amount),0) AS total_paid,
       GREATEST(inv.amount-COALESCE(SUM(pay.paid_amount),0),0) AS remaining_balance,
       inv.due_on, inv.invoice_status
FROM invoices inv
LEFT JOIN payments pay ON pay.invoice_id=inv.invoice_id
GROUP BY inv.invoice_id, inv.invoice_number, inv.student_id, inv.fee_type,
         inv.amount, inv.due_on, inv.invoice_status;

-- ---------------------------------------------------------------------
-- Fictional sample data. Change or remove these records before real use.
-- ---------------------------------------------------------------------
INSERT INTO departments (department_code,department_name,faculty_name,head_name,office_phone) VALUES
('IT','تقنية المعلومات','كلية الحاسوب وتقنية المعلومات','مسؤول تجريبي','000000000'),
('CS','علوم الحاسوب','كلية الحاسوب وتقنية المعلومات','مسؤول تجريبي','000000001'),
('BA','إدارة الأعمال','كلية العلوم الإدارية','مسؤول تجريبي','000000002'),
('MED','العلوم الطبية','كلية العلوم الطبية','مسؤول تجريبي','000000003');

INSERT INTO programs (department_id,program_code,program_name,degree_level,duration_years,total_credit_hours) VALUES
(1,'IT-BSC','تقنية المعلومات','Bachelor',4,132),
(2,'CS-BSC','علوم الحاسوب','Bachelor',4,136),
(3,'BA-BSC','إدارة الأعمال','Bachelor',4,128),
(4,'MED-BSC','العلوم الطبية','Bachelor',4,140);

INSERT INTO academic_terms (term_code,term_name,academic_year,starts_on,ends_on,registration_open,is_current) VALUES
('2026-FALL','الفصل الأول','2026/2027','2026-09-01','2027-01-15',TRUE,TRUE),
('2026-SPRING','الفصل الثاني','2026/2027','2027-02-01','2027-06-15',FALSE,FALSE);

INSERT INTO roles (role_code,role_name,description) VALUES
('SUPER_ADMIN','مدير النظام','إدارة عامة وصلاحيات شاملة'),
('REGISTRAR','القبول والتسجيل','إدارة ملفات الطلاب والتسجيل'),
('INSTRUCTOR','عضو هيئة تدريس','المقررات والدرجات والحضور'),
('FINANCE','الإدارة المالية','الفواتير والمدفوعات'),
('STUDENT','طالب','الخدمات الأكاديمية الذاتية');

INSERT INTO users (full_name,email,password_hash,account_status) VALUES
('Demo Administrator','admin@example.test','REPLACE_WITH_A_REAL_BCRYPT_HASH','Active'),
('Demo Instructor','instructor@example.test','REPLACE_WITH_A_REAL_BCRYPT_HASH','Active');

INSERT INTO instructors (user_id,department_id,employee_number,full_name,academic_rank,specialty,email,phone) VALUES
(2,2,'FAC-0018','د. أحمد القباطي','Assistant Professor','هندسة البرمجيات','a.q@example.test','000000010'),
(NULL,1,'FAC-0024','م. سمية الحداد','Lecturer','شبكات الحاسوب','s.h@example.test','000000011'),
(NULL,1,'FAC-0031','م. خالد حسن','Lecturer','أمن المعلومات','k.h@example.test','000000012'),
(NULL,3,'FAC-0040','د. سامي عبد الله','Assistant Professor','إدارة مالية','s.a@example.test','000000013');

INSERT INTO courses (department_id,course_code,course_name,description,credit_hours,course_level) VALUES
(1,'IT201','شبكات الحاسوب','مقدمة في مفاهيم الشبكات وبروتوكولات التوجيه.',3,2),
(2,'CS202','قواعد البيانات','تصميم قواعد البيانات والاستعلامات وإدارة البيانات.',3,2),
(1,'IT305','أمن المعلومات','مبادئ أمن المعلومات وإدارة المخاطر.',3,3),
(3,'BA110','مبادئ الإدارة','مفاهيم الإدارة والتنظيم والقيادة.',2,1);

INSERT INTO classrooms (building,room_code,capacity,room_type) VALUES
('مبنى الحاسوب','ROOM-104',40,'Lecture'),
('مبنى الحاسوب','LAB-01',24,'Computer Lab'),
('مبنى العلوم','ROOM-205',35,'Lecture');

INSERT INTO sections (course_id,term_id,instructor_id,section_code,max_students,section_status) VALUES
(1,1,2,'IT-3A',40,'Open'),(2,1,1,'CS-2B',40,'Open'),(3,1,3,'IT-3B',35,'Open'),(4,1,4,'BA-1A',45,'Open');

INSERT INTO class_sessions (section_id,classroom_id,day_of_week,starts_at,ends_at,session_kind) VALUES
(1,2,'Sunday','08:00:00','10:00:00','Lab'),
(2,1,'Monday','10:00:00','12:00:00','Lecture'),
(3,3,'Tuesday','12:00:00','14:00:00','Lecture');

INSERT INTO students (student_number,program_id,admission_term_id,first_name,middle_name,last_name,gender,email,phone,enrollment_status,admission_date) VALUES
('2026-IT-0142',1,1,'سارة','أحمد','نموذج','Female','sara@example.test','000000101','Active','2026-09-01'),
('2025-CS-0098',2,1,'محمد','علي','تجريبي','Male','mohamed@example.test','000000102','Active','2025-09-01'),
('2026-BA-0211',3,1,'ريم','خالد','مثال','Female','reem@example.test','000000103','Active','2026-09-01');

INSERT INTO enrollments (student_id,section_id,enrollment_status) VALUES
(1,1,'Enrolled'),(1,2,'Enrolled'),(2,1,'Enrolled'),(2,3,'Enrolled'),(3,4,'Enrolled');

INSERT INTO assessments (section_id,assessment_name,assessment_type,scheduled_at,max_score,weight_percent) VALUES
(1,'اختبار منتصف الفصل','Midterm','2026-11-28 09:00:00',30,30),
(2,'مشروع قواعد البيانات','Project','2026-12-02 10:00:00',20,20);

INSERT INTO invoices (student_id,term_id,invoice_number,fee_type,amount,issued_on,due_on,invoice_status) VALUES
(1,1,'INV-26031','Tuition',85000,'2026-09-01','2026-12-10','Unpaid'),
(2,1,'INV-26032','Registration',15000,'2026-09-01','2026-11-20','Paid'),
(3,1,'INV-26033','ID Card',5000,'2026-09-03','2026-11-18','Overdue');

INSERT INTO payments (invoice_id,receipt_number,paid_amount,payment_method,paid_at,reference_note) VALUES
(2,'RCPT-26032',15000,'Cash','2026-11-18 11:20:00','عملية تجريبية');

INSERT INTO scholarships (scholarship_name,scholarship_type,coverage_percent) VALUES
('منحة التفوق الأكاديمي','Merit',25.00),('منحة الدعم الطلابي','Need Based',50.00);

INSERT INTO library_books (isbn,title,author,publisher,category,publication_year) VALUES
('9780000000001','أساسيات قواعد البيانات','مؤلف تجريبي','ناشر تجريبي','تقنية المعلومات',2022),
('9780000000002','شبكات الحاسوب','مؤلف تجريبي','ناشر تجريبي','شبكات',2021),
('9780000000003','مقدمة في البرمجة','مؤلف تجريبي','ناشر تجريبي','برمجة',2023);

INSERT INTO book_copies (book_id,accession_number,copy_status,shelf_location) VALUES
(1,'BK-0001','Available','IT-A1'),(1,'BK-0002','On Loan','IT-A1'),(2,'BK-0003','Available','NET-B2'),(3,'BK-0004','Available','CS-C1');

INSERT INTO labs (lab_code,lab_name,building,capacity,supervisor_instructor_id,lab_status) VALUES
('LAB-01','مختبر الشبكات','مبنى الحاسوب',24,2,'Available'),
('LAB-02','مختبر البرمجة','مبنى الحاسوب',30,3,'Available');

INSERT INTO student_clubs (club_name,description,advisor_instructor_id) VALUES
('نادي التقنية','أنشطة وفعاليات تقنية للطلاب.',2),
('نادي ريادة الأعمال','فعاليات الابتكار وريادة الأعمال.',4);

INSERT INTO activities (club_id,activity_name,activity_description,starts_at,ends_at,location,max_participants,activity_status) VALUES
(1,'مسابقة البرمجة','مسابقة تدريبية تجريبية للطلاب.','2026-12-02 09:00:00','2026-12-02 14:00:00','قاعة الأنشطة',60,'Open'),
(2,'ملتقى الابتكار','عرض مبادرات ومشاريع طلابية.','2026-12-10 10:00:00','2026-12-10 14:00:00','القاعة الكبرى',100,'Open');

INSERT INTO dorm_buildings (building_name,address,supervisor_name) VALUES
('السكن A','عنوان تجريبي','مشرف تجريبي'),('السكن B','عنوان تجريبي','مشرف تجريبي');
INSERT INTO dorm_rooms (dorm_building_id,room_number,capacity,room_status) VALUES
(1,'A-104',4,'Available'),(1,'A-105',4,'Full'),(2,'B-202',3,'Available');

INSERT INTO transport_routes (route_name,origin_name,destination_name,departure_time) VALUES
('خط صنعاء – الجامعة','نقطة تجمع تجريبية','الجامعة','07:00:00'),
('خط حدة – الجامعة','نقطة تجمع تجريبية','الجامعة','07:15:00');
INSERT INTO vehicles (route_id,plate_number,vehicle_type,capacity,driver_name,vehicle_status) VALUES
(1,'DEMO-BUS-04','حافلة',30,'سائق تجريبي','Active'),
(2,'DEMO-BUS-07','حافلة',24,'سائق تجريبي','Active');

INSERT INTO installment_plans (invoice_id,number_of_installments,approved_at,plan_status) VALUES
(1,3,'2026-09-05','Active');
INSERT INTO installment_payments (installment_plan_id,installment_number,due_on,amount_due,amount_paid,installment_status) VALUES
(1,1,'2026-10-01',28333.33,28333.33,'Paid'),
(1,2,'2026-11-01',28333.33,0,'Overdue'),
(1,3,'2026-12-01',28333.34,0,'Pending');

INSERT INTO parking_zones (zone_name,location_description,total_spaces,zone_status) VALUES
('موقف الطلاب','منطقة مواقف تجريبية',80,'Open'),('موقف الموظفين','منطقة مواقف تجريبية',40,'Open');
INSERT INTO parking_permits (parking_zone_id,student_id,permit_number,vehicle_plate,valid_from,valid_until,permit_status) VALUES
(1,1,'PK-1002','DEMO-101','2026-09-01','2027-01-15','Active');

INSERT INTO inventory_items (item_code,item_name,warehouse_name,unit_name,quantity_on_hand,reorder_level,item_status) VALUES
('INV-001','أجهزة حاسوب مكتبية','مخزن تقنية المعلومات','جهاز',12,3,'Available'),
('INV-002','كابلات شبكة','مخزن المختبرات','قطعة',5,10,'Low Stock'),
('INV-003','أوراق طباعة','المخزن العام','رزمة',0,5,'Out of Stock');
INSERT INTO inventory_transactions (inventory_item_id,transaction_type,quantity,transaction_at,reference_code,notes) VALUES
(1,'Receipt',12,'2026-10-01 09:00:00','PO-DEMO-01','حركة توريد تجريبية'),
(2,'Issue',2,'2026-11-10 11:00:00','ISS-DEMO-02','حركة صرف تجريبية');

INSERT INTO cafeteria_outlets (outlet_name,location,manager_name,outlet_status) VALUES
('المقصف الرئيسي','الحرم الجامعي — موقع تجريبي','مشرف تجريبي','Open'),
('كافتيريا مبنى الحاسوب','مبنى الحاسوب — موقع تجريبي','مشرف تجريبي','Open');
INSERT INTO cafeteria_products (cafeteria_outlet_id,product_name,category,unit_price,is_available) VALUES
(1,'وجبة خفيفة','وجبات',1200,TRUE),(2,'مياه','مشروبات',300,TRUE),(1,'قهوة','مشروبات',500,FALSE);

INSERT INTO announcements (title,body,audience,publish_at,announcement_status,created_by) VALUES
('إعلان الاختبارات النصفية','هذا إعلان تجريبي لأغراض اختبار النظام فقط.','Students','2026-11-24 08:00:00','Published',1),
('تحديث مواعيد التسجيل','يرجى مراجعة وحدة القبول والتسجيل. إعلان تجريبي.','All','2026-11-22 09:00:00','Published',1);

SET FOREIGN_KEY_CHECKS = 1;

-- Example queries:
-- SELECT * FROM v_student_academic_summary;
-- SELECT * FROM v_course_enrollment_summary;
-- SELECT * FROM v_invoice_balances;
-- SELECT student_number, student_name FROM v_student_academic_summary WHERE enrollment_status='Active';
