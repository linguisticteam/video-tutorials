START TRANSACTION;

DROP DATABASE IF EXISTS `content_reference_central`;
CREATE DATABASE `content_reference_central`
DEFAULT CHARACTER SET 'utf8'
DEFAULT COLLATE 'utf8_unicode_ci';

USE `content_reference_central`;

/*--------------------------------*/
/*----   TABLES AND INSERTS   ----*/
/*--------------------------------*/

CREATE TABLE `resource` (
	`id` INT AUTO_INCREMENT,
	`resource_type_id` INT REFERENCES `resource_type` (`id`),
	`title` TEXT,
	`description` TEXT,
	PRIMARY KEY (id)
);

CREATE TABLE `element` (
	`id` INT AUTO_INCREMENT,
	`resource_id` INT REFERENCES `resource` (`id`),
	`element_type_id` INT REFERENCES `element_type` (`id`),
	`title` TEXT,
	`index` INT,
	`url` TEXT,
	PRIMARY KEY (id)
);

CREATE TABLE `keyword_xref` (
	`id` INT AUTO_INCREMENT,
	`resource_id` INT REFERENCES `resource` (`id`),
	`keyword_id` INT REFERENCES `keyword` (`id`),
	PRIMARY KEY(id)
);

CREATE TABLE `keyword` (
	`id` INT AUTO_INCREMENT,
	`name` TINYTEXT,
	PRIMARY KEY(id)
);

CREATE TABLE `entity` (
	`id` INT AUTO_INCREMENT,
	`resource_id` INT REFERENCES `resource` (`id`),
	`entity_type_id` INT REFERENCES `entity_type` (`id`),
	`full_name` TEXT,
	PRIMARY KEY (id)
);

CREATE TABLE `entity_type` (
	`id` INT AUTO_INCREMENT,
	`name` TINYTEXT,
	PRIMARY KEY (id)
);

INSERT INTO `entity_type` (name) VALUES
	('PERSON'),
	('ORGANIZATION')
;

CREATE TABLE `resource_type` (
	`id` INT AUTO_INCREMENT,
	`name` TINYTEXT,
	PRIMARY KEY (id)
);

INSERT INTO `resource_type` (name) VALUES
	('TUTORIAL'),
	('DOCUMENTATION')
;

CREATE TABLE `element_type` (
	`id` INT AUTO_INCREMENT,
	`name` TINYTEXT,
	PRIMARY KEY (id)
);

INSERT INTO `element_type` (name) VALUES
	('PRIMARY'),
	('PART'),
	('LESSON'),
	('CHAPTER')
;

/*-------------------*/
/*----   VIEWS   ----*/
/*-------------------*/

/*-------------------------------*/
/*----   STORED PROCEDURES   ----*/
/*-------------------------------*/

DELIMITER $$



/* Stored procedure to insert an single-element resource */
CREATE PROCEDURE insert_resource (IN param_title TEXT, IN param_resource_type TEXT, IN param_url TEXT, IN param_description TEXT)
BEGIN
                INSERT INTO `resource` (
                    `resource_type_id`,
                    `title`,
                    `description`
                )
                VALUES (
                    (SELECT `id` FROM `resource_type` WHERE `name` = param_resource_type),
                    param_title,
                    param_description
                );

                INSERT INTO `element` (
                    `url`
                )
                VALUES (
                    param_url
                );
END $$

/* Stored procedure to check if the keyword is a new one and insert it if so */
CREATE PROCEDURE insert_keyword (IN param_keyword TINYTEXT)
BEGIN
        IF
            (SELECT COUNT(`name`) FROM `keyword` WHERE `name` = param_keyword) = 0
        THEN
            INSERT INTO `keyword` (`name`) VALUES (param_keyword);
        END IF;
END $$

/* Stored procedure to insert into keyword_xref */
CREATE PROCEDURE insert_keyword_xref (IN param_resource_title TEXT, IN param_keyword_name TINYTEXT)
BEGIN
        INSERT INTO `keyword_xref` (
            `resource_id`,
            `keyword_id`)
        VALUES (
        (SELECT `id` FROM `resource` WHERE `title` = param_resource_title),
        (SELECT `id` FROM `keyword` WHERE `name` = param_keyword_name)
        );
END $$


/* Stored procedure to insert an entity */
CREATE PROCEDURE insert_entity (IN param_element_title TEXT, IN param_entity_type_name TINYTEXT, IN param_entity_full_name TEXT)
BEGIN
	INSERT INTO `entity` (
		resource_id,
		entity_type_id,
		full_name) 
	VALUES (
		(SELECT resource_id
			FROM element
			WHERE title = param_element_title),
		(SELECT id
			FROM entity_type
			WHERE name = param_entity_type_name),
	param_entity_full_name
);

END $$

DELIMITER ;

/*---------------------------*/
/*----   DEMONSTRATION   ----*/
/*---------------------------*/

/* Make an entry into the resource table */
INSERT INTO resource (
	resource_type_id,
	description)
VALUES (
	(SELECT id
		FROM resource_type
		WHERE name = 'TUTORIAL'),
	'My description is tasty'
);

/* Make an entry into the element table */
INSERT INTO element (
	`resource_id`,
	`element_type_id`,
	`title`,
	`index`,
	`url`)
VALUES (
	(SELECT MAX(id) 
		FROM resource),
	(SELECT id
		FROM element_type
		WHERE name = 'PRIMARY'),
	'How to database',
	NULL,
	'http://databaseieat.com'
);

CALL insert_entity('How to database','PERSON','My full name');

SELECT
	`id` AS 'ID',
	(SELECT `description`
		FROM `resource`
		WHERE `resource`.`id` LIKE `entity`.`id`) AS 'Description',
	(SELECT `name`
		FROM `entity_type`
		WHERE `entity_type`.`id` LIKE `entity`.`id`) AS 'Entity Type',
	`full_name` AS 'Full Name'
FROM
	`entity`;

COMMIT
