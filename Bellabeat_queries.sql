-- 1. Set an Average amount of steps to be taken in a day
SELECT ROUND(AVG(TotalSteps), 0) AS AverageStepsPerDay
FROM bellabeat..dailyActivity

-- 2. Who is the most active person based on average steps
SELECT Id, ROUND(AVG(TotalSteps), 0) AS TotalSteps
FROM bellabeat..dailyActivity
GROUP BY Id
ORDER BY AVG(TotalSteps) DESC

-- 3. Show ratio of average steps per person 
SELECT Id, ROUND(AVG(TotalSteps), 0) AS TotalSteps, 
			(SELECT ROUND(AVG(TotalSteps), 0)
			FROM bellabeat..dailyActivity) AS AverageSteps, 
			ROUND(AVG(TotalSteps)/(SELECT ROUND(AVG(TotalSteps), 0)
			FROM bellabeat..dailyActivity), 2) AS Ratio
FROM bellabeat..dailyActivity
GROUP BY Id
ORDER BY AVG(TotalSteps) DESC

-- 4. See which hours of the day the most steps are taken
SELECT DATEPART(HOUR, ActivityHour) AS HourOfDay, SUM(StepTotal) AS TotalSteps 
FROM bellabeat..hourlySteps
GROUP BY DATEPART(HOUR, ActivityHour)
ORDER BY SUM(StepTotal) DESC

-- 5. Days most steps are taken
SELECT DATENAME(dw, ActivityHour) AS DayOfWeek, ROUND(AVG(StepTotal), 0) AS TotalSteps
FROM bellabeat..hourlySteps
GROUP BY DATENAME(dw, ActivityHour)
ORDER BY TotalSteps DESC

-- 6. How often is SedentaryActiveDistance 0
SELECT COUNT(*) AS NumberOfSedentaryHours
FROM bellabeat..dailyActivity
WHERE SedentaryActiveDistance <> 0

-- 7. How often is there a SedentaryActiveDistance
SELECT CONVERT(FLOAT, COUNT(*))/(SELECT COUNT(*)
					From bellabeat..dailyActivity) as RatioOfSedenaryActiveDisatance
FROM bellabeat..dailyActivity
WHERE SedentaryActiveDistance <> 0

-- 8. Summary Statistics for TotalDistance
SELECT MAX(TotalDistance) AS MaxDistance, MIN(TotalDistance) AS MinDistance, AVG(TotalDistance) AS AvgDistance
FROM bellabeat..dailyActivity
WHERE TotalDistance <> 0

-- 9. Active vs Sedentary Minutes Daily
SELECT Id, CONVERT(DATE, ActivityDate) AS Date, (VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) AS ActiveMinutesTotal, SedentaryMinutes AS SedentaryMinutesTotal,
		CONVERT(FLOAT, (VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes))/SedentaryMinutes AS ActiveVsSedentaryRatio
FROM bellabeat..dailyActivity
WHERE SedentaryMinutes <> 0 AND DATENAME(dw, ActivityDate) NOT IN ('Saturday', 'Sunday')
ORDER BY ActiveVsSedentaryRatio DESC

-- 10. Average calories per day
SELECT CONVERT(DATE, ActivityDate) AS Date, ROUND(AVG(Calories), 2) AS CaloriesPerDay
FROM bellabeat..dailyActivity
GROUP BY ActivityDate
ORDER BY CaloriesPerDay DESC

-- 11. Days most calories are burned on
SELECT DATENAME(dw, ActivityDay) AS DayOfTheWeek, SUM(Calories) AS Calories
FROM bellabeat..dailyCalories
GROUP BY DATENAME(dw, ActivityDay)
ORDER BY Calories DESC

-- 12. Calories per person
SELECT Id, SUM(Calories) AS Calories
FROM bellabeat..dailyActivity
GROUP BY Id

-- 13. Top 10 Calorie Burners
SELECT TOP(10) ID, SUM(Calories) AS Calories
FROM bellabeat..dailyActivity
GROUP BY Id
ORDER BY SUM(Calories) DESC

-- 14. Id of people who burn over 100000 Calories
SELECT Id, SUM(Calories) AS Calories
FROM bellabeat..dailyActivity
GROUP BY Id
HAVING SUM(Calories) > 100000

-- 15. Change datetime column to date format in dailyActivity
BEGIN TRAN
ALTER TABLE bellabeat..dailyActivity
ALTER COLUMN ActivityDate DATE NOT NULL

