--Set an Average amount of steps to be taken in a day
SELECT ROUND(AVG(TotalSteps), 0) AS AverageStepsPerDay
FROM bellabeat..dailyActivity

--Who is the most active person based on average steps
SELECT Id, ROUND(AVG(TotalSteps), 0) AS TotalSteps
FROM bellabeat..dailyActivity
GROUP BY Id
ORDER BY AVG(TotalSteps) DESC

--Show ratio of average steps per person 
SELECT Id, ROUND(AVG(TotalSteps), 0) AS TotalSteps, 
			(SELECT ROUND(AVG(TotalSteps), 0)
			FROM bellabeat..dailyActivity) AS AverageSteps, 
			ROUND(AVG(TotalSteps)/(SELECT ROUND(AVG(TotalSteps), 0)
			FROM bellabeat..dailyActivity), 2) AS Ratio
FROM bellabeat..dailyActivity
GROUP BY Id
ORDER BY AVG(TotalSteps) DESC

--See which hours of the day the most steps are taken
SELECT DATEPART(HOUR, ActivityHour) AS HourOfDay, SUM(StepTotal) AS TotalSteps 
FROM bellabeat..hourlySteps
GROUP BY DATEPART(HOUR, ActivityHour)
ORDER BY SUM(StepTotal) DESC

--Days most steps are taken
SELECT DATENAME(dw, ActivityHour) AS DayOfWeek, SUM(StepTotal) AS TotalSteps
FROM bellabeat..hourlySteps
GROUP BY DATENAME(dw, ActivityHour)
ORDER BY TotalSteps DESC

--How often is SedentaryActiveDistance 0
SELECT COUNT(*)
FROM bellabeat..dailyActivity
WHERE SedentaryActiveDistance <> 0

--How often is there a SedentaryActiveDistance
SELECT CONVERT(FLOAT, COUNT(*))/(SELECT COUNT(*)
					From bellabeat..dailyActivity) as RatioOfSedenaryActiveDisatance
FROM bellabeat..dailyActivity
WHERE SedentaryActiveDistance <> 0

--Summary Statistics for TotalDistance
SELECT MAX(TotalDistance) AS MaxDistance, MIN(TotalDistance) AS MinDistance, AVG(TotalDistance) AS AvgDistance
FROM bellabeat..dailyActivity

--Active vs Sedentary Minutes Daily
SELECT Id, CONVERT(DATE, ActivityDate) AS Date, VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes AS ActiveMinutesTotal, SedentaryMinutes AS SedentaryMinutesTotal,
		CONVERT(FLOAT, (VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes))/SedentaryMinutes AS ActiveVsSedentaryRatio
FROM bellabeat..dailyActivity
WHERE SedentaryMinutes <> 0

--Average calories per day
SELECT CONVERT(DATE, ActivityDate) AS Date, ROUND(AVG(Calories), 2) AS CaloriesPerDay
FROM bellabeat..dailyActivity
GROUP BY ActivityDate

--Days most calories are burned on
SELECT DATENAME(dw, ActivityDay) AS DayOfTheWeek, SUM(Calories) AS Calories
FROM bellabeat..dailyCalories
GROUP BY DATENAME(dw, ActivityDay)
ORDER BY Calories DESC

--Calories per person
SELECT Id, SUM(Calories) AS Calories
FROM bellabeat..dailyActivity
GROUP BY Id

--Top 10 Calorie Burners
SELECT TOP(10) ID, SUM(Calories) AS Calories
FROM bellabeat..dailyActivity
GROUP BY Id
ORDER BY SUM(Calories) DESC

--Id of people who burn over 100000 Calories
SELECT Id, SUM(Calories) AS Calories
FROM bellabeat..dailyActivity
GROUP BY Id
HAVING SUM(Calories) > 100000

--Change datetime column to date format in dailyActivity
BEGIN TRAN
ALTER TABLE bellabeat..dailyActivity
ALTER COLUMN ActivityDate DATE NOT NULL

SELECT *
FROM bellabeat..dailyActivity
ROLLBACK TRAN

--Check steps between two tables match
SELECT DA.Id, CAST(DA.ActivityDate AS DATE) AS ActivityDate, DA.TotalSteps, DS.StepTotal
FROM bellabeat..dailyActivity AS DA
INNER JOIN bellabeat..dailySteps AS DS
ON DA.Id = DS.Id AND DA.ActivityDate = DS.ActivityDay

--Get one heartrate reading per second
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

--Greatest hours for heartrate 
SELECT DATEPART(HOUR, Time) AS Hour, AVG(Value) AS AvgHeartRate
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

--Summary Statistics for heartrate
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

--Highest Calorie Hrs
SELECT DATEPART(HOUR, ActivityHour) AS HOUR, AVG(Calories) AS AvgCalories
FROM bellabeat..hourlyCalories
GROUP BY DATEPART(HOUR, ActivityHour)
ORDER BY AvgCalories DESC

--Highest Intensity Hrs
SELECT DATEPART(HOUR, ActivityHour) AS HOUR, AVG(TotalIntensity) AS AvgIntensity
FROM bellabeat..hourlyIntensities
GROUP BY DATEPART(HOUR, ActivityHour)
ORDER BY AvgIntensity DESC

