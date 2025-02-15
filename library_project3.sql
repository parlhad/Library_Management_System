 --Create Table Branch
 DROP TABLE IF EXISTS branch;
  CREATE TABLE branch
  ( 
  	branch_id VARCHAR(15) PRIMARY KEY,
	manager_id VARCHAR(15),
	branch_address VARCHAR(50),
	contact_no VARCHAR(15)
 );

 SELECT*FROM branch

 DROP TABLE IF EXISTS employees;
  CREATE TABLE employees(
  	emp_id VARCHAR(15) PRIMARY KEY,
	emp_name VARCHAR(25),
	position VARCHAR(25),
	salary INT,
	branch_id VARCHAR(15)--fk
);

DROP TABLE IF EXISTS books;
  CREATE TABLE books
  (
	isbn VARCHAR(20) PRIMARY KEY,
	book_title VARCHAR(80),
	category VARCHAR(20),
	rental_price FLOAT,
	status VARCHAR(15),
	author VARCHAR(40),
	publisher VARCHAR(40)
);

DROP TABLE IF EXISTS members;
  CREATE TABLE members
  (
  	member_id VARCHAR(15) PRIMARY KEY,
	member_name VARCHAR(25),
	member_address VARCHAR(75),
	reg_date DATE
	);

	DROP TABLE IF EXISTS issued_status;
  CREATE TABLE issued_status
  (
	issued_id VARCHAR(15) PRIMARY KEY,
	issued_member_id VARCHAR(15),--fk
	issued_book_name VARCHAR(75),
	issued_date DATE,
	issued_book_isbn VARCHAR(50),--fk
	issued_emp_id VARCHAR(15)--fk
	);

	DROP TABLE IF EXISTS return_status;
  CREATE TABLE return_status
  (
	return_id VARCHAR(15) PRIMARY KEY,
	issued_id VARCHAR(15),
	return_book_name VARCHAR(75),
	return_date DATE,
	return_book_isbn VARCHAR(30)
	);

-- ADD FOREIGN KEY

		ALTER TABLE issued_status
		ADD CONSTRAINT fk_members
		FOREIGN KEY (issued_member_id)
		REFERENCES members(member_id);

		ALTER TABLE issued_status
		ADD CONSTRAINT fk_books
		FOREIGN KEY (issued_book_isbn)
		REFERENCES books(isbn);

		ALTER TABLE issued_status
		ADD CONSTRAINT fk_employees
		FOREIGN KEY (issued_emp_id)
		REFERENCES employees(emp_id);

		ALTER TABLE employees
		ADD CONSTRAINT fk_branch
		FOREIGN KEY (branch_id)
		REFERENCES branch(branch_id);

		ALTER TABLE employees
		ADD CONSTRAINT fk_branch
		FOREIGN KEY (branch_id)
		REFERENCES branch(branch_id);

      ALTER TABLE return_status
		ADD CONSTRAINT fk_issued_status
		FOREIGN KEY (issued_id)
		REFERENCES issued_status(issued_id);

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;

--PROJECT SOLVE
--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

	INSERT INTO books(isbn,book_title,category,rental_price,status,author,publisher)
	VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

--Task 2: Update an Existing Member's Address
		
		UPDATE members
    SET member_address = '125 Oak St'
   WHERE member_id = 'C103';
		SELECT * FROM members;

--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

 DELETE FROM issued_status
 WHERE issued_id = 'IS121';
 SELECT * FROM issued_status;

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

		SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

--Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
		
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1

--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

 CREATE TABLE book_counts--(CAS):- Crate table AS so we can run any time and new added or deleted all details showd 
 AS
SELECT 
 b.isbn,b.book_title,
 COUNT(ist.issued_book_isbn)
 FROM books b
 JOIN
 issued_status ist
 ON ist.issued_book_isbn=b.isbn
 GROUP BY  b.isbn,b.book_title;

 SELECT * FROM book_counts;

--Task 7. Retrieve All Books in a Specific Category:
 	
	 SELECT* FROM books -- this is for all category and books 
	 SELECT DISTINCT(category),book_title FROM books;

	  SELECT* FROM books -- this is for Specific category and books 
	WHERE category='Classic';

--Task 8: Find Total Rental Income by Category: 

	 SELECT category,
	 SUM(rental_price),
	 COUNT(*)
	 FROM books b
	 JOIN
 	issued_status ist
	 ON ist.issued_book_isbn=b.isbn
	 GROUP BY 1;
	 
