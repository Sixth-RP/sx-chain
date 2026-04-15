CREATE TABLE IF NOT EXISTS player_chains (
    citizenid VARCHAR(50) NOT NULL,
    chain_name VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (citizenid)
);