SELECT *
FROM bellabeat..dailyActivity
ROLLBACK TRAN

-- 16. Check steps between two tables match
SELECT DA.Id, CAST(DA.ActivityDate AS DATE) AS ActivityDate, DA.TotalSteps, DS.StepTotal
FROM bellabeat..dailyActivity AS DA
INNER JOIN bellabeat..dailySteps AS DS
ON DA.Id = DS.Id AND DA.ActivityDate = DS.ActivityDay

-- 17. Get one heartrate reading per second
SELECT HR.Id, CONCAT(DATEPART(YEAR, HR.Time),'-',DATEPART(MONTH, HR.Time),'-', DATEPART(DAY, HR.Time),' ', DATEPART(HOUR, HR.Time),':', 
DATEPART(MINUTE, HR.Time)) AS Time, ROUND(AVG(HR.Value), 0) AS HeartbeatPerSecond
FROM (
	SELECT *
	FROM bellabeat..heartrateSeconds0
	UNION 
	SELECT *
	FROM bellabeat..heartrateSeconds1
	UNION
	SELECT *
	FROM bellabeat..heartrateSeconds2
	) AS HR
GROUP BY HR.Id, DATEPART(YEAR, HR.Time), DATEPART(MONTH, HR.Time), DATEPART(DAY, HR.Time), DATEPART(HOUR, HR.Time), DATEPART(MINUTE, HR.Time)
ORDER BY HR.Id, DATEPART(YEAR, HR.Time), DATEPART(MONTH, HR.Time), DATEPART(DAY, HR.Time), DATEPART(HOUR, HR.Time), DATEPART(MINUTE, HR.Time)

-- 18. Greatest hours for heartrate 
SELECT DATEPART(HOUR, Time) AS Hour, ROUND(AVG(Value), 0) AS AvgHeartRate
FROM (
	SELECT * 
	FROM bellabeat..heartrateSeconds0
	UNION 
	SELECT *
	FROM bellabeat..heartrateSeconds1
	UNION
	SELECT *
	FROM bellabeat..heartrateSeconds2
	) AS HR
GROUP BY DATEPART(HOUR, Time)
ORDER BY AvgHeartRate DESC

-- 19. Avg hr per day
SELECT DATENAME(dw, Time) AS DayOfWeek, ROUND(AVG(VALUE), 0) AS AvgHeartRate
FROM (
	SELECT * 
	FROM bellabeat..heartrateSeconds0
	UNION 
	SELECT *
	FROM bellabeat..heartrateSeconds1
	UNION
	SELECT *
	FROM bellabeat..heartrateSeconds2
	) AS HR
GROUP BY DATENAME(dw, Time)
ORDER BY AvgHeartRate DESC

-- 20. Summary Statistics for heartrate
SELECT MIN(HR.Value) AS MinHr, ROUND(AVG(HR.Value), 0) AS AvgHR, MAX(HR.Value) AS MaxHr
FROM (
	SELECT *
	FROM bellabeat..heartrateSeconds0
	UNION
	SELECT *
	FROM bellabeat..heartrateSeconds1
	UNION
	SELECT *
	FROM bellabeat..heartrateSeconds2
	) AS HR
WHERE HR.Value <> 0 

-- 21. Highest Calorie Hrs
SELECT DATEPART(HOUR, ActivityHour) AS HOUR, ROUND(AVG(Calories), 0) AS AvgCalories
FROM bellabeat..hourlyCalories
GROUP BY DATEPART(HOUR, ActivityHour)
ORDER BY AvgCalories DESC

-- 22. Highest Intensity Hrs
SELECT DATEPART(HOUR, ActivityHour) AS HOUR, ROUND(AVG(TotalIntensity), 2) AS AvgIntensity
FROM bellabeat..hourlyIntensities
GROUP BY DATEPART(HOUR, ActivityHour)
ORDER BY AvgIntensity DESC

-- 23. Days of avg Intensity
SELECT DATENAME(dw, ActivityHour) AS DayOfWeek, ROUND(AVG(TotalIntensity), 2) AS AvgIntensity
FROM bellabeat..hourlyIntensities
GROUP BY DATENAME(dw, ActivityHour)
ORDER BY AvgIntensity DESC

-- 24. Highest Steps Hrs
SELECT DATEPART(HOUR, ActivityHour) AS HOUR, ROUND(AVG(StepTotal),0) AS AvgSteps
FROM bellabeat..hourlySteps
GROUP BY DATEPART(HOUR, ActivityHour)
ORDER BY AvgSteps DESC

