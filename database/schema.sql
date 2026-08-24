
CREATE TABLE IF NOT EXISTS dim_country(
    country_id INTEGER PRIMARY KEY,
    country_code VARCHAR(3) NOT NULL UNIQUE,
    country_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_indicator(
indicator_id INTEGER PRIMARY KEY,
indicator_code VARCHAR(50) NOT NULL UNIQUE,
indicator_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS fact_observation(
observation_id INTEGER PRIMARY KEY,

country_id INTEGER NOT NULL,
indicator_id INTEGER NOT NULL,

year INTEGER NOT NULL,
value REAL,

FOREIGN KEY(country_id)
   REFERENCES dim_country(country_id),

FOREIGN KEY(indicator_id)
   REFERENCES dim_indicator(indicator)id),

UNIQUE(
   country_id,
   indicator_id,
   year)

);



