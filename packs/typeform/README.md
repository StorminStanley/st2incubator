Typeform Integration
====================

This integration pack provides a sensor to query a Typeform form for new submissions.

### Prerequisites
In order to track state, it depends on a MySQL database.

```CREATE DATABASE community;

USE community;

CREATE TABLE user_registration(
			id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
			email VARCHAR(255) NOT NULL,
			last_name VARCHAR(32),
			first_name VARCHAR(32),
			source VARCHAR(255),
			newsletter TINYINT UNSIGNED,
			referer VARCHAR(128),
			date_land TIMESTAMP,
			date_submit TIMESTAMP,
			date_invited TIMESTAMP);

ALTER TABLE user_registration ADD UNIQUE(email);```