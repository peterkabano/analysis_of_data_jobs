
/*-- Problem 1 --
Get job details for BOTH 'Data analyst' or 'Business analyst' positions
	for 'Data analyst' I want jobs only > 100000
	for 'Business analyst' I want jobs > 70000
Only include jobs located in either:
	boston
	anywhere
*/

FROM
	job_postings_fact
WHERE
	job_location IN ('Boston, MA', 'Anywhere')
    
    AND
    
	(
     	(job_title_short = 'Data Analyst' AND salary_year_avg > 100000) OR 
     	(job_title_short = 'Business Analyst' AND salary_year_avg > 70000)
    )
    ;



/*
-- Problem 2 --
Look for non-senior data analyst or business analyst roles
Get the job title, location, and average yearly salary
*/


SELECT
	job_title,
	job_location as location,
	salary_year_avg AS salary
FROM
	job_postings_fact
WHERE
	(job_title LIKE '%Data%' OR job_title = '%Business%') AND
	job_title LIKE '%Analyst%' AND
	job_title NOT LIKE '%Senior%';

/*
-- Practice problem 3 
Calculate the current month's total earnings (hours_spent * hours_rate) per project 
Calculate a scenario where the hourly rate increases by 5
*/

SELECT
    project_id,
    SUM(hours_spent * hours_rate) AS project_original_cost,
    SUM(hours_spent * (hours_rate + 5)) AS project_scenario_cost
FROM
    invoices_fact
GROUP BY
    project_id,
    
/*
--  Practice problem 5
Find the average salary and number of job positngs for each skill for this:
Hint: Use LEFT JOIN to combine skills_dim, skill_job_dim, and job_postings_fact tables
*/

SELECT
   T2.skills AS skill_name,
   COUNT(T3.job_id) AS job_counts,
   AVG(T1.salary_year_avg) AS avg_salary
FROM
    skills_job_dim AS T3
LEFT JOIN 
    skills_dim AS T2
        ON T3.skill_id = T2.skill_id
LEFT JOIN
	job_postings_fact AS T1
    	ON T3.job_id = T1.job_id
GROUP BY
	skill_name
ORDER BY
	job_counts DESC


/*
--  Practice problems 6
Create a table from other tables
	create three tables
		jan
		feb
		march
*/
-- jan [method 1 (CREATE A TABLE)]
CREATE TABLE january_jobs AS 
SELECT
	*
FROM
	job_postings_fact
WHERE
	EXTRACT(MONTH FROM job_posted_date) = 1;

-- feb [method 2 (copy INTO)]
SELECT
	*
INTO february_jobs
FROM
	job_postings_fact
WHERE
	EXTRACT(MONTH FROM job_posted_date) = 2;


-- march [method 1]
CREATE TABLE march_jobs AS 
SELECT
	*
FROM
	job_postings_fact
WHERE
	EXTRACT(MONTH FROM job_posted_date) = 3;


/*
-- Practice problem 7 
Find the count of the number of remote job postings per skill
	- Display the top 5 skills by their demand in remote jobs
	- Include skill ID, name, and count of postings requiring the skill
*/


WITH remote_job_skills AS (
    SELECT
        skill_id,
        COUNT(*) AS skill_count
    FROM
        skills_job_dim AS skills_to_job
    INNER JOIN 
        job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
    WHERE
        job_postings.job_work_from_home = True
    GROUP BY
        skill_id
)
SELECT
    skills.skill_id,
    skills as skill_name,
    skill_count
FROM
    remote_job_skills
INNER JOIN
    skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC


/*
-- Practice Problem 8
Find job positngs from the first quarter that have a salary greater than 70k
- Combine job posting tables from the first quarter of 2023 (Jan - Mar)
- Gets job postings with an average yearly salary > 70 k
*/

SELECT
	quarter1_job_postings.job_title_short,
	quarter1_job_postings.job_location,
	quarter1_job_postings.job_via,
	quarter1_job_postings.job_posted_date::DATE,
	quarter1_job_postings.salary_year_avg
FROM (
	SELECT *
	FROM january_jobs
	UNION ALL
	SELECT *
	FROM february_jobs
	UNION ALL
	SELECT *
	FROM march_jobs
	) AS quarter1_job_postings
WHERE
	quarter1_job_postings.salary_year_avg > 70000


SELECT * FROM january_jobs LIMIT 2

/*
-- Project problem
Goals
1. What are the top paying jobs for my role?
2. What are the skills required for these top-paying roles?
3. What are the most in-demand skills for my role?
4. What are the top skills based on salary for my role?
5. What are the most optimal skills to learn?
*/

