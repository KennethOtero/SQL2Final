-- --------------------------------------------------------------------------------
-- Kenneth Otero
-- March 15, 2021
-- Final Project - Randomization
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------------
USE dbSQL1;     -- Get out of the master database
SET NOCOUNT ON; -- Report only errors

-- --------------------------------------------------------------------------------
-- Drop Tables
-- --------------------------------------------------------------------------------
IF OBJECT_ID('TDrugKits')					IS NOT NULL DROP TABLE TDrugKits
IF OBJECT_ID('TVisits')						IS NOT NULL DROP TABLE TVisits
IF OBJECT_ID('TPatients')					IS NOT NULL DROP TABLE TPatients
IF OBJECT_ID('TSites')						IS NOT NULL DROP TABLE TSites
IF OBJECT_ID('TRandomCodes')				IS NOT NULL DROP TABLE TRandomCodes
IF OBJECT_ID('TStudies')					IS NOT NULL DROP TABLE TStudies
IF OBJECT_ID('TGenders')					IS NOT NULL DROP TABLE TGenders
IF OBJECT_ID('TStates')						IS NOT NULL DROP TABLE TStates
IF OBJECT_ID('TVisitTypes')					IS NOT NULL DROP TABLE TVisitTypes
IF OBJECT_ID('TWithdrawReasons')			IS NOT NULL DROP TABLE TWithdrawReasons

-- --------------------------------------------------------------------------------
-- Drop Views
-- --------------------------------------------------------------------------------
IF OBJECT_ID('vPatientStudies')				IS NOT NULL DROP VIEW vPatientStudies
IF OBJECT_ID('vRandomPatients')				IS NOT NULL DROP VIEW vRandomPatients
IF OBJECT_ID('vStudy1Codes')				IS NOT NULL DROP VIEW vStudy1Codes
IF OBJECT_ID('vStudy2Codes')				IS NOT NULL DROP VIEW vStudy2Codes
IF OBJECT_ID('vStudy1AvailableDrugs')		IS NOT NULL DROP VIEW vStudy1AvailableDrugs
IF OBJECT_ID('vStudy2AvailableDrugs')		IS NOT NULL DROP VIEW vStudy2AvailableDrugs
IF OBJECT_ID('vWithdrawn')					IS NOT NULL DROP VIEW vWithdrawn
IF OBJECT_ID('vGetStudy2ActiveCodes')		IS NOT NULL DROP VIEW vGetStudy2ActiveCodes
IF OBJECT_ID('vGetStudy2PlaceboCodes')		IS NOT NULL DROP VIEW vGetStudy2PlaceboCodes

-- --------------------------------------------------------------------------------
-- Drop Stored Procedures
-- --------------------------------------------------------------------------------
IF OBJECT_ID('uspScreening')				IS NOT NULL DROP PROCEDURE uspScreening
IF OBJECT_ID('uspWithdrawal')				IS NOT NULL DROP PROCEDURE uspWithdrawal
IF OBJECT_ID('uspRandomization')			IS NOT NULL DROP PROCEDURE uspRandomization
IF OBJECT_ID('uspRandomCode')				IS NOT NULL DROP PROCEDURE uspRandomCode
IF OBJECT_ID('uspInsertRandomized')			IS NOT NULL DROP PROCEDURE uspInsertRandomized
IF OBJECT_ID('uspRandomizeStudy1')			IS NOT NULL DROP PROCEDURE uspRandomizeStudy1
IF OBJECT_ID('uspRandomizeStudy2')			IS NOT NULL DROP PROCEDURE uspRandomizeStudy2

-- --------------------------------------------------------------------------------
-- Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TStudies
(
	intStudyID								INTEGER IDENTITY		NOT NULL
   ,strStudyDesc							VARCHAR(250)			NOT NULL
   ,CONSTRAINT TStudies_PK PRIMARY KEY (intStudyID)
)

CREATE TABLE TGenders
(
	intGenderID								INTEGER IDENTITY		NOT NULL
   ,strGender								VARCHAR(250)			NOT NULL
   ,CONSTRAINT TGenders_PK PRIMARY KEY (intGenderID)
)

CREATE TABLE TStates
(
	intStateID								INTEGER IDENTITY		NOT NULL
   ,strStateDesc							VARCHAR(250)			NOT NULL
   ,CONSTRAINT TStates_PK PRIMARY KEY (intStateID)
)

CREATE TABLE TVisitTypes
(
	intVisitTypeID							INTEGER IDENTITY		NOT NULL
   ,strVisitDesc							VARCHAR(250)			NOT NULL
   ,CONSTRAINT TVisitTypes_PK PRIMARY KEY (intVisitTypeID)
)

CREATE TABLE TWithdrawReasons
(
	intWithdrawReasonID						INTEGER IDENTITY		NOT NULL
   ,strWithdrawDesc							VARCHAR(250)			NOT NULL
   ,CONSTRAINT TWithdrawReasons_PK PRIMARY KEY (intWithdrawReasonID)
)

