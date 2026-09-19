-- ============================================================
-- PostgreSQL 全语法练习数据集
-- ============================================================

-- 清理环境
DROP TABLE IF EXISTS score_log CASCADE;
DROP TABLE IF EXISTS enrollment CASCADE;
DROP TABLE IF EXISTS course CASCADE;
DROP TABLE IF EXISTS student CASCADE;
DROP TABLE IF EXISTS teacher CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP VIEW IF EXISTS v_student_score CASCADE;
DROP FUNCTION IF EXISTS get_student_avg(INT) CASCADE;

-- ============================================================
-- 第一部分：DDL 建表
-- ============================================================

-- 1.1 院系表
CREATE TABLE department (
    dept_id     SERIAL PRIMARY KEY,                 -- 自增主键
    dept_name   VARCHAR(50) NOT NULL UNIQUE,        -- 唯一约束
    building    VARCHAR(50),
    budget      NUMERIC(12,2) CHECK (budget > 0),   -- 检查约束
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- 默认值
);

-- 1.2 教师表
CREATE TABLE teacher (
    teacher_id  SERIAL PRIMARY KEY,
    name        VARCHAR(50) NOT NULL,
    gender      CHAR(1) CHECK (gender IN ('M','F')),
    title       VARCHAR(20) DEFAULT '讲师',          -- 默认值
    hire_date   DATE NOT NULL,
    salary      NUMERIC(10,2),
    dept_id     INT REFERENCES department(dept_id)   -- 外键
                ON DELETE SET NULL ON UPDATE CASCADE
);

-- 1.3 学生表
CREATE TABLE student (
    student_id  SERIAL PRIMARY KEY,
    name        VARCHAR(50) NOT NULL,
    gender      CHAR(1) CHECK (gender IN ('M','F')),
    birth_date  DATE,
    email       VARCHAR(100) UNIQUE,
    phone       VARCHAR(20),
    address     TEXT,
    enroll_year INT NOT NULL,
    gpa         NUMERIC(3,2) DEFAULT 0.00,
    dept_id     INT REFERENCES department(dept_id),
    mentor_id   INT REFERENCES teacher(teacher_id),  -- 导师
    is_active   BOOLEAN DEFAULT TRUE
);

-- 1.4 课程表
CREATE TABLE course (
    course_id   SERIAL PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    credit      INT CHECK (credit BETWEEN 1 AND 10),
    course_type VARCHAR(20) DEFAULT '必修',          -- 必修/选修
    teacher_id  INT REFERENCES teacher(teacher_id),
    dept_id     INT REFERENCES department(dept_id)
);

-- 1.5 选课成绩表
CREATE TABLE enrollment (
    student_id  INT REFERENCES student(student_id) ON DELETE CASCADE,
    course_id   INT REFERENCES course(course_id)   ON DELETE CASCADE,
    score       NUMERIC(5,2) CHECK (score BETWEEN 0 AND 100),
    semester    VARCHAR(20) NOT NULL,                -- 如 '2024-春'
    exam_date   DATE,
    PRIMARY KEY (student_id, course_id, semester)    -- 联合主键
);

