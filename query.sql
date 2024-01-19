CREATE SCHEMA pcdb
GO

CREATE TABLE pcdb.price_catcher
(
	date_pc			DATE,
	premise_code	VARCHAR(100),
	premise			VARCHAR(100),
	address			VARCHAR(500),
	premise_type	VARCHAR(100),
	district		VARCHAR(100),
	state			VARCHAR(100),
	item_code		VARCHAR(100),
	item			VARCHAR(100),
	unit			VARCHAR(100),
	price			DECIMAL(10, 2),
	item_group		VARCHAR(100),
	item_category	VARCHAR(100)
)
GO