-- 25. Which part of the hr are people burning more calories
SELECT(
	CASE 
		WHEN DATEPART(MINUTE, MinCal.ActivityMinute) < 15 THEN '0 TO 15'
		WHEN DATEPART(MINUTE, MinCal.ActivityMinute) >= 15 AND DATEPART(MINUTE, MinCal.ActivityMinute) < 30 THEN '15 TO 30'
		WHEN DATEPART(MINUTE, MinCal.ActivityMinute) >= 30 AND DATEPART(MINUTE, MinCal.ActivityMinute) < 45 THEN '30 TO 45'
		ELSE '45 TO 60'
	END) AS PartOfHour, FORMAT(SUM(MinCal.Calories), 'N2') AS Calories
FROM (
	SELECT * 
	FROM bellabeat..minuteCaloriesNarrow0
	UNION
	SELECT *
	FROM bellabeat..minuteCaloriesNarrow1
	) AS MinCal
GROUP BY (
	CASE 
		WHEN DATEPART(MINUTE, MinCal.ActivityMinute) < 15 THEN '0 TO 15'
		WHEN DATEPART(MINUTE, MinCal.ActivityMinute) >= 15 AND DATEPART(MINUTE, MinCal.ActivityMinute) < 30 THEN '15 TO 30'
		WHEN DATEPART(MINUTE, MinCal.ActivityMinute) >= 30 AND DATEPART(MINUTE, MinCal.ActivityMinute) < 45 THEN '30 TO 45'
		ELSE '45 TO 60'
	END)
ORDER BY Calories DESC

-- 26. Which part of the hr are people's intensities higher
SELECT(
	CASE 
		WHEN DATEPART(MINUTE, MinInt.ActivityMinute) < 15 THEN '0 TO 15'
		WHEN DATEPART(MINUTE, MinInt.ActivityMinute) >= 15 AND DATEPART(MINUTE, MinInt.ActivityMinute) < 30 THEN '15 TO 30'
		WHEN DATEPART(MINUTE, MinInt.ActivityMinute) >= 30 AND DATEPART(MINUTE, MinInt.ActivityMinute) < 45 THEN '30 TO 45'
		ELSE '45 TO 60'
	END) AS PartOfHour, FORMAT(SUM(MinInt.Intensity), 'N2') AS Intensities
FROM (
	SELECT * 
	FROM bellabeat..minuteIntensitiesNarrow0
	UNION
	SELECT *
	FROM bellabeat..minuteIntensitiesNarrow1
	) AS MinInt
GROUP BY (
	CASE 
		WHEN DATEPART(MINUTE, MinInt.ActivityMinute) < 15 THEN '0 TO 15'
		WHEN DATEPART(MINUTE, MinInt.ActivityMinute) >= 15 AND DATEPART(MINUTE, MinInt.ActivityMinute) < 30 THEN '15 TO 30'
		WHEN DATEPART(MINUTE, MinInt.ActivityMinute) >= 30 AND DATEPART(MINUTE, MinInt.ActivityMinute) < 45 THEN '30 TO 45'
		ELSE '45 TO 60'
	END)
ORDER BY Intensities DESC

-- 27. METS by day
SELECT DATEPART(DAY, MinMet.ActivityMinute) AS DATE, ROUND(AVG(MinMet.METs), 2) AS AvgMet
FROM (
	SELECT *
	FROM bellabeat..minuteMETsNarrow0
	UNION
	SELECT *
	FROM bellabeat..minuteMETsNarrow1
	) AS MinMet
GROUP BY DATEPART(MONTH, ActivityMinute), DATEPART(DAY, MinMet.ActivityMinute)
ORDER BY AvgMet DESC

-- 28. Mets by the hr
SELECT DATEPART(HOUR, MinMet.ActivityMinute) AS HOUR, ROUND(AVG(MinMet.METs), 2) AS AvgMet
FROM (
	SELECT *
	FROM bellabeat..minuteMETsNarrow0
	UNION
	SELECT *
	FROM bellabeat..minuteMETsNarrow1
	) AS MinMet
GROUP BY DATEPART(HOUR, MinMet.ActivityMinute)
ORDER BY AvgMet DESC