-- task 9 List Members Who Registered in the Last 180 Days:
  
		 SELECT * FROM members
		 WHERE reg_date>= CURRENT_DATE - INTERVAL'180 days';


INSERT INTO members(member_id,member_name,member_address,reg_date)
VALUES('C125','sam kotian','195 Main St','12-02-2025'),
		('126','John Wick','145 Main St','25-12-2024');

-- tsak 10 List Employees with Their Branch Manager's Name and their branch details:

	SELECT e1.*,
			b.manager_id,
			e2.emp_name AS MANEGER
	FROM branch AS b
	JOIN
	employees AS e1
	ON e1.branch_id=b.branch_id
	JOIN 
	employees AS e2
	ON b.manager_id=e2.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 5usd:	

	CREATE TABLE books_price_gretherthan_5 
	AS
	SELECT * FROM books
	WHERE rental_price>5;

	SELECT* FROM books_price_gretherthan_5

--Task 12: Retrieve the List of Books Not Yet Returned

 	SELECT DISTINCT ist.issued_book_name AS not_returend_yet
	 FROM issued_status AS ist
	 LEFT JOIN return_status AS r
	 ON r.issued_id=ist.issued_id
	 WHERE r.return_id IS NULL;


--ADVANCE QUETION
	
  SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;


-- Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, 
--member's name, book title, issue date, and days overdue.

	--issued staatus == memebers == books == return status
	--filter book which are return
	-- overdue > 30

	SELECT ist.issued_member_id,
	m.member_name,
	bk.book_title,
	ist.issued_date,
	CURRENT_DATE-ist.issued_date  AS over_due_days
	FROM issued_status AS ist
	JOIN
	members AS m
	ON ist.issued_member_id = m.member_id
	JOIN 
	books AS bk
	ON ist.issued_book_isbn = bk.isbn
  LEFT JOIN
	return_status AS rs
	ON ist.issued_id = rs.issued_id
	WHERE 
	rs.return_date IS NULL
	AND 
		CURRENT_DATE-ist.issued_date > 30
		ORDER BY ist.issued_member_id ;
/*
Task 14: Update Book Status on ReturnWrite a query to update the status of books in the books table to "Yes" when they are 
returned (based on entries in the return_status table)
*/
		SELECT * FROM issued_status
		WHERE issued_book_isbn='978-0-451-52994-2';


		SELECT * FROM books
		WHERE isbn = '978-0-451-52994-2';

		UPDATE books
		SET status='no'
		WHERE isbn='978-0-451-52994-2';

		SELECT * FROM return_status
		WHERE issued_id='IS130';

		INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
		VALUES('RS125','IS130',CURRENT_DATE,'Good');
		SELECT * FROM return_status
		WHERE issued_id='IS130';

-- store procedure
		 CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10),p_issued_id VARCHAR(15),p_book_quality VARCHAR(15))
			LANGUAGE plpgsql
			AS $$

			DECLARE 
				v_isbn VARCHAR(50);
				v_book_name VARCHAR(80);
			BEGIN
			-- Isert Into returns Based on user input
			INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
		VALUES(p_return_id,p_issued_id,CURRENT_DATE,p_book_quality);
		 
	 SELECT 
	 		issued_book_isbn,
			 issued_book_name
			 INTO
			 v_isbn,
			 v_book_name
			 FROM issued_status
			 WHERE issued_id=p_issued_id;

		UPDATE books
		SET status='yes'
		WHERE isbn=v_isbn;

		RAISE NOTICE 'Thank you for returning book %:',v_book_name;

	END;
	$$

--Testing function add_return_records
--issued_id = IS135
--isbn- WHERE isbn ='978-0-307-58837-1'

SELECT * FROM books
WHERE isbn='978-0-330-25864-8';

UPDATE books
SET status='no'
WHERE isbn='978-0-330-25864-8'

SELECT * FROM issued_status
WHERE issued_book_isbn='978-0-330-25864-8';
--IS140
SELECT * FROM return_status
WHERE issued_id='IS140';

--Caliing FUnctions
	CALL add_return_records('RS138','IS135','Good');
	
-- Calliing function
	CALL add_return_records('RS148','IS140','Good');
/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/
		SELECT * FROM branch;
		
		SELECT * FROM issued_status;

		SELECT * FROM employees;

		SELECT * FROM books;

		SELECT * FROM return_status;


	CREATE TABLE branch_report
	AS
	SELECT 
	b.branch_id,
	b.manager_id,
	COUNT(ist.issued_id) AS NO_Book_Issued,
	COUNT(rs.return_id) AS no_book_return,
	SUM(bk.rental_price) AS total_revenue
	FROM issued_status AS ist
	JOIN 
	employees AS e
	ON ist.issued_emp_id=e.emp_id
	JOIN 
	branch AS b
	ON e.branch_id=b.branch_id
	LEFT JOIN
	return_status AS rs
	ON rs.issued_id=ist.issued_id
	JOIN books AS bk
	ON ist.issued_book_isbn=bk.isbn
	GROUP BY 1,2;