--Highest Steps Hrs
SELECT DATEPART(HOUR, ActivityHour) AS HOUR, ROUND(AVG(StepTotal),0) AS AvgSteps
FROM bellabeat..hourlySteps
GROUP BY DATEPART(HOUR, ActivityHour)
ORDER BY AvgSteps DESC

--Which part of the hr are people burning more calories
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

--Which part of the hr are people's intensities higher
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

--METS by day
SELECT DATEPART(DAY, MinMet.ActivityMinute) AS DATE, AVG(MinMet.METs) AS AvgMet
FROM (
	SELECT *
	FROM bellabeat..minuteMETsNarrow0
	UNION
	SELECT *
	FROM bellabeat..minuteMETsNarrow1
	) AS MinMet
GROUP BY DATEPART(MONTH, ActivityMinute), DATEPART(DAY, MinMet.ActivityMinute)
ORDER BY AvgMet DESC

--Mets by the hr
SELECT DATEPART(HOUR, MinMet.ActivityMinute) AS HOUR, AVG(MinMet.METs) AS AvgMet
FROM (
	SELECT *
	FROM bellabeat..minuteMETsNarrow0
	UNION
	SELECT *
	FROM bellabeat..minuteMETsNarrow1
	) AS MinMet
GROUP BY DATEPART(HOUR, MinMet.ActivityMinute)
ORDER BY AvgMet DESC

--Which part of the hr are people's intensities higher
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

--Which part of the hr are people's steps more
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

--Sleep summary statistics
SELECT ROUND(MIN(TotalMinutesAsleep)/60, 2) AS MinSleep , ROUND(AVG(TotalMinutesAsleep)/60, 2) AS AvgSleep, ROUND(MAX(TotalMinutesAsleep)/60, 2) AS MaxSleep
FROM bellabeat..sleepDay

--Sleep by person
SELECT Id, DATEPART(DAY, SleepDay) AS DAY, ROUND(AVG(TotalMinutesAsleep)/60, 2) AS AvgHrsSleeping
FROM bellabeat..sleepDay
GROUP BY ID, DATEPART(MONTH, SleepDay), DATEPART(DAY, SleepDay)
ORDER BY Id

--Which days do people get the most sleep
SELECT DATENAME(dw, SleepDay) AS DayOfTheWeek, ROUND(AVG(TotalMinutesAsleep)/60, 2) AS AvgSleepTime  
FROM bellabeat..sleepDay
GROUP BY DATENAME(dw, SleepDay)
ORDER BY AvgSleepTime DESC

--Time spent before getting out of bed
SELECT Id, Round(Avg(TotalTimeInBed - TotalMinutesAsleep), 2) AS AvgTimeToGetUp
FROM bellabeat..sleepDay
GROUP BY Id

--Naps taken in a month
Select count(*) AS NapsPerMonth
FROM bellabeat..sleepDay
WHERE TotalSleepRecords > 1
GROUP BY Id

--BMI category per person
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

--Summary statistics for weight
SELECT ROUND(MIN(WeightPounds), 2) AS MinWeight, Round(AVG(WeightPounds), 2) AS AvgWeight, Round(MAX(WeightPounds), 2) AS MaxWeight
FROM bellabeat..weightLogInfo

--Steps vs Distance traveled
SELECT S.Id, SUM(S.StepTotal) AS StepTotal, SUM((I.LightActiveDistance + I.ModeratelyActiveDistance + I.VeryActiveDistance)) AS DistanceTotal
FROM bellabeat..dailySteps AS S
JOIN bellabeat..dailyIntensities AS I
ON S.Id = I.Id 
AND S.ActivityDay = I.ActivityDay
GROUP BY S.Id
ORDER BY StepTotal DESC

--Steps vs Calories
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

--Active Minutes vs Calories
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

--Active Minutes vs Sleep
SELECT AM.Id, SUM(AM.LightlyActiveMinutes + AM.FairlyActiveMinutes + AM.VeryActiveMinutes) AS ActiveMinutes, ROUND(AVG(S.TotalMinutesAsleep)/60, 2) AS TotalSleepTime
FROM bellabeat..dailyIntensities AS AM
JOIN bellabeat..sleepDay AS S
ON AM.Id = S.Id 
AND AM.ActivityDay = S.SleepDay
GROUP BY AM.Id
ORDER BY ActiveMinutes DESC

--Active Minutes vs BMI
SELECT AM.Id, SUM(ActiveMinutes) AS TotalActiveMinutes, AVG(BMI) AS BMI
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

--Intensity vs METs
SELECT I.Id, ROUND(AVG(I.Intensity), 2) AS AvgIntensity, ROUND(AVG(MET.METs), 2) AS AvgMETs
FROM (SELECT * FROM bellabeat..minuteIntensitiesNarrow0 UNION SELECT * FROM bellabeat..minuteIntensitiesNarrow1) AS I
JOIN (SELECT * FROM bellabeat..minuteMETsNarrow0 UNION SELECT * FROM bellabeat..minuteMETsNarrow1) AS MET
ON I.Id = MET.Id 
AND I.ActivityMinute = MET.ActivityMinute
GROUP BY I.ID
ORDER BY AvgIntensity DESC

--Heartrate vs METs
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
ORDER BY AvgHR 