-- 1.6 成绩变动日志表
CREATE TABLE score_log (
    log_id      SERIAL PRIMARY KEY,
    student_id  INT,
    course_id   INT,
    old_score   NUMERIC(5,2),
    new_score   NUMERIC(5,2),
    changed_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 2.1 单行插入（指定列）
INSERT INTO department (dept_name, building, budget)
VALUES ('计算机学院', '信息楼A座', 5000000.00);

-- 2.2 多行插入
INSERT INTO department (dept_name, building, budget) VALUES
    ('数学学院',   '理学楼B座', 3000000.00),
    ('外国语学院', '文科楼C座', 2000000.00),
    ('物理学院',   '理学楼D座', 4000000.00),
    ('经济管理学院','商科楼E座', 3500000.00);

INSERT INTO teacher (name, gender, title, hire_date, salary, dept_id) VALUES
    ('张志远',   'M', '教授',   '2010-09-01', 25000.00, 1),
    ('李雅雯',   'F', '副教授', '2015-03-15', 18000.00, 1),
    ('王建国',   'M', '讲师',   '2020-07-01', 12000.00, 2),
    ('刘志强',   'M', '教授',   '2008-01-10', 26000.00, 2),
    ('陈雪梅',   'F', '副教授', '2016-08-20', 17500.00, 3),
    ('杨浩然',   'M', '讲师',   '2021-09-01', 11500.00, 4),
    ('赵淑华',   'F', '教授',   '2012-05-30', 24000.00, 5),
    ('孙鹏飞',   'M', '助教',   '2023-02-15',  8000.00, 1);

INSERT INTO student (name, gender, birth_date, email, phone, address, enroll_year, gpa, dept_id, mentor_id) VALUES
    ('王一诺', 'M', '2003-05-12', 'wangyinuo@edu.cn',   '13800000001', '北京市海淀区', 2021, 3.65, 1, 1),
    ('李雨桐', 'F', '2004-08-23', 'liyutong@edu.cn',    '13800000002', '上海市浦东新区', 2021, 3.80, 1, 2),
    ('张皓轩', 'M', '2003-11-05', 'zhanghaoxuan@edu.cn','13800000003', '广州市天河区', 2022, 2.95, 1, 1),
    ('刘欣怡', 'F', '2005-02-14', 'liuxinyi@edu.cn',    '13800000004', '深圳市南山区', 2022, 3.50, 2, 3),
    ('陈俊杰', 'M', '2004-06-30', 'chenjunjie@edu.cn',  '13800000005', '杭州市西湖区', 2021, 3.20, 2, 4),
    ('杨思琪', 'F', '2003-09-18', 'yangsiqi@edu.cn',    '13800000006', '成都市武侯区', 2020, 3.90, 3, 5),
    ('黄梓豪', 'M', '2005-01-25', 'huangzihao@edu.cn',  '13800000007', '武汉市洪山区', 2023, 3.10, 4, 6),
    ('周梦琪', 'F', '2004-12-08', 'zhoumengqi@edu.cn',  '13800000008', '南京市鼓楼区', 2022, 3.45, 5, 7),
    ('吴俊杰', 'M', '2003-04-16', 'wujunjie@edu.cn',    '13800000009', '西安市雁塔区', 2021, 2.80, 1, 8),
    ('徐若曦', 'F', '2005-07-07', 'xuruoxi@edu.cn',     '13800000010', '重庆市渝中区', 2023, 3.75, 2, 3),
    ('马子涵', 'M', '2004-10-11', 'mazihan@edu.cn',     NULL,           '天津市和平区', 2022, 3.05, 1, NULL);

INSERT INTO course (course_name, credit, course_type, teacher_id, dept_id) VALUES
    ('数据库原理',   4, '必修', 1, 1),
    ('高等数学',     5, '必修', 3, 2),
    ('大学英语',     3, '必修', 5, 3),
    ('数据结构',     4, '必修', 2, 1),
    ('线性代数',     3, '必修', 4, 2),
    ('操作系统',     4, '必修', 1, 1),
    ('物理实验',     2, '选修', 6, 4),
    ('宏观经济学',   3, '选修', 7, 5),
    ('Python程序设计', 3, '选修', 8, 1),
    ('英语口语',     2, '选修', 5, 3);

INSERT INTO enrollment (student_id, course_id, score, semester, exam_date) VALUES
    (1, 1, 92.5, '2024-春', '2024-06-20'),
    (1, 2, 85.0, '2024-春', '2024-06-22'),
    (1, 4, 88.0, '2024-秋', '2024-12-20'),
    (2, 1, 95.0, '2024-春', '2024-06-20'),
    (2, 3, 90.5, '2024-春', '2024-06-25'),
    (2, 5, 78.0, '2024-秋', '2024-12-22'),
    (3, 1, 65.0, '2024-春', '2024-06-20'),
    (3, 2, 58.5, '2024-春', '2024-06-22'),
    (3, 9, 82.0, '2024-秋', '2024-12-25'),
    (4, 2, 91.0, '2024-春', '2024-06-22'),
    (4, 5, 87.5, '2024-春', '2024-06-23'),
    (5, 2, 76.0, '2024-春', '2024-06-22'),
    (5, 8, 84.0, '2024-秋', '2024-12-26'),
    (6, 3, 96.0, '2024-春', '2024-06-25'),
    (6, 10, 93.5, '2024-春', '2024-06-26'),
    (7, 7, 72.0, '2024-春', '2024-06-28'),
    (7, 2, 68.5, '2024-春', '2024-06-22'),
    (8, 8, 89.0, '2024-春', '2024-06-27'),
    (8, 3, 81.5, '2024-春', '2024-06-25'),
    (9, 1, 55.0, '2024-春', '2024-06-20'),
    (9, 6, 71.0, '2024-秋', '2024-12-21'),
    (10, 2, 94.0, '2024-春', '2024-06-22'),
    (10, 5, 90.0, '2024-春', '2024-06-23'),
    (11, 1, 77.5, '2024-春', '2024-06-20'),
    (11, 9, 85.5, '2024-秋', '2024-12-25'),
    (1, 9, 88.5, '2024-秋', '2024-12-25');
