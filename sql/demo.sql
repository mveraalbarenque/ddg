-- DROP SCHEMA public;

CREATE SCHEMA public AUTHORIZATION postgres;

COMMENT ON SCHEMA public IS 'standard public schema';

-- DROP TYPE public."mpaa_rating";

CREATE TYPE public."mpaa_rating" AS ENUM (
	'G',
	'PG',
	'PG-13',
	'R',
	'NC-17');

-- DROP DOMAIN public."year";

CREATE DOMAIN public."year" AS integer
	CONSTRAINT year_check CHECK (VALUE >= 1901 AND VALUE <= 2155);
-- DROP SEQUENCE public.actor_actor_id_seq;

CREATE SEQUENCE public.actor_actor_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.address_address_id_seq;

CREATE SEQUENCE public.address_address_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.category_category_id_seq;

CREATE SEQUENCE public.category_category_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.city_city_id_seq;

CREATE SEQUENCE public.city_city_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.country_country_id_seq;

CREATE SEQUENCE public.country_country_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.customer_customer_id_seq;

CREATE SEQUENCE public.customer_customer_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.film_film_id_seq;

CREATE SEQUENCE public.film_film_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.inventory_inventory_id_seq;

CREATE SEQUENCE public.inventory_inventory_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.language_language_id_seq;

CREATE SEQUENCE public.language_language_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.payment_payment_id_seq;

CREATE SEQUENCE public.payment_payment_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.rental_rental_id_seq;

CREATE SEQUENCE public.rental_rental_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.staff_staff_id_seq;

CREATE SEQUENCE public.staff_staff_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.store_store_id_seq;

CREATE SEQUENCE public.store_store_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;-- public.actor definition

-- Drop table

-- DROP TABLE actor;

CREATE TABLE actor (
	actor_id serial4 NOT NULL,
	first_name varchar(45) NOT NULL,
	last_name varchar(45) NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT actor_pkey PRIMARY KEY (actor_id)
);
CREATE INDEX idx_actor_last_name ON public.actor USING btree (last_name);

-- Table Triggers

create trigger last_updated before
update
    on
    public.actor for each row execute function last_updated();


-- public.category definition

-- Drop table

-- DROP TABLE category;

CREATE TABLE category (
	category_id serial4 NOT NULL,
	"name" varchar(25) NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT category_pkey PRIMARY KEY (category_id)
);

-- Table Triggers

create trigger last_updated before
update
    on
    public.category for each row execute function last_updated();


-- public.country definition

-- Drop table

-- DROP TABLE country;

CREATE TABLE country (
	country_id serial4 NOT NULL,
	country varchar(50) NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT country_pkey PRIMARY KEY (country_id)
);

-- Table Triggers

create trigger last_updated before
update
    on
    public.country for each row execute function last_updated();


-- public."language" definition

-- Drop table

-- DROP TABLE "language";

CREATE TABLE "language" (
	language_id serial4 NOT NULL,
	"name" bpchar(20) NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT language_pkey PRIMARY KEY (language_id)
);

-- Table Triggers

create trigger last_updated before
update
    on
    public.language for each row execute function last_updated();


-- public.city definition

-- Drop table

-- DROP TABLE city;

CREATE TABLE city (
	city_id serial4 NOT NULL,
	city varchar(50) NOT NULL,
	country_id int2 NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT city_pkey PRIMARY KEY (city_id),
	CONSTRAINT fk_city FOREIGN KEY (country_id) REFERENCES country(country_id)
);
CREATE INDEX idx_fk_country_id ON public.city USING btree (country_id);

-- Table Triggers

create trigger last_updated before
update
    on
    public.city for each row execute function last_updated();


-- public.film definition

-- Drop table

-- DROP TABLE film;