CREATE TABLE TSites
(
	intSiteID								INTEGER IDENTITY		NOT NULL
   ,intSiteNumber							INTEGER					NOT NULL
   ,intStudyID								INTEGER					NOT NULL
   ,strName									VARCHAR(250)			NOT NULL
   ,strAddress								VARCHAR(250)			NOT NULL
   ,strCity									VARCHAR(250)			NOT NULL
   ,intStateID								INTEGER					NOT NULL
   ,strZip									VARCHAR(250)			NOT NULL
   ,strPhone								VARCHAR(250)			NOT NULL
   ,CONSTRAINT TSites_PK PRIMARY KEY (intSiteID)
)

CREATE TABLE TRandomCodes
(
	intRandomCodeID							INTEGER IDENTITY		NOT NULL
   ,intRandomCode							INTEGER					NOT NULL
   ,intStudyID								INTEGER					NOT NULL
   ,strTreatment							VARCHAR(1)				NOT NULL 
   ,blnAvailable							VARCHAR(1)				NOT NULL 
   ,CONSTRAINT TRandomCodes_PK PRIMARY KEY (intRandomCodeID)
   ,CONSTRAINT CK_RandomTreatment CHECK (strTreatment = 'A' OR strTreatment = 'P')
   ,CONSTRAINT CK_RandomAvailable CHECK (blnAvailable = 'T' OR blnAvailable = 'F')
)

CREATE TABLE TPatients
(
	intPatientID							INTEGER IDENTITY		NOT NULL
   ,intPatientNumber						INTEGER					NOT NULL
   ,intSiteID								INTEGER					NOT NULL
   ,dtmDOB									DATETIME				NOT NULL
   ,intGenderID								INTEGER					NOT NULL
   ,intWeight								INTEGER					NOT NULL
   ,intRandomCodeID							INTEGER					
   ,CONSTRAINT TPatients_PK PRIMARY KEY (intPatientID)
)

CREATE TABLE TVisits
(
	intVisitID								INTEGER IDENTITY		NOT NULL
   ,intPatientID							INTEGER					NOT NULL
   ,dtmVisit								DATETIME				NOT NULL
   ,intVisitTypeID							INTEGER					NOT NULL
   ,intWithdrawReasonID						INTEGER					
   ,CONSTRAINT TVisits_PK PRIMARY KEY (intVisitID)
)

CREATE TABLE TDrugKits
(
	intDrugKitID							INTEGER IDENTITY		NOT NULL
   ,intDrugKitNumber						INTEGER					NOT NULL
   ,intSiteID								INTEGER					NOT NULL
   ,strTreatment							VARCHAR(1)				NOT NULL 
   ,intVisitID								INTEGER					
   ,CONSTRAINT TDrugKits_PK PRIMARY KEY (intDrugKitID)
   ,CONSTRAINT CK_DrugTreatment CHECK (strTreatment = 'A' OR strTreatment = 'P')
)

-- --------------------------------------------------------------------------------
-- Identify and Create Foreign Keys
-- --------------------------------------------------------------------------------
--
-- #	Child								Parent						Column(s)
-- -	-----								------						---------
-- 1	TSites								TStudies					intStudyID
-- 2	TSites								TStates						intStateID
-- 3	TPatients							TSites						intSiteID
-- 4	TPatients							TGenders					intGenderID
-- 5	TPatients							TRandomCodes				intRandomCodeID
-- 6	TVisits								TPatients					intPatientID
-- 7	TVisits								TVisitTypes					intVisitTypeID
-- 8	TVisits								TWithdrawReasons			intWithdrawReasonID
-- 9	TRandomCodes						TStudies					intStudyID
-- 10	TDrugKits							TSites						intSiteID
-- 11	TDrugKits							TVisits						intVisitID

-- 1
ALTER TABLE TSites ADD CONSTRAINT TSites_TStudies_FK
FOREIGN KEY (intStudyID) REFERENCES TStudies (intStudyID)

-- 2
ALTER TABLE TSites ADD CONSTRAINT TSites_TStates_FK
FOREIGN KEY (intStateID) REFERENCES TStates (intStateID)

-- 3
ALTER TABLE TPatients ADD CONSTRAINT TPatients_TSites_FK
FOREIGN KEY (intSiteID) REFERENCES TSites (intSiteID)

-- 4
ALTER TABLE TPatients ADD CONSTRAINT TPatients_TGenders_FK
FOREIGN KEY (intGenderID) REFERENCES TGenders (intGenderID)

-- 5
ALTER TABLE TPatients ADD CONSTRAINT TPatients_TRandomCodes_FK
FOREIGN KEY (intRandomCodeID) REFERENCES TRandomCodes (intRandomCodeID)

-- 6
ALTER TABLE TVisits ADD CONSTRAINT TVisits_TPatients_FK
FOREIGN KEY (intPatientID) REFERENCES TPatients (intPatientID)

