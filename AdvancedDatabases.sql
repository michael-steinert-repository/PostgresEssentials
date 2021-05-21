CREATE TABLE IF NOT EXISTS customer
(
    id         BIGSERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name  TEXT NOT NULL,
    email      TEXT NOT NULL UNIQUE,
    address    TEXT NOT NULL,
    create_at  TIMESTAMP WITH TIME ZONE
);

INSERT INTO customer (id, first_name, last_name, email, address, create_at)
VALUES (1, 'Michael', 'Steinert', 'michael.steinert@gmail.com', 'Germany,GER', now()),
       (2, 'Marie', 'Schmidt', 'marie.schmidt@gmail.com', 'Germany,GER', now()),
       (3, 'Bruno', 'Doggo', 'bruno.doggo@gmail.com', 'Poland,PL', now()),
       (4, 'Bud', 'Buddy', 'bud.buddy@hotmail.com', 'Italy,IT', now());

CREATE TABLE IF NOT EXISTS customer_order
(
    id           BIGSERIAL PRIMARY KEY,
    customer_id  BIGINT         NOT NULL REFERENCES customer (id),
    total_amount NUMERIC(10, 2) NOT NULL,
    create_at    TIMESTAMP WITH TIME ZONE
);

INSERT INTO customer_order(id, customer_id, total_amount, create_at)
VALUES (1, 1, 1.80, now()),
       (2, 1, 0.36, now()),
       (3, 3, 1.89, now()),
       (4, 3, 5.70, now()),
       (5, 4, 5.77, now());

CREATE TABLE IF NOT EXISTS product
(
    id           BIGSERIAL PRIMARY KEY,
    product_name TEXT           NOT NULL,
    price        NUMERIC(10, 2) NOT NULL,
    discontinued BOOLEAN        NOT NULL
);

INSERT INTO product (id, product_name, price, discontinued)
VALUES (1, 'bread', 1.40, false),
       (2, 'apple', 0.40, false),
       (3, 'banana', 0.18, false),
       (4, 'milk', 0.89, false),
       (5, 'nuts', 1.90, false),
       (6, 'pepsi', 1.00, false);

CREATE TABLE IF NOT EXISTS order_item
(
    id         BIGSERIAL PRIMARY KEY,
    order_id   BIGINT         NOT NULL REFERENCES customer_order (id),
    product_id BIGINT         NOT NULL REFERENCES product (id),
    quantity   INT            NOT NULL CHECK ( quantity > 0 ),
    price      NUMERIC(10, 2) NOT NULL
);

INSERT INTO order_item (order_id, product_id, quantity, price)
VALUES (1, 1, 1, 1.40),
       (1, 2, 1, 0.40),
       (2, 3, 2, .38),
       (3, 6, 1, 1.00),
       (3, 4, 1, 0.89),
       (4, 5, 3, 5.70),
       (5, 1, 1, 1.40),
       (5, 2, 1, 0.40),
       (5, 3, 1, 0.18),
       (5, 4, 1, 0.89),
       (5, 5, 1, 1.90),
       (5, 6, 1, 1.00);

SELECT *
FROM customer;

/* Joins */

/* Joins combines different Relations (Tables) in the Data by one Query */

/* Inner Joins allows to combine Data from Tables where is an Attribute that is matching in each Table */
/* JOIN is the same as INNER JOIN */
SELECT *
FROM customer
         JOIN customer_order ON customer.id = customer_order.customer_id
         JOIN order_item ON customer_order.id = order_item.order_id
         JOIN product ON order_item.product_id = product.id;

/* Left Joins combine Data from the left Table an matching it with the Data from the right Table */
/* It selects all Data from the left Table and the matching Data from the right Table */
/* LEFT JOIN is the same as LEFT OUTER JOIN */
SELECT *
FROM customer
         LEFT JOIN customer_order ON customer.id = customer_order.customer_id;
