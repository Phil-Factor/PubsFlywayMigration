
CREATE TABLE EditionType (TheType NVARCHAR(20) CONSTRAINT pk_EditionType PRIMARY KEY);
INSERT INTO EditionType (TheType)
  SELECT type
    FROM (VALUES ('Book'), ('AudioBook'), ('Map'), ('Hardback'),
          ('Paperback'), ('Calendar'), ('Ebook')
         ) f (type);

CREATE TABLE dbo.publications
  (
  --Title_id AS publication_id, pub_id, title ,notes
  Publication_id dbo.tid NOT NULL CONSTRAINT PK_Publication PRIMARY KEY,
  title VARCHAR(80)  NOT NULL,
  pub_id CHAR(8)  NULL CONSTRAINT fkPublishers REFERENCES dbo.publishers,
  notes VARCHAR(200)  NULL,
  pubdate DATETIME NOT NULL
    CONSTRAINT pub_NowDefault DEFAULT (GetDate())
  ) ON [PRIMARY];
GO

CREATE TABLE dbo.editions
  (
  Edition_id INT IDENTITY(1, 1) CONSTRAINT PK_editions PRIMARY KEY,
  publication_id dbo.tid CONSTRAINT fk_edition REFERENCES publications,
  Publication_type NVARCHAR(20) NOT NULL --
    CONSTRAINT FK_EditionType FOREIGN KEY (fk_Publication_type) --
    REFERENCES dbo.EditionType  (TheType),
  EditionDate DATETIME2 NOT NULL DEFAULT GetDate()
  );
GO

CREATE TABLE dbo.prices
  (
  Price_id INT IDENTITY(1, 1) CONSTRAINT PK_Prices PRIMARY KEY,
  Edition_id INT CONSTRAINT fk_prices REFERENCES editions,
  price dbo.Dollars NULL,
  advance dbo.Dollars NULL,
  royalty INT NULL,
  ytd_sales INT NULL,
  PriceStartDate DATETIME2 NOT NULL DEFAULT GetDate(),
  PriceEndDate DATETIME2 NULL
  );
GO

CREATE TABLE dbo.Limbo
  (
  Soul_ID INT IDENTITY(1, 1),
  JSON NVARCHAR(MAX) NOT null,
  Version NOT NULL NVARCHAR(20),
  SourceName NOT NULL sysname,
  InsertionDate DATETIME2 NOT NULL DEFAULT GetDate()
  );

/* do the necessary data migrations.First store the old table */
IF not EXISTS (SELECT name FROM tempdb.sys.tables WHERE name LIKE '#titles%')
SELECT title_id, title, pub_id, price, advance, royalty, ytd_sales, notes,
  pubdate
  INTO #titles
  FROM titles;

INSERT INTO publications (Publication_id, title, pub_id, notes, pubdate)
  SELECT title_id, title, pub_id, notes, pubdate FROM #titles;

INSERT INTO editions (publication_id, Publication_type, EditionDate)
  SELECT title_id, 'book', pubdate FROM #titles;

INSERT INTO dbo.prices (Edition_id, price, advance, royalty, ytd_sales,
PriceStartDate, PriceEndDate)
  SELECT Edition_id, price, advance, royalty, ytd_sales, pubdate, NULL
    FROM #titles t
      INNER JOIN editions
        ON t.title_id = editions.publication_id;