-- 7
ALTER TABLE TVisits ADD CONSTRAINT TVisits_TVisitTypes_FK
FOREIGN KEY (intVisitTypeID) REFERENCES TVisitTypes (intVisitTypeID)

-- 8
ALTER TABLE TVisits ADD CONSTRAINT TVisits_TWithdrawReasons_FK
FOREIGN KEY (intWithdrawReasonID) REFERENCES TWithdrawReasons (intWithdrawReasonID)

-- 9
ALTER TABLE TRandomCodes ADD CONSTRAINT TRandomCodes_TStudies_FK
FOREIGN KEY (intStudyID) REFERENCES TStudies (intStudyID)

-- 10
ALTER TABLE TDrugKits ADD CONSTRAINT TDrugKits_TSites_FK
FOREIGN KEY (intSiteID) REFERENCES TSites (intSiteID)

-- 11
ALTER TABLE TDrugKits ADD CONSTRAINT TDrugKits_TVisits_FK
FOREIGN KEY (intVisitID) REFERENCES TVisits (intVisitID)

-- --------------------------------------------------------------------------------
-- Insert Data
-- --------------------------------------------------------------------------------
INSERT INTO TStudies (strStudyDesc)
VALUES	('Study 12345')
	   ,('Study 54321')

INSERT INTO TVisitTypes (strVisitDesc)
VALUES	('Screening')
	   ,('Randomization')
	   ,('Withdrawal')

INSERT INTO TStates (strStateDesc)
VALUES	('Ohio')
	   ,('Kentucky')
	   ,('Indiana')
	   ,('New Jersey')
	   ,('Virginia')
	   ,('Georgia')
	   ,('Iowa')

INSERT INTO TSites (intSiteNumber, intStudyID, strName, strAddress, strCity, intStateID, strZip, strPhone)
VALUES	(101, 1, 'Dr. Stan Heinrich', '123 E. Main St', 'Atlanta', 6, '25869', '1234567890')
	   ,(111, 1, 'Mercy Hospital', '3456 Elmhurst Rd.', 'Secaucus', 4, '32659', '5013629564')
	   ,(121, 1, 'St. Elizabeth Hospital', '976 Jackson Way', 'Ft. Thomas', 2, '41258', '3026521478')
	   ,(501, 2, 'Dr. Robert Adler', '9087 W. Maple Ave.', 'Cedar Rapids', 7, '42365', '6149652574')
	   ,(511, 2, 'Dr. Tim Schmitz', '4539 Helena Run', 'Mason', 1, '45040', '5136987462')
	   ,(521, 2, 'Dr. Lawrence Snell', '9201 NW. Washington Blvd.', 'Bristol', 5, '20163', '3876510249')

INSERT INTO TRandomCodes (intRandomCode, intStudyID, strTreatment, blnAvailable)
VALUES	(1000, 1, 'A', 'T') -- Study #1
	   ,(1001, 1, 'P', 'T')
	   ,(1002, 1, 'A', 'T')
	   ,(1003, 1, 'P', 'T')
	   ,(1004, 1, 'P', 'T')
	   ,(1005, 1, 'A', 'T')
	   ,(1006, 1, 'A', 'T')
	   ,(1007, 1, 'P', 'T')
	   ,(1008, 1, 'A', 'T')
	   ,(1009, 1, 'P', 'T')
	   ,(1010, 1, 'P', 'T')
	   ,(1011, 1, 'A', 'T')
	   ,(1012, 1, 'P', 'T')
	   ,(1013, 1, 'A', 'T')
	   ,(1014, 1, 'A', 'T')
	   ,(1015, 1, 'A', 'T')
	   ,(1016, 1, 'P', 'T')
	   ,(1017, 1, 'P', 'T')
	   ,(1018, 1, 'A', 'T')
	   ,(1019, 1, 'P', 'T')
	   ,(5000, 2, 'A', 'T') -- Study #2
	   ,(5001, 2, 'A', 'T')
	   ,(5002, 2, 'A', 'T')
	   ,(5003, 2, 'A', 'T')
	   ,(5004, 2, 'A', 'T')
	   ,(5005, 2, 'A', 'T')
	   ,(5006, 2, 'A', 'T')
	   ,(5007, 2, 'A', 'T')
	   ,(5008, 2, 'A', 'T')
	   ,(5009, 2, 'A', 'T')
	   ,(5010, 2, 'P', 'T')
	   ,(5011, 2, 'P', 'T')
	   ,(5012, 2, 'P', 'T')
	   ,(5013, 2, 'P', 'T')
	   ,(5014, 2, 'P', 'T')
	   ,(5015, 2, 'P', 'T')
	   ,(5016, 2, 'P', 'T')
	   ,(5017, 2, 'P', 'T')
	   ,(5018, 2, 'P', 'T')
	   ,(5019, 2, 'P', 'T')

