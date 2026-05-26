-- 1. Специальности
CREATE TABLE specialties (
    id_specialty SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialty_code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    comment TEXT
);

-- 2. Доктора
CREATE TABLE doctors (
    id_doctor SERIAL PRIMARY KEY,
    id_specialty INTEGER NOT NULL,
    doctor_full_name VARCHAR(150) NOT NULL,
    birth_date DATE,
    experience_start_year INTEGER CHECK (experience_start_year >= 1950),
    portfolio_url TEXT,
    about TEXT,
    activity_status BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_doctors_specialties
        FOREIGN KEY (id_specialty)
        REFERENCES specialties(id_specialty)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- 3. Пациенты
CREATE TABLE patients (
    id_patient SERIAL PRIMARY KEY,
    patient_full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    comment TEXT
);

-- 4. Пользователи
CREATE TABLE users (
    id_user SERIAL PRIMARY KEY,
    user_full_name VARCHAR(150) NOT NULL,
    role VARCHAR(30) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    comment TEXT,

    CONSTRAINT chk_users_role
        CHECK (role IN ('администратор', 'врач', 'пациент'))
);

-- 5. Слоты
CREATE TABLE slots (
    id_slot SERIAL PRIMARY KEY,
    id_doctor INTEGER NOT NULL,
    slot_start_date DATE NOT NULL,
    slot_start_time TIME NOT NULL,
    slot_end_date DATE NOT NULL,
    slot_end_time TIME NOT NULL,
    slot_availability BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_slots_doctors
        FOREIGN KEY (id_doctor)
        REFERENCES doctors(id_doctor)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_doctor_slot
        UNIQUE (id_doctor, slot_start_date, slot_start_time)
);

-- 6. Записи
CREATE TABLE appointments (
    id_appointment SERIAL PRIMARY KEY,
    id_patient INTEGER NOT NULL,
    id_slot INTEGER NOT NULL UNIQUE,
    appointment_status VARCHAR(30) NOT NULL DEFAULT 'created',
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_appointments_patients
        FOREIGN KEY (id_patient)
        REFERENCES patients(id_patient)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_appointments_slots
        FOREIGN KEY (id_slot)
        REFERENCES slots(id_slot)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_appointment_status
        CHECK (appointment_status IN ('created', 'confirmed', 'cancelled', 'completed'))
);

-- 7. История статусов записи
CREATE TABLE appointment_status_history (
    id SERIAL PRIMARY KEY,
    id_appointment INTEGER NOT NULL,
    id_user INTEGER NOT NULL,
    old_status VARCHAR(30),
    current_status VARCHAR(30) NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_history_appointments
        FOREIGN KEY (id_appointment)
        REFERENCES appointments(id_appointment)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_history_users
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_history_current_status
        CHECK (current_status IN ('created', 'confirmed', 'cancelled', 'completed'))
);

-- Заполнение таблицы "Специальности"
INSERT INTO specialties (name, specialty_code, description, comment) VALUES
('Терапевт', 'THERAPIST', 'Первичный приём, общее состояние, температура, простуда и слабость', 'Основная специальность для онлайн-консультаций'),
('Ветеринарный врач', 'VET', 'Консультации по здоровью животных и необычных пациентов', 'Специальность добавлена для Доктора Айболита'),
('Травматолог', 'TRAUMA', 'Травмы, ушибы, укусы чудовищ, восстановление после сражений', 'Подходит для героев после приключений'),
('Токсиколог', 'TOXICOLOGIST', 'Отравления, укусы, действие зелий и неизвестных веществ', 'Специальность для мира Ведьмака'),
('Психотерапевт', 'PSYCHOTHERAPIST', 'Тревога, стресс, бессонница и эмоциональное выгорание', 'Подходит для долгих путешествий и сложных квестов'),
('Целитель', 'HEALER', 'Комплексная помощь, восстановление, наблюдение после тяжёлых состояний', 'Специальность для эльфийской медицины');

-- Заполнение таблицы "Доктора"
INSERT INTO doctors (id_specialty, doctor_full_name, birth_date, experience_start_year, portfolio_url, about, activity_status) VALUES
((SELECT id_specialty FROM specialties WHERE specialty_code = 'VET'), 'Доктор Айболит', '1955-01-01', 1980, 'https://medvisit.demo/doctors/aibolit', 'Добрый врач, который помогает и людям, и животным. Специализируется на срочных обращениях и заботливых консультациях', TRUE),
((SELECT id_specialty FROM specialties WHERE specialty_code = 'TOXICOLOGIST'), 'Геральт из Ривии', '1975-05-01', 2000, 'https://medvisit.demo/doctors/geralt', 'Опытный специалист по токсинам, укусам чудовищ и последствиям контакта с неизвестными существами', TRUE),
((SELECT id_specialty FROM specialties WHERE specialty_code = 'HEALER'), 'Элронд Полуэльф', '1960-09-29', 1985, 'https://medvisit.demo/doctors/elrond', 'Мудрый целитель из Ривенделла. Помогает с восстановлением после сложных состояний и долгих путешествий', TRUE),
((SELECT id_specialty FROM specialties WHERE specialty_code = 'PSYCHOTHERAPIST'), 'Гэндальф Серый', '1950-01-01', 1975, 'https://medvisit.demo/doctors/gandalf', 'Консультирует по стрессу, тревоге перед важными событиями и эмоциональному выгоранию после приключений', TRUE),
((SELECT id_specialty FROM specialties WHERE specialty_code = 'TRAUMA'), 'Арагорн Элесар', '1970-03-01', 1995, 'https://medvisit.demo/doctors/aragorn', 'Знает основы полевой медицины, помогает при травмах, ранах и восстановлении после походов', TRUE);

-- Заполнение таблицы "Пациенты"
INSERT INTO patients (patient_full_name, phone, email, comment) VALUES
('Барбос', '+79990000001', 'barbos@example.com', 'Нужна консультация после прогулки и лёгкой простуды'),
('Цири из Цинтры', '+79990000002', 'ciri@example.com', 'Нужна консультация после тренировки и перемещений между мирами'),
('Фродо Бэггинс', '+79990000003', 'frodo@example.com', 'Жалобы на усталость после долгого путешествия'),
('Сэм Гэмджи', '+79990000004', 'sam@example.com', 'Нужна консультация по восстановлению после похода'),
('Лютик', '+79990000005', 'dandelion@example.com', 'Беспокоит голос после долгого выступления'),
('Бильбо Бэггинс', '+79990000006', 'bilbo@example.com', 'Плановая онлайн-консультация');

-- Заполнение таблицы "Пользователи"
INSERT INTO users (user_full_name, role, email, comment) VALUES
('Администратор MedVisit', 'администратор', 'admin@medvisit.demo', 'Администратор сервиса, помогает с записями'),
('Доктор Айболит', 'врач', 'aibolit@medvisit.demo', 'Врач сервиса MedVisit'),
('Геральт из Ривии', 'врач', 'geralt@medvisit.demo', 'Врач сервиса MedVisit'),
('Элронд Полуэльф', 'врач', 'elrond@medvisit.demo', 'Врач сервиса MedVisit'),
('Фродо Бэггинс', 'пациент', 'frodo.user@example.com', 'Пациент сервиса MedVisit'),
('Цири из Цинтры', 'пациент', 'ciri.user@example.com', 'Пациент сервиса MedVisit');

-- Заполнение таблицы "Слоты"
INSERT INTO slots (id_doctor, slot_start_date, slot_start_time, slot_end_date, slot_end_time, slot_availability) VALUES
((SELECT id_doctor FROM doctors WHERE doctor_full_name = 'Доктор Айболит'), '2026-05-25', '09:00', '2026-05-25', '09:30', FALSE),
((SELECT id_doctor FROM doctors WHERE doctor_full_name = 'Доктор Айболит'), '2026-05-25', '10:00', '2026-05-25', '10:30', TRUE),
((SELECT id_doctor FROM doctors WHERE doctor_full_name = 'Геральт из Ривии'), '2026-05-25', '11:00', '2026-05-25', '11:30', FALSE),
((SELECT id_doctor FROM doctors WHERE doctor_full_name = 'Геральт из Ривии'), '2026-05-25', '12:00', '2026-05-25', '12:30', TRUE),
((SELECT id_doctor FROM doctors WHERE doctor_full_name = 'Элронд Полуэльф'), '2026-05-26', '13:00', '2026-05-26', '13:30', FALSE),
((SELECT id_doctor FROM doctors WHERE doctor_full_name = 'Элронд Полуэльф'), '2026-05-26', '14:00', '2026-05-26', '14:30', TRUE),
((SELECT id_doctor FROM doctors WHERE doctor_full_name = 'Гэндальф Серый'), '2026-05-26', '15:00', '2026-05-26', '15:30', TRUE),
((SELECT id_doctor FROM doctors WHERE doctor_full_name = 'Арагорн Элесар'), '2026-05-27', '16:00', '2026-05-27', '16:30', TRUE);

-- Заполнение таблицы "Записи"
INSERT INTO appointments (id_patient, id_slot, appointment_status, comment) VALUES
(
    (SELECT id_patient FROM patients WHERE patient_full_name = 'Барбос'),
    (
        SELECT s.id_slot
        FROM slots s
        JOIN doctors d ON d.id_doctor = s.id_doctor
        WHERE d.doctor_full_name = 'Доктор Айболит'
          AND s.slot_start_date = '2026-05-25'
          AND s.slot_start_time = '09:00'
    ),
    'confirmed',
    'Барбос записан к Доктору Айболиту'
),
(
    (SELECT id_patient FROM patients WHERE patient_full_name = 'Цири из Цинтры'),
    (
        SELECT s.id_slot
        FROM slots s
        JOIN doctors d ON d.id_doctor = s.id_doctor
        WHERE d.doctor_full_name = 'Геральт из Ривии'
          AND s.slot_start_date = '2026-05-25'
          AND s.slot_start_time = '11:00'
    ),
    'created',
    'Цири записана к Геральту для консультации после тренировки'
),
(
    (SELECT id_patient FROM patients WHERE patient_full_name = 'Фродо Бэггинс'),
    (
        SELECT s.id_slot
        FROM slots s
        JOIN doctors d ON d.id_doctor = s.id_doctor
        WHERE d.doctor_full_name = 'Элронд Полуэльф'
          AND s.slot_start_date = '2026-05-26'
          AND s.slot_start_time = '13:00'
    ),
    'confirmed',
    'Фродо записан к Элронду для восстановления после путешествия'
);

-- Заполнение таблицы "История статусов записи"
INSERT INTO appointment_status_history (id_appointment, id_user, old_status, current_status) VALUES
(
    (SELECT id_appointment FROM appointments WHERE comment = 'Барбос записан к Доктору Айболиту'),
    (SELECT id_user FROM users WHERE user_full_name = 'Администратор MedVisit'),
    'created',
    'confirmed'
),
(
    (SELECT id_appointment FROM appointments WHERE comment = 'Цири записана к Геральту для консультации после тренировки'),
    (SELECT id_user FROM users WHERE user_full_name = 'Администратор MedVisit'),
    NULL,
    'created'
),
(
    (SELECT id_appointment FROM appointments WHERE comment = 'Фродо записан к Элронду для восстановления после путешествия'),
    (SELECT id_user FROM users WHERE user_full_name = 'Администратор MedVisit'),
    'created',
    'confirmed'
);

-- 1. SELECT
SELECT
    s.id_slot,
    d.doctor_full_name,
    s.slot_start_date,
    s.slot_start_time,
    s.slot_end_time,
    s.slot_availability
FROM slots s
JOIN doctors d ON d.id_doctor = s.id_doctor
WHERE d.doctor_full_name = 'Доктор Айболит'
  AND s.slot_availability = TRUE;

-- 2. INSERT
INSERT INTO patients (patient_full_name, phone, email, comment)
VALUES ('Леголас Зеленолист', '+79990000007', 'legolas@example.com', 'Пациент добавлен для проверки INSERT');

-- 3. UPDATE
UPDATE patients
SET comment = 'Пациент просит консультацию после долгого похода'
WHERE patient_full_name = 'Леголас Зеленолист';

-- 4. DELETE
DELETE FROM patients
WHERE patient_full_name = 'Леголас Зеленолист';

-- 5. SELECT с JOIN
SELECT
    a.id_appointment,
    p.patient_full_name,
    sp.name AS specialty_name,
    d.doctor_full_name,
    s.slot_start_date,
    s.slot_start_time,
    a.appointment_status,
    a.comment
FROM appointments a
JOIN patients p ON p.id_patient = a.id_patient
JOIN slots s ON s.id_slot = a.id_slot
JOIN doctors d ON d.id_doctor = s.id_doctor
JOIN specialties sp ON sp.id_specialty = d.id_specialty
ORDER BY s.slot_start_date, s.slot_start_time;
