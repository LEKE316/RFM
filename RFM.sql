-- Code generator MYSQL Workbench version 6.3.4
-- The create view to generate Recency of users visit. 
CREATE VIEW recent AS  
(
	SELECT user_id, MAX(unix_timestamp(`timestamp`)) AS recency
	FROM sessions
	-- WHERE user_id IS NOT NULL AND session_id IS NOT NULL
	GROUP BY user_id
);


-- The create view to generate the frequency of users visit. 
CREATE VIEW frequent AS
(
	SELECT user_id, COUNT(DISTINCT session_id) AS frequency
	FROM sessions
	-- WHERE user_id IS NOT NULL AND session_id IS NOT NULL
	GROUP BY user_id
);


-- The create view to generate the total duration of users visit.
CREATE VIEW monetary AS
(
	SELECT sd.user_id, SUM(sd.duration) AS total 
	FROM 
	(
		SELECT user_id, session_id,
		(MAX(unix_timestamp(`timestamp`)) - MIN(unix_timestamp(`timestamp`))) AS duration
		FROM sessions
		-- WHERE user_id IS NOT NULL AND session_id IS NOT NULL
		GROUP BY user_id, session_id
	) AS sd GROUP BY sd.user_id
);


-- The create view to generate the rfm rank of the users 
-- ordered by recency, frequency and monetary. 
CREATE VIEW rfm AS
(
	SELECT rf.user_id, rf.recency, rf.frequency, m.total 
	FROM
	(
		SELECT r.user_id, r.recency, f.frequency  
		FROM recent r
		INNER JOIN frequent f ON r.user_id = f.user_id
	)	AS rf INNER JOIN monetary m ON rf.user_id = m.user_id
	ORDER BY rf.recency DESC, rf.frequency DESC, m.total DESC
);