-- Excluding from the right Table:
SELECT *
FROM customer
         LEFT JOIN customer_order ON customer.id = customer_order.customer_id
WHERE customer_order.id IS NULL;

/* Right Joins combine Data from the right Table an matching it with the Data from the left Table */
/* RIGHT JOIN is the same as RIGHT OUTER JOIN */
SELECT *
FROM customer
         RIGHT JOIN customer_order ON customer.id = customer_order.customer_id;

/* Full Joins selects all Data that matching in the left and right Table */
/* Where is no Match there will be filled the Data with Null */
SELECT *
FROM customer
         FULL JOIN customer_order ON customer.id = customer_order.customer_id;

/* Transactions */

/* ACID Properties */
/* Atomicity guarantees that the Transaction completes in an all-or-nothing Manner */
/* Consistency ensures the Change to Data written to the Database must be valid and follow predefined Rules */
/* Isolation determines how Transaction Integrity is visible to other Transactions */
/* Durability makes sure that Transactions that have been committed will be stored in the Database permanently */

CREATE TABLE IF NOT EXISTS account
(
    id      BIGSERIAL PRIMARY KEY,
    name    TEXT           NOT NULL,
    gender  TEXT           NOT NULL,
    balance NUMERIC(19, 2) NOT NULL
);

INSERT INTO account (name, gender, balance)
VALUES ('Michael', 'MALE', 100),
       ('Marie', 'FEMALE', 200),
       ('Bruno', 'MALE', 300);

BEGIN;
UPDATE account
SET balance = balance - 42
WHERE id = 1;
UPDATE account
SET balance = balance + 42
WHERE id = 2;
COMMIT;
/* ROLLBACK is using if something went wrong while the Transaction */
--ROLLBACK;

/* Index */
/* Indexes make Queries run faster. Without an Index the Query have to go to every single Row in the Table and look after it */

/* If the Keyword UNIQUE or PRIMARY KEY is using it will automatically create an Index of this Column */

CREATE INDEX account_name_index ON account (name);
/* Partial Index */
CREATE INDEX account_balance_index ON account (balance) WHERE gender = 'MALE';
/* Multi Column Index */
/* Multi Column Indexes only work for the both Columns or the first Column (in this Case: name)*/
CREATE INDEX account_name_balance_index ON account (name, balance);

--DROP INDEX accounts_name_index;
--DROP INDEX accounts_balance_index;

/* Functions */
/* Show all Functions: \df */
SELECT count_by_gender('MALE');

CREATE OR REPLACE FUNCTION count_by_gender(parameter_gender TEXT)
    RETURNS INT
    LANGUAGE plpgsql
AS
$$
DECLARE
    --Variable Declaration
    total int;
BEGIN
    --Logic
    SELECT COUNT(*)
    INTO total
    FROM account
    WHERE gender = parameter_gender;

    RETURN total;
END;
$$

/* Roles */
/* Show all Roles: \du */
/* Role is an Alias for User */
/* Roles represent User Accounts */
/* One Role can contains more Roles := Group Role */
CREATE ROLE my_role WITH LOGIN PASSWORD 'password';
CREATE ROLE my_superuser SUPERUSER LOGIN PASSWORD 'password';

/* A Privilege allows a Role to perform a certain Action (select, insert, update, delete, ..) on a Table or Schema */
GRANT SELECT, INSERT ON account TO my_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public to my_superuser;
REVOKE INSERT ON account from my_role;

/* Schema */
/* Show all Schemas: \dn */
/* Schema is a Namespace that contains Tables, Indexes, Views, Functions and other Objects */
/* Schemas organizes the Database in logical Groups that make it easier to manage */
CREATE SCHEMA my_schema;
GRANT USAGE ON SCHEMA my_schema TO my_role;
INSERT INTO my_schema.some_table VALUES ('');
SET search_path TO my_schema, public;
INSERT INTO my_schema.some_table VALUES ('');
