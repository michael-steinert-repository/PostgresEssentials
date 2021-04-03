/* Delete an existing Database */
DROP DATABASE postgres_essentials;

/* Create a new Database */
CREATE DATABASE postgres_essentials;

CREATE TABLE person(
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(12) NOT NULL,
    age INTEGER NOT NULL,
    date_of_birth DATE NOT NULL
);

ALTER TABLE person ADD email VARCHAR(50);

INSERT INTO person (name, age, date_of_birth)
    VALUES ('Michael', 27, DATE '1994-02-02');

INSERT INTO person (name, age, date_of_birth)
    VALUES ('Marie', 26, DATE '1995-12-04');

INSERT INTO person (name, age, date_of_birth)
    VALUES ('Marie', 22, DATE '1999-11-08');

INSERT INTO person (name, age, date_of_birth, email)
    VALUES ('Bruno', 12, DATE '2009-02-08', 'Bruno@mail.com');

SELECT * FROM person ORDER BY age, date_of_birth DESC;

DELETE from person where id = 2;

SELECT name FROM person ORDER BY age, date_of_birth DESC;

/* Distinct remove Duplicates from Query */
SELECT DISTINCT name from person;

SELECT * from person WHERE age = 27;

/* Offset ignores the first 1 Row of Data */
SELECT name from person where name = 'Marie' OFFSET 1 FETCH FIRST 1 ROW ONLY;

SELECT name from person where name IN ('Michael', 'Marie');

SELECT name from person where date_of_birth between DATE '1994-01-01' AND '1995-12-31';

SELECT name from person where name LIKE 'M_____%';

/* GROUP BY grouped Data based on a Column */
SELECT name, COUNT(*) FROM person GROUP BY name;

/* HAVING allows an extra Filtering after the Aggregation of GROUP BY */
SELECT name, COUNT(*) AS number_of_perons FROM person GROUP BY name HAVING COUNT(*) >= 2;

SELECT name, ROUND(age * 0.1, 2)  AS ten_percent_of_age FROM person;

/* Null-Handling */
/* Coalesce is a Default Value if the queried Data is not present */
SELECT name, COALESCE(email, 'Email not provided') FROM person;
/* Nullif returns the first Argument if the second Argument is not equal to the first Argument */
SELECT COALESCE(10 / NULLIF(2, 42), 0);
SELECT COALESCE(10 / NULLIF(0, 0), 0);

/* Casting Date and Time */
SELECT NOW();
SELECT NOW()::DATE;
SELECT NOW()::TIME;

/* Adding and Subtracting Dates with Interval */
SELECT NOW() + INTERVAL '42 YEARS';
SELECT NOW() - INTERVAL '10 MONTHS';
SELECT NOW() - INTERVAL '10 DAYS';
SELECT (NOW() - INTERVAL '10 DAYS')::DATE;

/* Extracting Fields from Timestamp */
SELECT EXTRACT(YEAR FROM NOW());
SELECT EXTRACT(MONTH FROM NOW());
SELECT EXTRACT(DAY FROM NOW());
/* DOW: Day of Week */
SELECT EXTRACT(DOW FROM NOW());

SELECT name, AGE(now(), date_of_birth) AS age_of_person FROM person;

/* Unique Constraints allows to have an unique Value per Column */
ALTER TABLE person ADD CONSTRAINT unique_email UNIQUE(email);
ALTER TABLE person DROP CONSTRAINT unique_email;
/* Constrain Name is defined by Postgres */
ALTER TABLE person ADD UNIQUE(email);

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'person';

/* Check Constraint allows to add a Constraint based on a boolean Condition */
ALTER TABLE person ADD gender VARCHAR(6);
ALTER TABLE person ADD CONSTRAINT gender_constraint CHECK (gender = 'male' OR gender = 'female');
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'person';
INSERT INTO person (name, age, date_of_birth, email, gender)
    VALUES ('Bud', 2, DATE '2019-02-08', 'Bud@mail.com', 'male');

DELETE FROM person WHERE name = 'Bud' AND email = 'Bud@mail.com';

UPDATE person SET email = 'Michael@mail.com', gender = 'male' WHERE id = 1;

SELECT * FROM person WHERE id = 1;

/* On Conflict allows to handle Conflicts in Constraints -> Query has no Effect */
INSERT INTO person (id, name, age, date_of_birth) VALUES (1, 'Michael', 27, DATE '1994-02-02') ON CONFLICT (id) DO NOTHING;

/* On Conflict allows to handle Conflicts in Constraints -> Query has Effect */
INSERT INTO person (id, name, age, date_of_birth, email)
VALUES (1, 'Michael', 27, DATE '1994-02-02', 'Michael@mail.edu') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email;

/* One-to-One Relationship */
ALTER TABLE person ADD car_id BIGINT REFERENCES car(id);
ALTER TABLE person ADD UNIQUE(car_id);

CREATE TABLE car(
    id BIGSERIAL NOT NULL PRIMARY KEY,
    make VARCHAR(12) NOT NULL
);

INSERT INTO car(make) VALUES ('VW');
INSERT INTO car(make) VALUES ('Audio');
INSERT INTO car(make) VALUES ('BMW');
SELECT * from car;

UPDATE person SET car_id = 3 WHERE id = 1;
SELECT * FROM person;

/* Inner Joins give the Result of both Records if a Foreign Key is present in both Tables */
SELECT * FROM person JOIN car ON person.car_id = car.id;

/* Left Joins include all Records from the left Table and the Records from the right Table that have a Foreign Key in both Tables */
SELECT * FROM person LEFT JOIN car ON person.car_id = car.id;

