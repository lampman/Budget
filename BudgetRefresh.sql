USE BUDGET;
DELETE FROM USBANK_CHECK_INPUT;
COMMIT;
LOAD DATA INFILE "/Applications/MAMP/db/mysql/check.csv"
INTO TABLE USBANK_CHECK_INPUT
COLUMNS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
COMMIT;
DELETE FROM USBANK_SAVE_INPUT;
COMMIT;
LOAD DATA INFILE "/Applications/MAMP/db/mysql/save.csv"
INTO TABLE USBANK_SAVE_INPUT
COLUMNS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
COMMIT;
DELETE FROM USBANK_BROCK_INPUT;
COMMIT;
LOAD DATA INFILE "/Applications/MAMP/db/mysql/brock.csv"
INTO TABLE USBANK_BROCK_INPUT
COLUMNS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
COMMIT;
DELETE FROM USBANK_MEGAN_INPUT;
COMMIT;
LOAD DATA INFILE "/Applications/MAMP/db/mysql/megan.csv"
INTO TABLE USBANK_MEGAN_INPUT
COLUMNS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
COMMIT;
DELETE FROM CAP_ONE_INPUT;
COMMIT;
LOAD DATA INFILE "/Applications/MAMP/db/mysql/cap_one.csv"
INTO TABLE CAP_ONE_INPUT
COLUMNS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
COMMIT;
UPDATE CAP_ONE_INPUT
SET trans_amount = CASE WHEN TRIM(trans_credit) = '' THEN CONCAT('-',TRIM(trans_debit))
                        WHEN TRIM(trans_credit) <> '' THEN TRIM(trans_credit) END;
COMMIT;
DELETE FROM CHASE_INPUT;
COMMIT;
LOAD DATA INFILE "/Applications/MAMP/db/mysql/chase.csv"
INTO TABLE CHASE_INPUT
COLUMNS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
COMMIT;
DELETE FROM PAYEE;
COMMIT;
INSERT INTO PAYEE(payee_memo_name)
SELECT DISTINCT CASE WHEN TRIM(SUBSTR(t1.trans_memo,27)) = '' THEN TRIM(t1.trans_name) 
					 WHEN TRIM(SUBSTR(t1.trans_memo,27)) <> '' THEN TRIM(SUBSTR(t1.trans_memo,27)) END
                       FROM USBANK_CHECK_INPUT AS t1
					   WHERE ((TRIM(SUBSTR(t1.trans_memo,27)) <> '' AND 
                               TRIM(SUBSTR(t1.trans_memo,27)) NOT IN (SELECT t2.payee_memo_name
																	  FROM PAYEE t2))
							  OR
	                          (TRIM(SUBSTR(t1.trans_memo,27)) = '' AND 
                               TRIM(t1.trans_name)  NOT IN (SELECT t2.payee_memo_name
															FROM PAYEE t2)));
COMMIT;
INSERT INTO PAYEE(payee_memo_name)
SELECT DISTINCT CASE WHEN TRIM(SUBSTR(t1.trans_memo,27)) = '' THEN TRIM(t1.trans_name) 
					 WHEN TRIM(SUBSTR(t1.trans_memo,27)) <> '' THEN TRIM(SUBSTR(t1.trans_memo,27)) END
                       FROM USBANK_SAVE_INPUT AS t1
					   WHERE ((TRIM(SUBSTR(t1.trans_memo,27)) <> '' AND 
                               TRIM(SUBSTR(t1.trans_memo,27)) NOT IN (SELECT t2.payee_memo_name
																	  FROM PAYEE t2))
							  OR
	                          (TRIM(SUBSTR(t1.trans_memo,27)) = '' AND 
                               TRIM(t1.trans_name)  NOT IN (SELECT t2.payee_memo_name
															FROM PAYEE t2)));
COMMIT;
INSERT INTO PAYEE(payee_memo_name)
SELECT DISTINCT CASE WHEN TRIM(SUBSTR(t1.trans_memo,27)) = '' THEN TRIM(t1.trans_name) 
					 WHEN TRIM(SUBSTR(t1.trans_memo,27)) <> '' THEN TRIM(SUBSTR(t1.trans_memo,27)) END
                       FROM USBANK_BROCK_INPUT AS t1
					   WHERE ((TRIM(SUBSTR(t1.trans_memo,27)) <> '' AND 
                               TRIM(SUBSTR(t1.trans_memo,27)) NOT IN (SELECT t2.payee_memo_name
																	  FROM PAYEE t2))
							  OR
	                          (TRIM(SUBSTR(t1.trans_memo,27)) = '' AND 
                               TRIM(t1.trans_name)  NOT IN (SELECT t2.payee_memo_name
															FROM PAYEE t2)));
COMMIT;
INSERT INTO PAYEE(payee_memo_name)
SELECT DISTINCT CASE WHEN TRIM(SUBSTR(t1.trans_memo,27)) = '' THEN TRIM(t1.trans_name) 
					 WHEN TRIM(SUBSTR(t1.trans_memo,27)) <> '' THEN TRIM(SUBSTR(t1.trans_memo,27)) END
                       FROM USBANK_MEGAN_INPUT AS t1
					   WHERE ((TRIM(SUBSTR(t1.trans_memo,27)) <> '' AND 
                               TRIM(SUBSTR(t1.trans_memo,27)) NOT IN (SELECT t2.payee_memo_name
																	  FROM PAYEE t2))
							  OR
	                          (TRIM(SUBSTR(t1.trans_memo,27)) = '' AND 
                               TRIM(t1.trans_name)  NOT IN (SELECT t2.payee_memo_name
															FROM PAYEE t2)));
COMMIT;
INSERT INTO PAYEE(payee_memo_name)
SELECT DISTINCT TRIM(t1.trans_memo) 
FROM CAP_ONE_INPUT AS t1
WHERE TRIM(t1.trans_memo) NOT IN (SELECT t2.payee_memo_name
								  FROM PAYEE t2);
COMMIT;
INSERT INTO PAYEE(payee_memo_name)
SELECT DISTINCT TRIM(t1.trans_memo) 
FROM CHASE_INPUT AS t1
WHERE TRIM(t1.trans_memo) NOT IN (SELECT t2.payee_memo_name
								  FROM PAYEE t2);
COMMIT;