-- 29. Mets by the day of week
SELECT DATENAME(dw, MinMet.ActivityMinute) AS DayOfWeek, Round(AVG(MinMet.METs), 2) AS AvgMet
FROM (
	SELECT *
	FROM bellabeat..minuteMETsNarrow0
	UNION
	SELECT *
	FROM bellabeat..minuteMETsNarrow1
	) AS MinMet
GROUP BY DATENAME(dw, MinMet.ActivityMinute)
ORDER BY AvgMet DESC

-- 30. Which part of the hr are people's intensities higher
SELECT(
	CASE 
		WHEN DATEPART(MINUTE, MinMet.ActivityMinute) < 15 THEN '0 TO 15'
		WHEN DATEPART(MINUTE, MinMet.ActivityMinute) >= 15 AND DATEPART(MINUTE, MinMet.ActivityMinute) < 30 THEN '15 TO 30'
		WHEN DATEPART(MINUTE, MinMet.ActivityMinute) >= 30 AND DATEPART(MINUTE, MinMet.ActivityMinute) < 45 THEN '30 TO 45'
		ELSE '45 TO 60'
	END) AS PartOfHour, FORMAT(SUM(MinMet.METs), 'N0') AS METs
FROM (
	SELECT * 
	FROM bellabeat..minuteMETsNarrow0
	UNION
	SELECT *
	FROM bellabeat..minuteMETsNarrow1
	) AS MinMet
GROUP BY (
	CASE 
		WHEN DATEPART(MINUTE, MinMet.ActivityMinute) < 15 THEN '0 TO 15'
		WHEN DATEPART(MINUTE, MinMet.ActivityMinute) >= 15 AND DATEPART(MINUTE, MinMet.ActivityMinute) < 30 THEN '15 TO 30'
		WHEN DATEPART(MINUTE, MinMet.ActivityMinute) >= 30 AND DATEPART(MINUTE, MinMet.ActivityMinute) < 45 THEN '30 TO 45'
		ELSE '45 TO 60'
	END)
ORDER BY METs DESC

-- 31. Which part of the hr are people's steps more
SELECT(
	CASE 
		WHEN DATEPART(MINUTE, MinStep.ActivityMinute) < 15 THEN '0 TO 15'
		WHEN DATEPART(MINUTE, MinStep.ActivityMinute) >= 15 AND DATEPART(MINUTE, MinStep.ActivityMinute) < 30 THEN '15 TO 30'
		WHEN DATEPART(MINUTE, MinStep.ActivityMinute) >= 30 AND DATEPART(MINUTE, MinStep.ActivityMinute) < 45 THEN '30 TO 45'
		ELSE '45 TO 60'
	END) AS PartOfHour, FORMAT(SUM(MinStep.Steps), 'N0') AS Steps
FROM (
	SELECT * 
	FROM bellabeat..minuteStepsNarrow0
	UNION
	SELECT *
	FROM bellabeat..minuteStepsNarrow1
	) AS MinStep
GROUP BY (
	CASE 
		WHEN DATEPART(MINUTE, MinStep.ActivityMinute) < 15 THEN '0 TO 15'
		WHEN DATEPART(MINUTE, MinStep.ActivityMinute) >= 15 AND DATEPART(MINUTE, MinStep.ActivityMinute) < 30 THEN '15 TO 30'
		WHEN DATEPART(MINUTE, MinStep.ActivityMinute) >= 30 AND DATEPART(MINUTE, MinStep.ActivityMinute) < 45 THEN '30 TO 45'
		ELSE '45 TO 60'
	END)
ORDER BY Steps DESC

-- 32. Sleep summary statistics
SELECT ROUND(MIN(TotalMinutesAsleep)/60, 2) AS MinSleep , ROUND(AVG(TotalMinutesAsleep)/60, 2) AS AvgSleep, ROUND(MAX(TotalMinutesAsleep)/60, 2) AS MaxSleep
FROM bellabeat..sleepDay

-- 33. Sleep by person
SELECT Id, DATEPART(DAY, SleepDay) AS Day, ROUND(AVG(TotalMinutesAsleep)/60, 2) AS AvgHrsSleeping
FROM bellabeat..sleepDay
GROUP BY ID, DATEPART(MONTH, SleepDay), DATEPART(DAY, SleepDay)
ORDER BY AvgHrsSleeping DESC

-- 34. Which days do people get the most sleep
SELECT DATENAME(dw, SleepDay) AS DayOfTheWeek, ROUND(AVG(TotalMinutesAsleep)/60, 2) AS AvgSleepTime  
FROM bellabeat..sleepDay
GROUP BY DATENAME(dw, SleepDay)
ORDER BY AvgSleepTime DESC

