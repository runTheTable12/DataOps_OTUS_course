create schema hw;

create table hw.course (
id INTEGER PRIMARY KEY UNIQUE NOT NULL,
name VARCHAR (250),
hours INTEGER
);

create table hw.student (
id INTEGER,
first_name VARCHAR(255),
last_name VARCHAR(255), 
dob DATE,
course_id INTEGER REFERENCES hw.course(id)
);