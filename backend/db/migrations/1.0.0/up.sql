CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    gender INT NOT NULL,
    height INT NOT NULL,
    target_weight DOUBLE NOT NULL,
    daily_water_target DOUBLE NOT NULL
);

INSERT INTO
    users (
        gender,
        height,
        target_weight,
        daily_water_target
    )
VALUES
    (2, 160, 55.0, 2000);

CREATE TABLE weights (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    user_id INT NOT NULL,
    date VARCHAR NOT NULL,
    value DOUBLE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE water_intakes (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    user_id INT NOT NULL,
    date VARCHAR NOT NULL,
    value DOUBLE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE fasting_periods (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    user_id INT NOT NULL,
    start VARCHAR NOT NULL,
    duration INTEGER NOT NULL,
    closed BOOLEAN NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);