-- 35. Time spent before getting out of bed
SELECT Id, Round(Avg(TotalTimeInBed - TotalMinutesAsleep), 2) AS AvgTimeToGetUp
FROM bellabeat..sleepDay
GROUP BY Id

-- 36. Naps taken in a month
Select count(*) AS NapsPerMonth
FROM bellabeat..sleepDay
WHERE TotalSleepRecords > 1
GROUP BY Id

-- 37. BMI category per person
SELECT 
	(CASE
		WHEN CleanBmi.BMI < 18.5 THEN 'UNDERWEIGHT'
		WHEN CleanBmi.BMI >= 18.5 AND BMI < 25 THEN 'HEALTHY'
		WHEN CleanBmi.BMI >= 25 AND BMI < 30 THEN 'OVERWEIGHT'
		ELSE 'OBESE'
	END) AS BmiDescription,
	COUNT(BMI) AS BMI
FROM (
	SELECT Id, AVG(BMI) AS BMI
	FROM bellabeat..weightLogInfo
	GROUP BY Id
	) AS CleanBmi
GROUP BY
	(CASE
		WHEN CleanBmi.BMI < 18.5 THEN 'UNDERWEIGHT'
		WHEN CleanBmi.BMI >= 18.5 AND BMI < 25 THEN 'HEALTHY'
		WHEN CleanBmi.BMI >= 25 AND BMI < 30 THEN 'OVERWEIGHT'
		ELSE 'OBESE'
	END)

-- 38. Summary statistics for weight
SELECT ROUND(MIN(WeightPounds), 2) AS MinWeight, Round(AVG(WeightPounds), 2) AS AvgWeight, Round(MAX(WeightPounds), 2) AS MaxWeight
FROM bellabeat..weightLogInfo

-- 39. Steps vs Distance traveled
SELECT S.Id, SUM(S.StepTotal) AS StepTotal, ROUND(SUM((I.LightActiveDistance + I.ModeratelyActiveDistance + I.VeryActiveDistance)), 2) AS DistanceTotal
FROM bellabeat..dailySteps AS S
JOIN bellabeat..dailyIntensities AS I
ON S.Id = I.Id 
AND S.ActivityDay = I.ActivityDay
GROUP BY S.Id
ORDER BY StepTotal DESC

-- 40. Steps vs Calories
SELECT SC.Id, SUM(SC.StepTotal) AS StepTotal, SUM(SC.Calories) AS CaloriesTotal
FROM (
	SELECT DISTINCT S.Id, S.ActivityDay, S.StepTotal, C.Calories
	FROM bellabeat..dailySteps AS S
	JOIN bellabeat..dailyCalories AS C
	ON S.Id = C.Id
	AND S.ActivityDay = C.ActivityDay
	) AS SC
GROUP BY SC.Id
ORDER BY StepTotal DESC

-- 41. Active Minutes vs Calories
SELECT AMC.Id, SUM(AMC.ActiveMinutes) AS TotalActiveMinutes, SUM(AMC.Calories) AS TotalCalories 
FROM (
	SELECT DISTINCT AM.Id, AM.ActivityDay, (AM.LightlyActiveMinutes + AM.FairlyActiveMinutes + AM.VeryActiveMinutes) AS ActiveMinutes, C.Calories
	FROM bellabeat..dailyIntensities AS AM
	JOIN bellabeat..dailyCalories AS C
	ON AM.Id = C.Id 
	AND AM.ActivityDay = C.ActivityDay
	) AS AMC
GROUP BY AMC.Id
ORDER BY TotalActiveMinutes DESC

-- 42. Active Minutes vs Sleep
SELECT AM.Id, SUM(AM.LightlyActiveMinutes + AM.FairlyActiveMinutes + AM.VeryActiveMinutes) AS ActiveMinutes, ROUND(AVG(S.TotalMinutesAsleep)/60, 2) AS TotalSleepTime
FROM bellabeat..dailyIntensities AS AM
JOIN bellabeat..sleepDay AS S
ON AM.Id = S.Id 
AND AM.ActivityDay = S.SleepDay
GROUP BY AM.Id
ORDER BY ActiveMinutes DESC

