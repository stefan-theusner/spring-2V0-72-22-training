INSERT INTO card_kind (id, name, hint) VALUES (1, 'Annotation', 'ann');
INSERT INTO card_kind (id, name, hint) VALUES (2, 'Starter', 'sta');

INSERT INTO card_category (id, code, name) VALUES (10, 'AOP', 'AOP');
INSERT INTO card_category (id, code, name) VALUES (20, 'JPA', 'JPA & Spring Data');

INSERT INTO card (id, name, kind_id, category_id, description, example_code, info_tables, source_url)
VALUES (100, 'Card A', 1, 10, 'Desc A', 'code A', JSON '[]', 'http://a');
INSERT INTO card (id, name, kind_id, category_id, description, example_code, info_tables, source_url)
VALUES (101, 'Card B', 1, 20, 'Desc B', null, JSON '[]', null);
INSERT INTO card (id, name, kind_id, category_id, description, example_code, info_tables, source_url)
VALUES (102, 'Card C', 2, 10, 'Desc C', null, JSON '[]', null);

ALTER TABLE card ALTER COLUMN id RESTART WITH 200;
ALTER TABLE card_kind ALTER COLUMN id RESTART WITH 10;
ALTER TABLE card_category ALTER COLUMN id RESTART WITH 30;
