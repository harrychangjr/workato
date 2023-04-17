CREATE TABLE employees (
    emp_no INT(11) PRIMARY KEY,
    birth_date DATE,
    first_name VARCHAR(14),
    last_name VARCHAR(16),
    gender ENUM('M', 'F'),
    hire_date DATE
);

CREATE TABLE titles (
    emp_no INT(11),
    title VARCHAR(39),
    from_date DATE,
    to_date DATE,
    FOREIGN KEY (emp_no) REFERENCES employees(emp_no)
);

CREATE TABLE departments (
    dept_no CHAR(4) PRIMARY KEY,
    dept_name VARCHAR(40) UNIQUE
);

CREATE TABLE dept_emp (
    emp_no INT(11),
    dept_no CHAR(4),
    from_date DATE,
    to_date DATE,
    PRIMARY KEY (emp_no, dept_no),
    FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
    FOREIGN KEY (dept_no) REFERENCES departments(dept_no)
);

CREATE TABLE salaries (
    emp_no INT(11),
    salary INT(11),
    from_date DATE,
    to_date DATE,
    PRIMARY KEY (emp_no, from_date),
    FOREIGN KEY (emp_no) REFERENCES employees(emp_no)
);

CREATE TABLE dept_manager (
    emp_no INT(11),
    dept_no CHAR(4),
    from_date DATE,
    to_date DATE,
    PRIMARY KEY (emp_no, dept_no),
    FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
    FOREIGN KEY (dept_no) REFERENCES departments(dept_no)
);

--List all employees for each department with their first name, last name, emp_no, dept_no & name:
SELECT e.first_name, e.last_name, e.emp_no, d.dept_no, d.dept_name
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no;

-- List all employees where their salary exceeds the salary of their manager
SELECT e.emp_no, e.first_name, e.last_name, e_salary.salary, m_salary.salary AS manager_salary
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN dept_manager dm ON de.dept_no = dm.dept_no AND de.from_date <= dm.to_date AND de.to_date >= dm.from_date
JOIN salaries e_salary ON e.emp_no = e_salary.emp_no
JOIN salaries m_salary ON dm.emp_no = m_salary.emp_no
WHERE e_salary.salary > m_salary.salary AND e_salary.from_date <= m_salary.to_date AND e_salary.to_date >= m_salary.from_date;

-- List highest salaried employees for each department
SELECT e.emp_no, e.first_name, e.last_name, d.dept_no, d.dept_name, s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
WHERE (d.dept_no, s.salary) IN (
    SELECT de.dept_no, MAX(s.salary)
    FROM dept_emp de
    JOIN salaries s ON de.emp_no = s.emp_no
    GROUP BY de.dept_no
);

-- List all employees that don't have a manager
SELECT e.emp_no, e.first_name, e.last_name
FROM employees e
WHERE e.emp_no NOT IN (
    SELECT dm.emp_no
    FROM dept_manager dm
);

-- List all employees who are their own manager
SELECT e.emp_no, e.first_name, e.last_name
FROM employees e
JOIN dept_manager dm ON e.emp_no = dm.emp_no
WHERE e.emp_no = dm.emp_no;

-- List all employees who have been hired prior to their manager
SELECT e.emp_no, e.first_name, e.last_name, e.hire_date, m.emp_no AS manager_emp_no, m.first_name AS manager_first_name, m.last_name AS manager_last_name, m.hire_date AS manager_hire_date
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN dept_manager dm ON de.dept_no = dm.dept_no
JOIN employees m ON dm.emp_no = m.emp_no
WHERE e.hire_date < m.hire_date;