CREATE TABLE film (
	film_id serial4 NOT NULL,
	title varchar(255) NOT NULL,
	description text NULL,
	release_year public."year" NULL,
	language_id int2 NOT NULL,
	rental_duration int2 DEFAULT 3 NOT NULL,
	rental_rate numeric(4, 2) DEFAULT 4.99 NOT NULL,
	length int2 NULL,
	replacement_cost numeric(5, 2) DEFAULT 19.99 NOT NULL,
	rating public."mpaa_rating" DEFAULT 'G'::mpaa_rating NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	special_features _text NULL,
	fulltext tsvector NOT NULL,
	CONSTRAINT film_pkey PRIMARY KEY (film_id),
	CONSTRAINT film_language_id_fkey FOREIGN KEY (language_id) REFERENCES "language"(language_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX film_fulltext_idx ON public.film USING gist (fulltext);
CREATE INDEX idx_fk_language_id ON public.film USING btree (language_id);
CREATE INDEX idx_title ON public.film USING btree (title);

-- Table Triggers

create trigger film_fulltext_trigger before
insert
    or
update
    on
    public.film for each row execute function tsvector_update_trigger('fulltext',
    'pg_catalog.english',
    'title',
    'description');
create trigger last_updated before
update
    on
    public.film for each row execute function last_updated();


-- public.film_actor definition

-- Drop table

-- DROP TABLE film_actor;

CREATE TABLE film_actor (
	actor_id int2 NOT NULL,
	film_id int2 NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT film_actor_pkey PRIMARY KEY (actor_id, film_id),
	CONSTRAINT film_actor_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES actor(actor_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT film_actor_film_id_fkey FOREIGN KEY (film_id) REFERENCES film(film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_film_id ON public.film_actor USING btree (film_id);

-- Table Triggers

create trigger last_updated before
update
    on
    public.film_actor for each row execute function last_updated();


-- public.film_category definition

-- Drop table

-- DROP TABLE film_category;

CREATE TABLE film_category (
	film_id int2 NOT NULL,
	category_id int2 NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT film_category_pkey PRIMARY KEY (film_id, category_id),
	CONSTRAINT film_category_category_id_fkey FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT film_category_film_id_fkey FOREIGN KEY (film_id) REFERENCES film(film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Table Triggers

create trigger last_updated before
update
    on
    public.film_category for each row execute function last_updated();


-- public.inventory definition

-- Drop table

-- DROP TABLE inventory;

CREATE TABLE inventory (
	inventory_id serial4 NOT NULL,
	film_id int2 NOT NULL,
	store_id int2 NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT inventory_pkey PRIMARY KEY (inventory_id),
	CONSTRAINT inventory_film_id_fkey FOREIGN KEY (film_id) REFERENCES film(film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_store_id_film_id ON public.inventory USING btree (store_id, film_id);

-- Table Triggers

create trigger last_updated before
update
    on
    public.inventory for each row execute function last_updated();


-- public.address definition

-- Drop table

-- DROP TABLE address;

CREATE TABLE address (
	address_id serial4 NOT NULL,
	address varchar(50) NOT NULL,
	address2 varchar(50) NULL,
	district varchar(20) NOT NULL,
	city_id int2 NOT NULL,
	postal_code varchar(10) NULL,
	phone varchar(20) NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT address_pkey PRIMARY KEY (address_id),
	CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);
CREATE INDEX idx_fk_city_id ON public.address USING btree (city_id);

-- Table Triggers

create trigger last_updated before
update
    on
    public.address for each row execute function last_updated();


-- public.customer definition

-- Drop table

-- DROP TABLE customer;

CREATE TABLE customer (
	customer_id serial4 NOT NULL,
	store_id int2 NOT NULL,
	first_name varchar(45) NOT NULL,
	last_name varchar(45) NOT NULL,
	email varchar(50) NULL,
	address_id int2 NOT NULL,
	activebool bool DEFAULT true NOT NULL,
	create_date date DEFAULT 'now'::text::date NOT NULL,
	last_update timestamp DEFAULT now() NULL,
	active int4 NULL,
	CONSTRAINT customer_pkey PRIMARY KEY (customer_id),
	CONSTRAINT customer_address_id_fkey FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_address_id ON public.customer USING btree (address_id);
CREATE INDEX idx_fk_store_id ON public.customer USING btree (store_id);
CREATE INDEX idx_last_name ON public.customer USING btree (last_name);

-- Table Triggers

create trigger last_updated before
update
    on
    public.customer for each row execute function last_updated();


-- public.staff definition

-- Drop table

-- DROP TABLE staff;

CREATE TABLE staff (
	staff_id serial4 NOT NULL,
	first_name varchar(45) NOT NULL,
	last_name varchar(45) NOT NULL,
	address_id int2 NOT NULL,
	email varchar(50) NULL,
	store_id int2 NOT NULL,
	active bool DEFAULT true NOT NULL,
	username varchar(16) NOT NULL,
	"password" varchar(40) NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	picture bytea NULL,
	CONSTRAINT staff_pkey PRIMARY KEY (staff_id),
	CONSTRAINT staff_address_id_fkey FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Table Triggers

create trigger last_updated before
update
    on
    public.staff for each row execute function last_updated();


-- public.store definition

-- Drop table

-- DROP TABLE store;

CREATE TABLE store (
	store_id serial4 NOT NULL,
	manager_staff_id int2 NOT NULL,
	address_id int2 NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT store_pkey PRIMARY KEY (store_id),
	CONSTRAINT store_address_id_fkey FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT store_manager_staff_id_fkey FOREIGN KEY (manager_staff_id) REFERENCES staff(staff_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE UNIQUE INDEX idx_unq_manager_staff_id ON public.store USING btree (manager_staff_id);

-- Table Triggers

create trigger last_updated before
update
    on
    public.store for each row execute function last_updated();


-- public.rental definition

-- Drop table

-- DROP TABLE rental;

CREATE TABLE rental (
	rental_id serial4 NOT NULL,
	rental_date timestamp NOT NULL,
	inventory_id int4 NOT NULL,
	customer_id int2 NOT NULL,
	return_date timestamp NULL,
	staff_id int2 NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT rental_pkey PRIMARY KEY (rental_id),
	CONSTRAINT rental_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT rental_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT rental_staff_id_key FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);
CREATE INDEX idx_fk_inventory_id ON public.rental USING btree (inventory_id);
CREATE UNIQUE INDEX idx_unq_rental_rental_date_inventory_id_customer_id ON public.rental USING btree (rental_date, inventory_id, customer_id);

-- Table Triggers

create trigger last_updated before
update
    on
    public.rental for each row execute function last_updated();


-- public.payment definition

-- Drop table

-- DROP TABLE payment;

CREATE TABLE payment (
	payment_id serial4 NOT NULL,
	customer_id int2 NOT NULL,
	staff_id int2 NOT NULL,
	rental_id int4 NOT NULL,
	amount numeric(5, 2) NOT NULL,
	payment_date timestamp NOT NULL,
	CONSTRAINT payment_pkey PRIMARY KEY (payment_id),
	CONSTRAINT payment_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT payment_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES rental(rental_id) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT payment_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_customer_id ON public.payment USING btree (customer_id);
CREATE INDEX idx_fk_rental_id ON public.payment USING btree (rental_id);
CREATE INDEX idx_fk_staff_id ON public.payment USING btree (staff_id);


-- public.actor_info source

CREATE OR REPLACE VIEW public.actor_info
AS SELECT a.actor_id,
    a.first_name,
    a.last_name,
    group_concat(DISTINCT (c.name::text || ': '::text) || (( SELECT group_concat(f.title::text) AS group_concat
           FROM film f
             JOIN film_category fc_1 ON f.film_id = fc_1.film_id
             JOIN film_actor fa_1 ON f.film_id = fa_1.film_id
          WHERE fc_1.category_id = c.category_id AND fa_1.actor_id = a.actor_id
          GROUP BY fa_1.actor_id))) AS film_info
   FROM actor a
     LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
     LEFT JOIN film_category fc ON fa.film_id = fc.film_id
     LEFT JOIN category c ON fc.category_id = c.category_id
  GROUP BY a.actor_id, a.first_name, a.last_name;


-- public.customer_list source

CREATE OR REPLACE VIEW public.customer_list
AS SELECT cu.customer_id AS id,
    (cu.first_name::text || ' '::text) || cu.last_name::text AS name,
    a.address,
    a.postal_code AS "zip code",
    a.phone,
    city.city,
    country.country,
        CASE
            WHEN cu.activebool THEN 'active'::text
            ELSE ''::text
        END AS notes,
    cu.store_id AS sid
   FROM customer cu
     JOIN address a ON cu.address_id = a.address_id
     JOIN city ON a.city_id = city.city_id
     JOIN country ON city.country_id = country.country_id;


-- public.film_list source

CREATE OR REPLACE VIEW public.film_list
AS SELECT film.film_id AS fid,
    film.title,
    film.description,
    category.name AS category,
    film.rental_rate AS price,
    film.length,
    film.rating,
    group_concat((actor.first_name::text || ' '::text) || actor.last_name::text) AS actors
   FROM category
     LEFT JOIN film_category ON category.category_id = film_category.category_id
     LEFT JOIN film ON film_category.film_id = film.film_id
     JOIN film_actor ON film.film_id = film_actor.film_id
     JOIN actor ON film_actor.actor_id = actor.actor_id
  GROUP BY film.film_id, film.title, film.description, category.name, film.rental_rate, film.length, film.rating;


-- public.nicer_but_slower_film_list source

CREATE OR REPLACE VIEW public.nicer_but_slower_film_list
AS SELECT film.film_id AS fid,
    film.title,
    film.description,
    category.name AS category,
    film.rental_rate AS price,
    film.length,
    film.rating,
    group_concat(((upper("substring"(actor.first_name::text, 1, 1)) || lower("substring"(actor.first_name::text, 2))) || upper("substring"(actor.last_name::text, 1, 1))) || lower("substring"(actor.last_name::text, 2))) AS actors
   FROM category
     LEFT JOIN film_category ON category.category_id = film_category.category_id
     LEFT JOIN film ON film_category.film_id = film.film_id
     JOIN film_actor ON film.film_id = film_actor.film_id
     JOIN actor ON film_actor.actor_id = actor.actor_id
  GROUP BY film.film_id, film.title, film.description, category.name, film.rental_rate, film.length, film.rating;


-- public.sales_by_film_category source

CREATE OR REPLACE VIEW public.sales_by_film_category
AS SELECT c.name AS category,
    sum(p.amount) AS total_sales
   FROM payment p
     JOIN rental r ON p.rental_id = r.rental_id
     JOIN inventory i ON r.inventory_id = i.inventory_id
     JOIN film f ON i.film_id = f.film_id
     JOIN film_category fc ON f.film_id = fc.film_id
     JOIN category c ON fc.category_id = c.category_id
  GROUP BY c.name
  ORDER BY (sum(p.amount)) DESC;


-- public.sales_by_store source

CREATE OR REPLACE VIEW public.sales_by_store
AS SELECT (c.city::text || ','::text) || cy.country::text AS store,
    (m.first_name::text || ' '::text) || m.last_name::text AS manager,
    sum(p.amount) AS total_sales
   FROM payment p
     JOIN rental r ON p.rental_id = r.rental_id
     JOIN inventory i ON r.inventory_id = i.inventory_id
     JOIN store s ON i.store_id = s.store_id
     JOIN address a ON s.address_id = a.address_id
     JOIN city c ON a.city_id = c.city_id
     JOIN country cy ON c.country_id = cy.country_id
     JOIN staff m ON s.manager_staff_id = m.staff_id
  GROUP BY cy.country, c.city, s.store_id, m.first_name, m.last_name
  ORDER BY cy.country, c.city;


-- public.staff_list source

CREATE OR REPLACE VIEW public.staff_list
AS SELECT s.staff_id AS id,
    (s.first_name::text || ' '::text) || s.last_name::text AS name,
    a.address,
    a.postal_code AS "zip code",
    a.phone,
    city.city,
    country.country,
    s.store_id AS sid
   FROM staff s
     JOIN address a ON s.address_id = a.address_id
     JOIN city ON a.city_id = city.city_id
     JOIN country ON city.country_id = country.country_id;



-- DROP FUNCTION public."_group_concat"(text, text);

CREATE OR REPLACE FUNCTION public._group_concat(text, text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
SELECT CASE
  WHEN $2 IS NULL THEN $1
  WHEN $1 IS NULL THEN $2
  ELSE $1 || ', ' || $2
END
$function$
;

-- DROP FUNCTION public.film_in_stock(in int4, in int4, out int4);

CREATE OR REPLACE FUNCTION public.film_in_stock(p_film_id integer, p_store_id integer, OUT p_film_count integer)
 RETURNS SETOF integer
 LANGUAGE sql
AS $function$
     SELECT inventory_id
     FROM inventory
     WHERE film_id = $1
     AND store_id = $2
     AND inventory_in_stock(inventory_id);
$function$
;

-- DROP FUNCTION public.film_not_in_stock(in int4, in int4, out int4);

CREATE OR REPLACE FUNCTION public.film_not_in_stock(p_film_id integer, p_store_id integer, OUT p_film_count integer)
 RETURNS SETOF integer
 LANGUAGE sql
AS $function$
    SELECT inventory_id
    FROM inventory
    WHERE film_id = $1
    AND store_id = $2
    AND NOT inventory_in_stock(inventory_id);
$function$
;

-- DROP FUNCTION public.get_customer_balance(int4, timestamp);

CREATE OR REPLACE FUNCTION public.get_customer_balance(p_customer_id integer, p_effective_date timestamp without time zone)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
       --#OK, WE NEED TO CALCULATE THE CURRENT BALANCE GIVEN A CUSTOMER_ID AND A DATE
       --#THAT WE WANT THE BALANCE TO BE EFFECTIVE FOR. THE BALANCE IS:
       --#   1) RENTAL FEES FOR ALL PREVIOUS RENTALS
       --#   2) ONE DOLLAR FOR EVERY DAY THE PREVIOUS RENTALS ARE OVERDUE
       --#   3) IF A FILM IS MORE THAN RENTAL_DURATION * 2 OVERDUE, CHARGE THE REPLACEMENT_COST
       --#   4) SUBTRACT ALL PAYMENTS MADE BEFORE THE DATE SPECIFIED
DECLARE
    v_rentfees DECIMAL(5,2); --#FEES PAID TO RENT THE VIDEOS INITIALLY
    v_overfees INTEGER;      --#LATE FEES FOR PRIOR RENTALS
    v_payments DECIMAL(5,2); --#SUM OF PAYMENTS MADE PREVIOUSLY
BEGIN
    SELECT COALESCE(SUM(film.rental_rate),0) INTO v_rentfees
    FROM film, inventory, rental
    WHERE film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_date <= p_effective_date
      AND rental.customer_id = p_customer_id;

    SELECT COALESCE(SUM(IF((rental.return_date - rental.rental_date) > (film.rental_duration * '1 day'::interval),
        ((rental.return_date - rental.rental_date) - (film.rental_duration * '1 day'::interval)),0)),0) INTO v_overfees
    FROM rental, inventory, film
    WHERE film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_date <= p_effective_date
      AND rental.customer_id = p_customer_id;

    SELECT COALESCE(SUM(payment.amount),0) INTO v_payments
    FROM payment
    WHERE payment.payment_date <= p_effective_date
    AND payment.customer_id = p_customer_id;

    RETURN v_rentfees + v_overfees - v_payments;
END
$function$
;

-- DROP AGGREGATE public.group_concat(text);

CREATE OR REPLACE AGGREGATE public.group_concat(pg_catalog.text) (
	SFUNC = _group_concat,
	STYPE = text
);

-- DROP FUNCTION public.inventory_held_by_customer(int4);

CREATE OR REPLACE FUNCTION public.inventory_held_by_customer(p_inventory_id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_customer_id INTEGER;
BEGIN

  SELECT customer_id INTO v_customer_id
  FROM rental
  WHERE return_date IS NULL
  AND inventory_id = p_inventory_id;

  RETURN v_customer_id;
END $function$
;

-- DROP FUNCTION public.inventory_in_stock(int4);

CREATE OR REPLACE FUNCTION public.inventory_in_stock(p_inventory_id integer)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_rentals INTEGER;
    v_out     INTEGER;
BEGIN
    -- AN ITEM IS IN-STOCK IF THERE ARE EITHER NO ROWS IN THE rental TABLE
    -- FOR THE ITEM OR ALL ROWS HAVE return_date POPULATED

    SELECT count(*) INTO v_rentals
    FROM rental
    WHERE inventory_id = p_inventory_id;

    IF v_rentals = 0 THEN
      RETURN TRUE;
    END IF;

    SELECT COUNT(rental_id) INTO v_out
    FROM inventory LEFT JOIN rental USING(inventory_id)
    WHERE inventory.inventory_id = p_inventory_id
    AND rental.return_date IS NULL;

    IF v_out > 0 THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
END $function$
;

-- DROP FUNCTION public.last_day(timestamp);

CREATE OR REPLACE FUNCTION public.last_day(timestamp without time zone)
 RETURNS date
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
  SELECT CASE
    WHEN EXTRACT(MONTH FROM $1) = 12 THEN
      (((EXTRACT(YEAR FROM $1) + 1) operator(pg_catalog.||) '-01-01')::date - INTERVAL '1 day')::date
    ELSE
      ((EXTRACT(YEAR FROM $1) operator(pg_catalog.||) '-' operator(pg_catalog.||) (EXTRACT(MONTH FROM $1) + 1) operator(pg_catalog.||) '-01')::date - INTERVAL '1 day')::date
    END
$function$
;

-- DROP FUNCTION public.last_updated();

CREATE OR REPLACE FUNCTION public.last_updated()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.last_update = CURRENT_TIMESTAMP;
    RETURN NEW;
END $function$
;

-- DROP FUNCTION public.rewards_report(int4, numeric);

CREATE OR REPLACE FUNCTION public.rewards_report(min_monthly_purchases integer, min_dollar_amount_purchased numeric)
 RETURNS SETOF customer
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    last_month_start DATE;
    last_month_end DATE;
rr RECORD;
tmpSQL TEXT;
BEGIN

    /* Some sanity checks... */
    IF min_monthly_purchases = 0 THEN
        RAISE EXCEPTION 'Minimum monthly purchases parameter must be > 0';
    END IF;
    IF min_dollar_amount_purchased = 0.00 THEN
        RAISE EXCEPTION 'Minimum monthly dollar amount purchased parameter must be > $0.00';
    END IF;

    last_month_start := CURRENT_DATE - '3 month'::interval;
    last_month_start := to_date((extract(YEAR FROM last_month_start) || '-' || extract(MONTH FROM last_month_start) || '-01'),'YYYY-MM-DD');
    last_month_end := LAST_DAY(last_month_start);

    /*
    Create a temporary storage area for Customer IDs.
    */
    CREATE TEMPORARY TABLE tmpCustomer (customer_id INTEGER NOT NULL PRIMARY KEY);

    /*
    Find all customers meeting the monthly purchase requirements
    */

    tmpSQL := 'INSERT INTO tmpCustomer (customer_id)
        SELECT p.customer_id
        FROM payment AS p
        WHERE DATE(p.payment_date) BETWEEN '||quote_literal(last_month_start) ||' AND '|| quote_literal(last_month_end) || '
        GROUP BY customer_id
        HAVING SUM(p.amount) > '|| min_dollar_amount_purchased || '
        AND COUNT(customer_id) > ' ||min_monthly_purchases ;

    EXECUTE tmpSQL;

    /*
    Output ALL customer information of matching rewardees.
    Customize output as needed.
    */
    FOR rr IN EXECUTE 'SELECT c.* FROM tmpCustomer AS t INNER JOIN customer AS c ON t.customer_id = c.customer_id' LOOP
        RETURN NEXT rr;
    END LOOP;

    /* Clean up */
    tmpSQL := 'DROP TABLE tmpCustomer';
    EXECUTE tmpSQL;

RETURN;
END
$function$
;