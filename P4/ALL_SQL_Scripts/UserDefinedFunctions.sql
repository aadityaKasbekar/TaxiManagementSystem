-- User define function for days to find the number of days remaining

CREATE FUNCTION ServiceDueinDays(@ReqDateTime DATETIME, @ServiceDueDate DATETIME)
RETURNS INT AS
BEGIN
DECLARE @NoOfDays INT
	SET @NoOfDays = DATEDIFF(DAY,@ServiceDueDate,@ReqDateTime); 
	RETURN @NoOfDays;
END;

SELECT sr.*, dbo.ServiceDueinDays(sr.ServiceDueDate, sr.ReqDateTime) "Service due in days" from ServiceRequest sr;

--function to categorize the customer by age group

CREATE FUNCTION CustomerCategory(@DateOfBirth DATETIME)
RETURNS VARCHAR(20) AS
BEGIN
DECLARE @AgeInYears INT
DECLARE @Category VARCHAR(20);
   SET @AgeInYears = DATEDIFF(year,@DateofBirth,GETDATE());
   SELECT @Category = CASE WHEN @AgeInYears < 18 THEN 'Under 18'
						  WHEN @AgeInYears BETWEEN 18 AND 25 THEN ' Young Adult'
						  WHEN @AgeInYears BETWEEN 26 AND 40 THEN 'Adult'
						  WHEN @AgeInYears BETWEEN 41 AND 60 THEN 'Middle Aged'
						  ELSE 'Senior Citizens'
						  END;
	RETURN @Category;
END;

select u.UserFName+' '+u.UserLName "Customer Full Name", u.PhoneNumber "Customer Phone Number", u.DOB "Date of Birth", dbo.CustomerCategory(u.DOB) "Customer Category"
from Customer c join [User] u on c.UserID = u.UserID;