INSERT INTO TDrugKits (intDrugKitNumber, intSiteID, strTreatment, intVisitID)
VALUES	(10000, 1, 'A', NULL)
	   ,(10001, 1, 'A', NULL)
	   ,(10002, 1, 'A', NULL)
	   ,(10003, 1, 'P', NULL)
	   ,(10004, 1, 'P', NULL)
	   ,(10005, 1, 'P', NULL)
	   ,(10006, 2, 'A', NULL)
	   ,(10007, 2, 'A', NULL)
	   ,(10008, 2, 'A', NULL)
	   ,(10009, 2, 'P', NULL)
	   ,(10010, 2, 'P', NULL)
	   ,(10011, 2, 'P', NULL)
	   ,(10012, 3, 'A', NULL)
	   ,(10013, 3, 'A', NULL)
	   ,(10014, 3, 'A', NULL)
	   ,(10015, 3, 'P', NULL)
	   ,(10016, 3, 'P', NULL)
	   ,(10017, 3, 'P', NULL)
	   ,(10018, 4, 'A', NULL)
	   ,(10019, 4, 'A', NULL)
	   ,(10020, 4, 'A', NULL)
	   ,(10021, 4, 'P', NULL)
	   ,(10022, 4, 'P', NULL)
	   ,(10023, 4, 'P', NULL)
	   ,(10024, 5, 'A', NULL)
	   ,(10025, 5, 'A', NULL)
	   ,(10026, 5, 'A', NULL)
	   ,(10027, 5, 'P', NULL)
	   ,(10028, 5, 'P', NULL)
	   ,(10029, 5, 'P', NULL)
	   ,(10030, 6, 'A', NULL)
	   ,(10031, 6, 'A', NULL)
	   ,(10032, 6, 'A', NULL)
	   ,(10033, 6, 'P', NULL)
	   ,(10034, 6, 'P', NULL)
	   ,(10035, 6, 'P', NULL)

INSERT INTO TWithdrawReasons (strWithdrawDesc)
VALUES	('Patient withdrew consent')
	   ,('Adverse event')
	   ,('Health issue - related to study')
	   ,('Health issue - unrelated to study')
	   ,('Personal reason')
	   ,('Completed the study')

INSERT INTO TGenders (strGender)
VALUES	('Male')
	   ,('Female')

-- --------------------------------------------------------------------------------
-- Step 2: Create the view that will show all patients at all sites for both studies. 
-- You can do this together or 1 view for each study.
-- --------------------------------------------------------------------------------
GO
CREATE VIEW vPatientStudies
AS
	SELECT
		TP.intPatientNumber
	   ,TS.strName
	   ,TS.intSiteNumber
	   ,TSD.strStudyDesc
	FROM
		TPatients as TP JOIN TSites as TS
			ON TP.intSiteID = TS.intSiteID
		JOIN TStudies as TSD
			ON TSD.intStudyID = TS.intStudyID
GO

-- --------------------------------------------------------------------------------
-- Step 3: Create the view that will show all randomized patients, their site and 
-- their treatment for both studies. You can do this together or 1 view for each study.
-- --------------------------------------------------------------------------------
GO
CREATE VIEW vRandomPatients
AS
	SELECT
		TP.intPatientNumber
	   ,TS.strName
	   ,TR.strTreatment
	   ,TSD.intStudyID
	FROM
		TPatients as TP JOIN TSites as TS
			ON TP.intSiteID = TS.intSiteID
		JOIN TStudies as TSD
			ON TSD.intStudyID = TS.intStudyID
		JOIN TRandomCodes as TR
			ON TR.intRandomCodeID = TP.intRandomCodeID
	WHERE 
		TP.intRandomCodeID IS NOT NULL 
GO

-- --------------------------------------------------------------------------------
-- Step 4: Create the view that will show the next available random codes (MIN) for 
-- both studies. This should be 2 separate views as the first study only gets the 
-- next ID and the second study needs the next ID for each treatment.
-- --------------------------------------------------------------------------------
GO
CREATE VIEW vStudy1Codes
AS
	SELECT TOP 1
		intRandomCodeID
	   ,intStudyID
	   ,strTreatment
	FROM 
		TRandomCodes 
	WHERE 
		intStudyID = 1 and blnAvailable = 'T'
GO

GO
CREATE VIEW vGetStudy2ActiveCodes
AS
	SELECT TOP 1
		MIN(intRandomCodeID) as intActiveCodeID
	   ,intRandomCode as ActiveCode
	   ,strTreatment as ActiveTreatment
	   ,intStudyID as ActiveStudyID
	   ,blnAvailable as ActiveAvailable
	FROM
		TRandomCodes
	WHERE
		intStudyID = 2 AND strTreatment = 'A' AND blnAvailable = 'T'
	GROUP BY
		intRandomCode
	   ,strTreatment
	   ,intStudyID
	   ,blnAvailable
GO

