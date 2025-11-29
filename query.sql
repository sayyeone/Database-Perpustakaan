
--BASIC QUERY
--1. Members from 'Bandung' older than 25 and active
SELECT book_id, isbn, title, author, publisher, publication_year, stock, price
FROM books
WHERE isbn LIKE '978-71%'
   OR isbn = '978-8250396675';

--JOIN QUERY
--1. Overdue transactions since 2023-01-01 with fines greater than 20000, sorted by fine amount descending
SELECT t.transaction_id, m.name, b.title, 
       t.borrow_date, t.due_date, t.fine_amount
FROM transactions t
JOIN members m ON t.member_id = m.member_id
JOIN books b ON t.book_id = b.book_id
WHERE t.status = 'overdue'
  AND t.borrow_date >= '2023-01-01'
  AND t.fine_amount > 20000
ORDER BY t.fine_amount DESC;


--AGGREGATE & CONDITIONAL QUERY
-- 1. Harga tertinggi dan terendah dari semua buku
SELECT 
    MAX(price) AS harga_tertinggi,
    MIN(price) AS harga_terendah
FROM books;

-- 2. Rata-rata denda dari transaksi yang sudah dikembalikan
SELECT c.category_name, COUNT(b.book_id) AS jumlah_buku
FROM categories c
LEFT JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_id;

-- OPTIMIZED INDEXING STRATEGY
-- 1. Index untuk Query 1: Members Search
CREATE INDEX idx_members_search 
ON members(city, age, status) 
USING BTREE
COMMENT 'Composite index untuk pencarian members berdasarkan city, age, status';

-- 2. Index untuk Query 2: Books Author Search (FULLTEXT)
CREATE FULLTEXT INDEX idx_books_author_fulltext 
ON books(author)
COMMENT 'FULLTEXT index untuk text search pada author dengan wildcard';

-- 3. Index untuk Query 2: Books Availability
CREATE INDEX idx_books_availability 
ON books(publication_year, stock) 
USING BTREE
COMMENT 'Composite index untuk filter tahun publikasi dan ketersediaan stock';

-- 4. Index untuk Query 3: Transactions Overdue
CREATE INDEX idx_transactions_overdue 
ON transactions(status, borrow_date, fine_amount) 
USING BTREE
COMMENT 'Composite index untuk filter status, tanggal, dan sorting denda';

-- QUERY 1: Members Search
EXPLAIN ANALYZE
SELECT member_id, nim, name, city, age, email, status
FROM members
WHERE city = 'Bandung' 
  AND age > 25
  AND status = 'active';

-- QUERY 2: Books Author Search (FULLTEXT)
EXPLAIN ANALYZE
SELECT book_id, isbn, title, author, publication_year, stock, price
FROM books
WHERE MATCH(author) AGAINST('Muhammad' IN NATURAL LANGUAGE MODE)
  AND publication_year >= 2010
  AND stock > 0;

-- QUERY 3: Transactions Overdue
EXPLAIN ANALYZE
SELECT transaction_id, member_id, book_id, borrow_date, due_date, fine_amount
FROM transactions
WHERE status = 'overdue'
  AND borrow_date >= '2023-01-01'
ORDER BY fine_amount DESC;

--END OF FILE