SELECT * FROM branch_report;


/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have 
issued at least one book in the last 2 months.
*/
	CREATE TABLE active_members
	AS
	SELECT * FROM members
	WHERE member_id IN (SELECT 
		DISTINCT issued_member_id
	FROM issued_status
	WHERE 
		issued_date>= CURRENT_DATE - INTERVAL '2 month');

	SELECT * FROM active_members

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/	
	SELECT e.emp_name,
			b.*,
		COUNT(ist.issued_id)AS no_book_issued
		FROM issued_status AS ist
	JOIN 
	employees AS e
	ON e.emp_id = ist.issued_emp_id
	JOIN
	branch AS b
	ON e.branch_id = b.branch_id
	GROUP BY 1,2;

/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" 
in the books table.Display the member name, book title, and the number of times they've issued damaged
books.
*/
 SELECT 
    m.member_name,
    COUNT(rs.issued_id) AS damaged_count
	FROM members AS m
	JOIN issued_status AS ist
	ON ist.issued_member_id = m.member_id
	JOIN return_status AS rs
	ON rs.issued_id = ist.issued_id
	WHERE rs.book_quality = 'Damaged'
	GROUP BY m.member_name
	HAVING COUNT(rs.issued_id) > 2
	ORDER BY damaged_count DESC;

/*Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.

Description: Write a stored procedure that updates the status of a book in the library based on its issuance.

The procedure should function as follows:
 
 The stored procedure should take the book_id as an input parameter.
 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued,and the status in the books table should be updated
to 'no'. If the book is not available
(status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/
 	 SELECT * FROM issued_status

 CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(15),p_issued_member_id VARCHAR(15),p_issued_book_isbn VARCHAR(50)
 ,p_issued_emp_id VARCHAR(15))
 LANGUAGE plpgsql
 AS 
 $$
 
 DECLARE 
v_status VARCHAR(10);

 BEGIN

    -- CHECK BOOK IS AVAILABLE OR NOT 
	SELECT 
		status
		INTO 
		v_status
	FROM books
	WHERE isbn =p_issued_book_isbn;

	IF v_status ='yes' THEN
			INSERT INTO issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
			VALUES(p_issued_id,p_issued_member_id,CURRENT_DATE,p_issued_book_isbn,p_issued_emp_id);
	
			UPDATE books
			SET status = 'no'
			WHERE isbn=p_issued_book_isbn;

			RAISE NOTICE 'Book record added successefully for book isbn : %',p_issued_book_isbn;
	ELSE
		RAISE NOTICE 'Sorry for inform you the book you jave requested thai is unavailable : %',p_issued_book_isbn;
	END IF;
END;
$$


SELECT * FROM books
--978-0-525-47535-5 'yes'
--978-0-7432-7357-1 ' no'
SELECT * FROM issued_status;

CALL issue_book('IS155','C107','978-0-525-47535-5','E104'); --available and issued 

SELECT * FROM books
WHERE isbn = '978-0-525-47535-5';

SELECT * FROM books
WHERE isbn = '978-0-7432-7357-1';

CALL issue_book('IS156','C108','978-0-7432-7357-1','E104');-- not available 


/*
Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query 
to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books they
have issued but not returned within 30 days. 
The table should include: The number of overdue books. The total fines, with each day's fine 
calculated at $0.50. The number of books issued by each member.
The resulting table should show: Member ID Number of overdue books Total fines
*/
	 SELECT 
    ist.issued_member_id,
    CURRENT_DATE - ist.issued_date AS over_due_days,
    CASE 
        WHEN CURRENT_DATE - ist.issued_date > 30 
        THEN (CURRENT_DATE - ist.issued_date - 30) * 0.50
        ELSE 0
    END AS fine
FROM issued_status AS ist
JOIN members AS m
ON ist.issued_member_id = m.member_id
LEFT JOIN return_status AS rs 
ON ist.issued_id = rs.issued_id
WHERE rs.return_date IS NULL  -- Book has not been returned
AND CURRENT_DATE - ist.issued_date > 30  -- Book is overdue
ORDER BY ist.issued_member_id;



--END PROJECT 

