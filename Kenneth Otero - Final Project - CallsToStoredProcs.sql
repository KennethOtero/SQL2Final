-- --------------------------------------------------------------------------------
-- Kenneth Otero
-- March 16, 2021
-- Final Project - Calls to Stored Procedures
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------------
USE dbSQL1;     -- Get out of the master database
SET NOCOUNT ON; -- Report only errors

-- --------------------------------------------------------------------------------
-- Step 11 A: Create 8 patients for each study for screening
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- Study #1 Patient Screening
-- --------------------------------------------------------------------------------
-- Declare variables
DECLARE @intPatientID	AS INTEGER
DECLARE @intVisitID		AS INTEGER

BEGIN TRANSACTION
	-- Patient #1 - Patient number, Site ID, DOB, gender, weight, and visit date
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 101001, 1, '01/01/1970', 1, 200, '01/01/1995'

	-- Patient #2
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 101002, 1, '02/02/1971', 1, 190, '02/02/1996'

	-- Patient #3
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 111001, 2, '03/03/1972', 1, 180, '03/03/1997'

	-- Patient #4
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 111002, 2, '04/04/1973', 1, 170, '04/04/1998'

	-- Patient #5
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 121001, 3, '05/05/1974', 1, 160, '05/05/1999'

	-- Patient #6
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 121002, 3, '06/06/1975', 1, 150, '06/06/2000'

	-- Patient #7
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 121003, 3, '07/07/1976', 1, 155, '07/07/2001'

	-- Patient #8
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 121004, 3, '08/08/1977', 1, 210, '08/08/2002'

COMMIT TRANSACTION

-- --------------------------------------------------------------------------------
-- Study #2 Patient Screening
-- --------------------------------------------------------------------------------
BEGIN TRANSACTION
	-- Patient #9 - Patient number, SiteID, DOB, gender, weight, and visit date
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 501001, 4, '01/01/1980', 1, 130, '01/01/2000'

	-- Patient #10
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 501002, 4, '02/02/1981', 1, 140, '02/02/2001'

	-- Patient #11
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 511001, 5, '03/03/1982', 1, 150, '03/03/2002'

	-- Patient #12
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 511002, 5, '04/04/1983', 1, 160, '04/04/2003'

	-- Patient #13
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 521001, 6, '05/05/1984', 1, 170, '05/05/2004'

	-- Patient #14
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 521002, 6, '06/06/1985', 1, 180, '06/06/2005'

	-- Patient #15
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 521003, 6, '07/07/1986', 1, 190, '07/07/2006'

	-- Patient #16
	EXECUTE uspScreening @intPatientID OUTPUT, @intVisitID OUTPUT, 521004, 6, '08/08/1987', 1, 200, '08/08/2007'
COMMIT TRANSACTION

-- --------------------------------------------------------------------------------
-- Step 11 B: 5 patients randomized for each study (including assigning
-- drug kit)
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- Study #1 Randomization - Patients 3-8 from screening
-- --------------------------------------------------------------------------------
BEGIN TRANSACTION
	-- Randomized Patient #1 - intPatientID, intStudyID
	EXECUTE uspRandomization 3, 1

	-- Randomized Patient #2
	EXECUTE uspRandomization 4, 1

	-- Randomized Patient #3
	EXECUTE uspRandomization 5, 1

	-- Randomized Patient #4
	EXECUTE uspRandomization 6, 1

	-- Randomized Patient #5
	EXECUTE uspRandomization 7, 1

COMMIT TRANSACTION

-- --------------------------------------------------------------------------------
-- Study #2 Randomization - Patients 11-16 from screening
-- --------------------------------------------------------------------------------
BEGIN TRANSACTION
	-- Randomized Patient #1 - intPatientID, intStudyID
	EXECUTE uspRandomization 11, 2

	-- Randomized Patient #2
	EXECUTE uspRandomization 12, 2

	-- Randomized Patient #3
	EXECUTE uspRandomization 13, 2

	-- Randomized Patient #4
	EXECUTE uspRandomization 14, 2

	-- Randomized Patient #5
	EXECUTE uspRandomization 15, 2

COMMIT TRANSACTION

-- --------------------------------------------------------------------------------
-- Step 11 C: Withdraw 4 patients (2 randomized and 2 not randomized) from each
-- study
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- Study #1 Withdrawal
-- --------------------------------------------------------------------------------
BEGIN TRANSACTION
	-- Withdraw Patient #1 - not randomized - intPatientID, visit date, intWithdrawReasonID
	EXECUTE uspWithdrawal @intVisitID OUTPUT, 1, '03/16/2021', 1

	-- Withdraw Patient #2 - not randomized
	EXECUTE uspWithdrawal @intVisitID OUTPUT, 2, '02/02/2011', 2

	-- Withdraw Patient #3 - randomized
	EXECUTE uspWithdrawal @intVisitID OUTPUT, 3, '02/02/2012', 6

	-- Withdraw Patient #4 - randomized
	EXECUTE uspWithdrawal @intVisitID OUTPUT, 4, '02/02/2013', 1
COMMIT TRANSACTION

-- --------------------------------------------------------------------------------
-- Study #2 Withdrawal
-- --------------------------------------------------------------------------------
BEGIN TRANSACTION
	-- Withdraw Patient #1 - not randomized - intPatientID, visit date, intWithdrawReasonID
	EXECUTE uspWithdrawal @intVisitID OUTPUT, 9, '03/16/2021', 1

	-- Withdraw Patient #2 - not randomized
	EXECUTE uspWithdrawal @intVisitID OUTPUT, 10, '03/16/2021', 1

	-- Withdraw Patient #3 - randomized
	EXECUTE uspWithdrawal @intVisitID OUTPUT, 11, '03/17/2022', 6

	-- Withdraw Patient #4 - randomized
	EXECUTE uspWithdrawal @intVisitID OUTPUT, 12, '03/17/2022', 6
COMMIT TRANSACTION