CREATE VIEW vGetStudy2PlaceboCodes
AS
	SELECT TOP 1
		MIN(intRandomCodeID) as intPlaceboCodeID
	   ,intRandomCode as PlaceboCode
	   ,strTreatment as PlaceboTreatment
	   ,intStudyID as PlaceboStudyID
	   ,blnAvailable as PlaceboAvailable
	FROM
		TRandomCodes
	WHERE
		intStudyID = 2 AND strTreatment = 'P' AND blnAvailable = 'T'
	GROUP BY 
		intRandomCode
	   ,strTreatment
	   ,intStudyID
	   ,blnAvailable
GO

GO
CREATE VIEW vStudy2Codes
AS
	SELECT TOP 1
		MIN(VA.intActiveCodeID) as ActiveCodeID
	   ,VA.ActiveCode
	   ,VA.ActiveTreatment
	   ,VA.ActiveStudyID
	   ,VA.ActiveAvailable
	   ,MIN(VP.intPlaceboCodeID) as PlaceboCodeID
	   ,VP.PlaceboCode
	   ,VP.PlaceboTreatment
	   ,VP.PlaceboStudyID
	   ,VP.PlaceboAvailable
	FROM
		vGetStudy2ActiveCodes as VA, vGetStudy2PlaceboCodes as VP, TRandomCodes as TR
	WHERE
		intStudyID = 2 AND blnAvailable = 'T'
	GROUP BY
		VA.ActiveCode
	   ,VA.ActiveTreatment
	   ,VA.ActiveStudyID
	   ,VA.ActiveAvailable
	   ,VP.PlaceboCode
	   ,VP.PlaceboTreatment
	   ,VP.PlaceboStudyID
	   ,VP.PlaceboAvailable
GO

-- --------------------------------------------------------------------------------
-- Step 5: Create the view that will show all available drug at all sites for both 
-- studies. You can do this together or 1 view for each study.
-- --------------------------------------------------------------------------------
GO
CREATE VIEW vStudy1AvailableDrugs
AS
	SELECT
		TDK.intDrugKitID
	   ,TDK.intDrugKitNumber
	   ,TS.intSiteID
	   ,TDK.strTreatment
	   ,TSD.strStudyDesc
	FROM
		TDrugKits as TDK JOIN TSites as TS
			ON TDK.intSiteID = TS.intSiteID
		JOIN TStudies as TSD
			ON TSD.intStudyID = TS.intStudyID
	WHERE 
		TS.intStudyID = 1 AND TDK.intVisitID IS NULL
GO

CREATE VIEW vStudy2AvailableDrugs
AS
	SELECT
	    TDK.intDrugKitID
	   ,TDK.intDrugKitNumber
	   ,TS.intSiteID
	   ,TDK.strTreatment
	   ,TSD.strStudyDesc
	FROM
		TDrugKits as TDK JOIN TSites as TS
			ON TDK.intSiteID = TS.intSiteID
		JOIN TStudies as TSD
			ON TSD.intStudyID = TS.intStudyID
	WHERE 
		TS.intStudyID = 2 AND TDK.intVisitID IS NULL
GO
	
-- --------------------------------------------------------------------------------
-- Step 6: Create the view that will show all withdrawn patients, their site, 
-- withdrawal date and withdrawal reason for both studies.
-- --------------------------------------------------------------------------------
GO
CREATE VIEW vWithdrawn
AS
	SELECT
		TP.intPatientNumber
	   ,TS.strName
	   ,TV.dtmVisit
	   ,TWR.strWithdrawDesc
	   ,TSD.strStudyDesc
	FROM
		TVisits as TV JOIN TPatients as TP
			ON TV.intPatientID = TP.intPatientID
		JOIN TWithdrawReasons as TWR
			ON TWR.intWithdrawReasonID = TV.intWithdrawReasonID
		JOIN TSites as TS
			ON TS.intSiteID = TP.intSiteID
		JOIN TStudies as TSD
			ON TSD.intStudyID = TS.intStudyID
	WHERE
		TV.intWithdrawReasonID IS NOT NULL
GO

-- --------------------------------------------------------------------------------
-- Step 8: Create the stored procedure(s) that will screen a patient for both studies. 
-- You can do this together or 1 for each study.
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspScreening
	@intPatientID		AS INTEGER OUTPUT
   ,@intVisitID			AS INTEGER OUTPUT
   ,@intPatientNumber	AS INTEGER
   ,@intSiteID			AS INTEGER
   ,@dtmDOB				AS DATETIME
   ,@intGenderID		AS INTEGER
   ,@intWeight			AS INTEGER
   ,@dtmVisit			AS DATETIME
AS

SET XACT_ABORT ON --terminate and rollback if any errors

