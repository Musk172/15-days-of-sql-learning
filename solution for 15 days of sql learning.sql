WITH RECURSIVE hacker as 
	(
	select DISTINCT submission_date,hacker_id
	from Submissions
	where submission_date = (select min(submission_date) from Submissions)
	union 
	select s.submission_date,s.hacker_id
	from Submissions s
	join hacker h on h.hacker_id = s.hacker_id
	where s.submission_date = (select min(submission_date) from Submissions
								where submission_date > h.submission_date)
	),
-- No. of unique hackers from this table (1)
	unique_hacker_count AS 
	(
	select submission_date,count(hacker_id) as unique_hackers
	from hacker
	group by submission_date
	ORDER by submission_date
	),
	 count_hacker as
	(
	select submission_date, hacker_id, count(1) as no_of_submissions
	from Submissions
	group by submission_date, hacker_id
	),
	max_hacker_id as
	(
	select submission_date, max(no_of_submissions) as max_no_submission
	from count_hacker
	group by submission_date
	),
	required_submission as
	(
	select mxi.submission_date,min(ch.hacker_id) as req_hackers
	from max_hacker_id mxi
	join count_hacker ch ON mxi.submission_date = ch.submission_date
	where ch.no_of_submissions = mxi.max_no_submission
	group by mxi.submission_date
	
	),
-- Final submission and name from this table (2)
	final_hacker_submission as
	(
	select rs.submission_date ,rs.req_hackers ,H.name
	from required_submission rs
	join Hackers H ON rs.req_hackers = H.hacker_id
	)
-- combining (1) and (2) for final result
select FHS.submission_date, UHC.unique_hackers , FHS.req_hackers, FHS.name
from final_hacker_submission FHS
join unique_hacker_count UHC ON FHS.submission_date = UHC.submission_date
order by 1