-- 43. Active Minutes vs BMI
SELECT AM.Id, SUM(ActiveMinutes) AS TotalActiveMinutes, ROUND(AVG(BMI), 1) AS BMI
FROM (
	(
	SELECT AM.Id, AM.ActivityDay, SUM(AM.LightlyActiveMinutes + AM.FairlyActiveMinutes + AM.VeryActiveMinutes) AS ActiveMinutes
	FROM bellabeat..dailyIntensities AS AM
	GROUP BY AM.Id, AM.ActivityDay
	) AS AM
JOIN (
	SELECT BMI.Id, AVG(BMI.BMI) AS BMI
	FROM bellabeat..weightLogInfo AS BMI
	GROUP BY BMI.Id
	) AS BMI
ON AM.Id = BMI.Id
	) 
GROUP BY AM.Id
ORDER BY TotalActiveMinutes DESC

-- 44. Intensity vs METs
SELECT I.Id, ROUND(AVG(I.Intensity), 2) AS AvgIntensity, ROUND(AVG(MET.METs), 2) AS AvgMETs
FROM (SELECT * FROM bellabeat..minuteIntensitiesNarrow0 UNION SELECT * FROM bellabeat..minuteIntensitiesNarrow1) AS I
JOIN (SELECT * FROM bellabeat..minuteMETsNarrow0 UNION SELECT * FROM bellabeat..minuteMETsNarrow1) AS MET
ON I.Id = MET.Id 
AND I.ActivityMinute = MET.ActivityMinute
GROUP BY I.ID
ORDER BY AvgIntensity DESC

-- 45. Heartrate vs METs
SELECT HR.Id, Round(AvgHeartRate, 2) AS AvgHR, ROUND(AvgMETs, 2) AS AvgMETs 
FROM (
	SELECT AllHR.Id, AVG(AllHR.Value) AS AvgHeartRate
	FROM (
		SELECT * FROM bellabeat..heartrateSeconds0 
		UNION 
		SELECT * FROM bellabeat..heartrateSeconds1 
		UNION 
		SELECT * FROM bellabeat..heartrateSeconds2
		) AS AllHR
	GROUP BY Id) AS HR
JOIN (
	SELECT AllMET.Id, AVG(AllMET.METs) AS AvgMETs
	FROM (
		SELECT * FROM bellabeat..minuteMETsNarrow0 
		UNION 
		SELECT * FROM bellabeat..minuteMETsNarrow1
		) AS AllMET
	GROUP BY AllMET.Id) AS MET
ON HR.Id = MET.Id
ORDER BY AvgHR DESC

-- 46. Steps, Calories, HeartRate, Intensity, METs by hour of the day
SELECT Steps.Hour, AvgSteps, AvgCalories, AvgHeartRate, AvgIntensity, AvgMet
FROM (
	SELECT DATEPART(HOUR, ActivityHour) AS Hour, ROUND(AVG(StepTotal),0) AS AvgSteps
	FROM bellabeat..hourlySteps
	GROUP BY DATEPART(HOUR, ActivityHour)
	) AS Steps
	JOIN (
		SELECT DATEPART(HOUR, ActivityHour) AS Hour, ROUND(AVG(Calories), 0) AS AvgCalories
		FROM bellabeat..hourlyCalories
		GROUP BY DATEPART(HOUR, ActivityHour)
		) AS Cal
	ON Steps.Hour = Cal.Hour
	JOIN (
		SELECT DATEPART(HOUR, HR.Time) AS Hour, ROUND(AVG(HR.Value), 0) AS AvgHeartRate
		FROM (
			SELECT * 
			FROM bellabeat..heartrateSeconds0
			UNION 
			SELECT *
			FROM bellabeat..heartrateSeconds1
			UNION
			SELECT *
			FROM bellabeat..heartrateSeconds2
			) AS HR
		GROUP BY DATEPART(HOUR, Time)
		) AS HR
	ON Steps.Hour = HR.Hour
	JOIN (
		SELECT DATEPART(HOUR, ActivityHour) AS Hour, ROUND(AVG(TotalIntensity), 0) AS AvgIntensity
		FROM bellabeat..hourlyIntensities
		GROUP BY DATEPART(HOUR, ActivityHour)
		) AS Intensity
	ON Steps.Hour = Intensity.Hour
	JOIN (
		SELECT DATEPART(HOUR, MinMet.ActivityMinute) AS Hour, ROUND(AVG(MinMet.METs), 0) AS AvgMet
		FROM (
			SELECT *
			FROM bellabeat..minuteMETsNarrow0
			UNION
			SELECT *
			FROM bellabeat..minuteMETsNarrow1
			) AS MinMet
		GROUP BY DATEPART(HOUR, MinMet.ActivityMinute)
		) AS Met
		ON Steps.Hour = Met.Hour