BEGIN TRANSACTION

	-- Insert into TPatients
	INSERT INTO TPatients WITH (TABLOCKX) (intPatientNumber, intSiteID, dtmDOB, intGenderID, intWeight)
	VALUES	(@intPatientNumber, @intSiteID, @dtmDOB, @intGenderID, @intWeight)

	SELECT @intPatientID = MAX(intPatientID) FROM TPatients

	-- Insert into TVisits
	INSERT INTO TVisits WITH (TABLOCKX) (intPatientID, dtmVisit, intVisitTypeID)
	VALUES	(@intPatientID, @dtmVisit, 1)

	SELECT @intVisitID = MAX(intVisitID) FROM TVisits

COMMIT TRANSACTION

GO

-- --------------------------------------------------------------------------------
-- Step 9: Create the stored procedure(s) that will withdraw a patient for both studies. 
-- You can do this together or 1 for each study. Remember a patient can go from Screening 
-- Visit to Withdrawal without being randomized. This will be up to the Doctor. 
-- Your code just has to be able to do it.
-- --------------------------------------------------------------------------------
GO
CREATE PROCEDURE uspWithdrawal
	@intVisitID				AS INTEGER OUTPUT
   ,@intPatientID			AS INTEGER
   ,@dtmVisit				AS DATETIME
   ,@intWithdrawReasonID	AS INTEGER
AS

SET XACT_ABORT ON --terminate and rollback if any errors

BEGIN TRANSACTION
	-- Validate the withdrawal visit date and make sure they aren't already withdrawn
	IF @dtmVisit > (SELECT TOP 1 dtmVisit FROM TVisits WHERE intPatientID = @intPatientID)
		IF (SELECT TOP 1 intVisitTypeID FROM TVisits WHERE intPatientID = @intPatientID) = 3
		BEGIN
			PRINT 'Patient has already been withdrawn.'
			ROLLBACK TRANSACTION
			RETURN -- Exit the stored procedure
		END
		ELSE
			-- Insert into TVisits to show that the patient withdrawed 
			INSERT INTO TVisits (intPatientID, dtmVisit, intVisitTypeID, intWithdrawReasonID)
			VALUES	(@intPatientID, @dtmVisit, 3, @intWithdrawReasonID)

			SELECT @intVisitID = MAX(intVisitID) FROM TVisits 

COMMIT TRANSACTION

GO

-- --------------------------------------------------------------------------------
-- Step 10: Create the stored procedure(s) that will randomize a patient for both 
-- studies. You can do this together or 1 for each study. This will include a stored 
-- procedure for obtaining a random code as well as a drug kit. 
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspRandomCode
	@intRandomCodeID	AS INTEGER OUTPUT
   ,@intDrugKitID		AS INTEGER OUTPUT
   ,@strTreatment		AS VARCHAR(1) OUTPUT
   ,@strDrugTreatment	AS VARCHAR(1) OUTPUT
   ,@intStudyID			AS INTEGER
   ,@intPatientID		AS INTEGER
AS

SET XACT_ABORT ON --terminate and rollback if any errors

BEGIN
	-- Check if study # is 2
	IF @intStudyID = 2
	BEGIN
		-- Declare variables
		DECLARE @decRandom AS DECIMAL(6,2)
		DECLARE @intSiteID AS INTEGER

		-- Match site ID with patient site ID
		SET @intSiteID = (SELECT intSiteID FROM TPatients WHERE intPatientID = @intPatientID)

		-- Set random number
		SET @decRandom = RAND()
	
		IF @decRandom <= 0.5
		BEGIN
			-- Choose placebo treatment
			-- Create cursor to grab min placebo treatment
			DECLARE PlaceboCursor CURSOR LOCAL FOR
			SELECT TOP 1 MIN(PlaceboCodeID), PlaceboTreatment FROM vStudy2Codes
			WHERE PlaceboStudyID = @intStudyID AND PlaceboTreatment = 'P' AND PlaceboAvailable = 'T'
			GROUP BY PlaceboTreatment

			OPEN PlaceboCursor

			FETCH FROM PlaceboCursor
			INTO @intRandomCodeID, @strTreatment

			CLOSE PlaceboCursor

			-- Create a cursor to get a drug kit
			DECLARE GetDrugKit CURSOR LOCAL FOR
			SELECT MIN(intDrugKitID), strTreatment FROM vStudy2AvailableDrugs
			WHERE strTreatment = 'P' and intSiteID = @intSiteID
			GROUP BY strTreatment

			OPEN GetDrugKit

			FETCH FROM GetDrugKit
			INTO @intDrugKitID, @strDrugTreatment 

			CLOSE GetDrugKit

			-- Match it with a drug kit
			IF @strTreatment = @strDrugTreatment
				SET @intRandomCodeID = @intRandomCodeID
				SET @intDrugKitID = @intDrugKitID
				SET @strTreatment = @strTreatment
				SET @strDrugTreatment = @strDrugTreatment
		END

		IF @decRandom > 0.5
		BEGIN
			-- Choose active treatment
			-- Create cursor to grab min active treatment
			DECLARE ActiveCursor CURSOR LOCAL FOR
			SELECT TOP 1 MIN(ActiveCodeID), ActiveTreatment FROM vStudy2Codes
			WHERE ActiveStudyID = @intStudyID AND ActiveTreatment = 'A' and ActiveAvailable = 'T'
			GROUP BY ActiveTreatment

			OPEN ActiveCursor

			FETCH FROM ActiveCursor
			INTO @intRandomCodeID, @strTreatment

			CLOSE ActiveCursor

			-- Create a cursor to get a drug kit
			DECLARE ActiveDrug CURSOR LOCAL FOR
			SELECT MIN(intDrugKitID), strTreatment FROM vStudy2AvailableDrugs
			WHERE strTreatment = 'A' AND intSiteID = @intSiteID
			GROUP BY strTreatment

			OPEN ActiveDrug

			FETCH FROM ActiveDrug
			INTO @intDrugKitID, @strDrugTreatment

			CLOSE ActiveDrug

			-- Match it with a drug kit
			IF @strTreatment = @strDrugTreatment
				SET @intRandomCodeID = @intRandomCodeID
				SET @intDrugKitID = @intDrugKitID
				SET @strTreatment = @strTreatment
				SET @strDrugTreatment = @strDrugTreatment
		END
	END
