CREATE TABLE IF NOT EXISTS india_population (state VARCHAR NOT NULL,city VARCHAR NOT NULL,population BIGINT CONSTRAINT india_population_pk PRIMARY KEY (state, city));