ORDER BY Hour
		
-- 47. Steps, Calories, HeartRate, Intensity, METs by day of the week
SELECT Steps.DayOfTheWeek, AvgSteps, AvgCalories, AvgHeartRate, AvgIntensity, AvgMet, AvgSleepTime
FROM (
	SELECT DATENAME(dw, ActivityHour) AS DayOfTheWeek, ROUND(AVG(StepTotal), 0) AS AvgSteps
	FROM bellabeat..hourlySteps
	GROUP BY DATENAME(dw, ActivityHour)
	) AS Steps
	JOIN (
		SELECT DATENAME(dw, ActivityDay) AS DayOfTheWeek, ROUND(AVG(Calories), 0) AS AvgCalories
		FROM bellabeat..dailyCalories
		GROUP BY DATENAME(dw, ActivityDay)
		) AS Cal
	ON Steps.DayOfTheWeek = Cal.DayOfTheWeek
	JOIN (
		SELECT DATENAME(dw, Time) AS DayOfTheWeek, ROUND(AVG(VALUE), 0) AS AvgHeartRate
		FROM (
			SELECT * 
			FROM bellabeat..heartrateSeconds0
			UNION 
			SELECT *
			FROM bellabeat..heartrateSeconds1
			UNION
			SELECT *
			FROM bellabeat..heartrateSeconds2
			) AS HR
		GROUP BY DATENAME(dw, Time)
		) AS HeartRate
	ON Steps.DayOfTheWeek = HeartRate.DayOfTheWeek
	JOIN (
		SELECT DATENAME(dw, ActivityHour) AS DayOfTheWeek, ROUND(AVG(TotalIntensity), 0) AS AvgIntensity
		FROM bellabeat..hourlyIntensities
		GROUP BY DATENAME(dw, ActivityHour)
		) AS Intensity
	ON Steps.DayOfTheWeek = Intensity.DayOfTheWeek
	JOIN (
		SELECT DATENAME(dw, MinMet.ActivityMinute) AS DayOfTheWeek, Round(AVG(MinMet.METs), 0) AS AvgMet
		FROM (
			SELECT *
			FROM bellabeat..minuteMETsNarrow0
			UNION
			SELECT *
			FROM bellabeat..minuteMETsNarrow1
			) AS MinMet
		GROUP BY DATENAME(dw, MinMet.ActivityMinute)
		) AS Met
	ON Steps.DayOfTheWeek = Met.DayOfTheWeek
	JOIN (
		SELECT DATENAME(dw, SleepDay) AS DayOfTheWeek, ROUND(AVG(TotalMinutesAsleep)/60, 2) AS AvgSleepTime  
		FROM bellabeat..sleepDay
		GROUP BY DATENAME(dw, SleepDay)
		) AS Sleep
	ON Steps.DayOfTheWeek = Sleep.DayOfTheWeek
ORDER BY AvgSteps

-- 48. Global averages
SELECT 'Average' AS GlobalStatistics, 
		(SELECT ROUND(AVG(TotalSteps), 0) 
		FROM bellabeat..dailyActivity) AS Steps,
		(SELECT ROUND(AVG(Calories), 0)
		FROM bellabeat..dailyCalories) AS Calories, 
		(SELECT ROUND(AVG(HR.Value), 0)
		FROM (
			SELECT * 
			FROM bellabeat..heartrateSeconds0
			UNION 
			SELECT *
			FROM bellabeat..heartrateSeconds1
			UNION
			SELECT *
			FROM bellabeat..heartrateSeconds2
			) AS HR
		) AS HeartRate, 
		(SELECT ROUND(AVG(TotalIntensity), 0)
		FROM bellabeat..hourlyIntensities) AS Intensity, 
		(SELECT ROUND(AVG(MinMet.METs), 0)
		FROM (
			SELECT *
			FROM bellabeat..minuteMETsNarrow0
			UNION
			SELECT *
			FROM bellabeat..minuteMETsNarrow1
			) AS MinMet
		) AS Met,
		(SELECT ROUND(AVG(TotalMinutesAsleep/60), 2)
		FROM bellabeat..sleepDay) AS Sleep