END

GO

-- This procedure will insert randomized patients and update the tables accordingly
CREATE PROCEDURE uspInsertRandomized
	@intVisitID			AS INTEGER OUTPUT
   ,@intPatientID		AS INTEGER
   ,@intRandomCodeID	AS INTEGER
   ,@intDrugKitID		AS INTEGER
AS

SET XACT_ABORT ON -- Terminate and rollback if needed
BEGIN TRANSACTION
	-- Insert into TVisits to show randomization visit
	INSERT INTO TVisits WITH (TABLOCKX) (intPatientID, dtmVisit, intVisitTypeID)
	VALUES	(@intPatientID, GETDATE(), 2)

	SELECT @intVisitID = MAX(intVisitID) FROM TVisits

	-- Update TPatients to show random code
	UPDATE TPatients
	SET intRandomCodeID = @intRandomCodeID
	WHERE intPatientID = @intPatientID

	-- Update TDrugKits to assign a visitID
	UPDATE TDrugKits 
	SET intVisitID = @intVisitID
	WHERE intDrugKitID = @intDrugKitID

	-- Update TRandomCodes to change availability
	UPDATE TRandomCodes
	SET blnAvailable = 'F'
	WHERE intRandomCodeID = @intRandomCodeID
COMMIT TRANSACTION

GO
-- This procedure will randomize study 1 patients
CREATE PROCEDURE uspRandomizeStudy1
	@intPatientID	AS INTEGER
   ,@intStudyID		AS INTEGER
AS

SET XACT_ABORT ON --terminate and rollback if any errors

BEGIN TRANSACTION
	-- Declare variables
	DECLARE @intRandomCodeID	AS INTEGER
	DECLARE @strTreatment		AS VARCHAR(1)
	DECLARE @intDrugKitID		AS INTEGER
	DECLARE @strDrugTreatment	AS VARCHAR(1)
	DECLARE @intVisitID			AS INTEGER
	DECLARE @intSiteID			AS INTEGER

	-- Study 1 Random Codes
	IF @intStudyID = 1
	BEGIN

		-- Match site ID with patient site ID
		SET @intSiteID = (SELECT intSiteID FROM TPatients WHERE intPatientID = @intPatientID)

		-- Create cursor for vStudy1Codes
		DECLARE GetRandomCode CURSOR LOCAL FOR
		SELECT TOP 1 intRandomCodeID, strTreatment FROM vStudy1Codes
		WHERE intStudyID = 1

		OPEN GetRandomCode

		FETCH FROM GetRandomCode
		INTO @intRandomCodeID, @strTreatment

		CLOSE GetRandomCode

		-- Create cursor for vStudy1AvailableDrugs
		DECLARE GetDrugKit CURSOR LOCAL FOR
		SELECT TOP 1 MIN(intDrugKitID), strTreatment FROM vStudy1AvailableDrugs
		WHERE intSiteID = @intSiteID AND strTreatment = @strTreatment
		GROUP BY strTreatment

		OPEN GetDrugKit

		FETCH FROM GetDrugKit
		INTO @intDrugKitID, @strDrugTreatment

		CLOSE GetDrugKit

		-- Match the random code treatment with the drug kit treatment
		IF @strTreatment = @strDrugTreatment
		BEGIN
			-- Insert data using uspInsertRandomized
			EXECUTE uspInsertRandomized @intVisitID OUTPUT, @intPatientID, @intRandomCodeID, @intDrugKitID
		END

		-- Rollback transaction if treatments do not match
		IF @strTreatment != @strDrugTreatment
		BEGIN
			PRINT 'Treatments do not match or are not available.'
			ROLLBACK TRANSACTION
			RETURN -- Exit the stored procedure
		END
	END
COMMIT TRANSACTION

GO
-- This procedure will randomize study 2 patients
CREATE PROCEDURE uspRandomizeStudy2
	@intPatientID	AS INTEGER
   ,@intStudyID		AS INTEGER
AS

SET XACT_ABORT ON --terminate and rollback if any errors

BEGIN TRANSACTION
	-- Declare variables
	DECLARE @intRandomCodeID	AS INTEGER
	DECLARE @strTreatment		AS VARCHAR(1)
	DECLARE @intDrugKitID		AS INTEGER
	DECLARE @strDrugTreatment	AS VARCHAR(1)
	DECLARE @intVisitID			AS INTEGER

	IF @intStudyID = 2
		-- Declare variables
		DECLARE @intActive		AS INTEGER
		DECLARE @intPlacebo		AS INTEGER

		-- Execute uspRandomCode and get a matching random code/drug kit
		EXECUTE uspRandomCode @intRandomCodeID OUTPUT, @intDrugKitID OUTPUT, 
		@strTreatment OUTPUT, @strDrugTreatment OUTPUT, 2, @intPatientID

		-- See how many randomized active patients there are
		SET @intActive = (SELECT COUNT(strTreatment) FROM vRandomPatients WHERE intStudyID = 2 AND strTreatment = 'A')

		-- See how many randomized placebo patients there are
		SET @intPlacebo = (SELECT COUNT(strTreatment) FROM vRandomPatients WHERE intStudyID = 2 AND strTreatment = 'P')
			
		-- If the difference between Active/Placebo is more than 2, get a Placebo drug
		IF (@intActive - @intPlacebo) >= 2
		BEGIN
			-- Execute uspRandomCode until a placebo drug is chosen
			WHILE @strTreatment = 'A' AND @strDrugTreatment = 'A'
			BEGIN
				EXECUTE uspRandomCode @intRandomCodeID OUTPUT, @intDrugKitID OUTPUT, 
				@strTreatment OUTPUT, @strDrugTreatment OUTPUT, 2, @intPatientID

				IF @strTreatment = 'P' and @strDrugTreatment = 'P'
					BREAK -- Exit the loop
			END

			-- Match the random code with the random drug
			IF @strTreatment = @strDrugTreatment
			BEGIN
				-- Insert data using uspInsertRandomized
				EXECUTE uspInsertRandomized @intVisitID OUTPUT, @intPatientID, @intRandomCodeID, @intDrugKitID
			END

			-- Rollback transaction if treatments do not match
			IF @strTreatment != @strDrugTreatment
			BEGIN
				PRINT 'Treatments do not match or are not available.'
				ROLLBACK TRANSACTION
				RETURN -- Exit the stored procedure
			END
		END

		-- If the difference between Placebo/Active is more than 2, get an Active drug
		IF (@intPlacebo - @intActive) >= 2
		BEGIN
			-- Execute uspRandomCode until an active drug is chosen
			WHILE @strTreatment = 'P' AND @strDrugTreatment = 'P'
			BEGIN 
				EXECUTE uspRandomCode @intRandomCodeID OUTPUT, @intDrugKitID OUTPUT, 
				@strTreatment OUTPUT, @strDrugTreatment OUTPUT, 2, @intPatientID
				
				IF @strTreatment = 'A' and @strDrugTreatment = 'A'
					BREAK -- Exit the loop
			END

			-- Match the random code treatment with the random drug treatment
			IF @strTreatment = @strDrugTreatment
			BEGIN
				-- Insert data using uspInsertRandomized
				EXECUTE uspInsertRandomized @intVisitID OUTPUT, @intPatientID, @intRandomCodeID, @intDrugKitID
			END

			-- Rollback transaction if treatments do not match
			IF @strTreatment != @strDrugTreatment
			BEGIN
				PRINT 'Treatments do not match or are not available.'
				ROLLBACK TRANSACTION
				RETURN -- Exit the stored procedure
			END
		END
		ELSE
			-- Match the random code treatment with the random drug treatment
			IF @strTreatment = @strDrugTreatment
			BEGIN
				-- Insert data using uspInsertRandomized
				EXECUTE uspInsertRandomized @intVisitID OUTPUT, @intPatientID, @intRandomCodeID, @intDrugKitID
			END
COMMIT TRANSACTION

GO
-- This procedure will call the approriate sprocs to randomize patients for both studies
CREATE PROCEDURE uspRandomization
	@intPatientID	AS INTEGER
   ,@intStudyID		AS INTEGER
AS

SET XACT_ABORT ON --terminate and rollback if any errors

BEGIN TRANSACTION

	-- Randomize patients for study 1
	EXECUTE uspRandomizeStudy1 @intPatientID, @intStudyID

	-- Randomize patients for study 2
	EXECUTE uspRandomizeStudy2 @intPatientID, @intStudyID

COMMIT TRANSACTION