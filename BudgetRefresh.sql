USE BUDGET;
/* Reload OFX Stage Tables from local dir*/
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
UPDATE USBANK_CHECK_INPUT t1
SET t1.account_id = (SELECT MAX(t2.account_id)
                     FROM ACCOUNT t2
                     WHERE t2.account_name = 'USBANK Checking');
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
UPDATE USBANK_SAVE_INPUT t1
SET t1.account_id = (SELECT MAX(t2.account_id)
                     FROM ACCOUNT t2
                     WHERE t2.account_name = 'USBANK Savings');
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
UPDATE USBANK_BROCK_INPUT t1
SET t1.account_id = (SELECT MAX(t2.account_id)
                     FROM ACCOUNT t2
                     WHERE t2.account_name = 'USBANK Brock');
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
UPDATE USBANK_MEGAN_INPUT t1
SET t1.account_id = (SELECT MAX(t2.account_id)
                     FROM ACCOUNT t2
                     WHERE t2.account_name = 'USBANK Megan');
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
UPDATE CAP_ONE_INPUT t1
SET t1.account_id = (SELECT MAX(t2.account_id)
                     FROM ACCOUNT t2
                     WHERE t2.account_name = 'Capital One');
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
UPDATE CHASE_INPUT t1
SET t1.account_id = (SELECT MAX(t2.account_id)
                     FROM ACCOUNT t2
                     WHERE t2.account_name = 'Chase');
COMMIT;

/*Standardizing Transaction Amounts*/
UPDATE CAP_ONE_INPUT
SET trans_amount = CASE WHEN TRIM(trans_credit) = '' THEN CONCAT('-',TRIM(trans_debit))
                        WHEN TRIM(trans_credit) <> '' THEN TRIM(trans_credit) END;
COMMIT;

/*Logging any new Payee records*/
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
UPDATE USBANK_CHECK_INPUT t1
SET t1.payee_id = (SELECT MAX(t2.payee_id)
				   FROM PAYEE t2
                   WHERE t2.payee_memo_name IN (TRIM(SUBSTR(t1.trans_memo,27)), TRIM(t1.trans_name)));
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
UPDATE USBANK_SAVE_INPUT t1
SET t1.payee_id = (SELECT MAX(t2.payee_id)
				   FROM PAYEE t2
                   WHERE t2.payee_memo_name IN (TRIM(SUBSTR(t1.trans_memo,27)), TRIM(t1.trans_name)));
COMMIT;

INSERT INTO PAYEE(payee_memo_name)
SELECT DISTINCT TRIM(t1.trans_name)
FROM USBANK_BROCK_INPUT AS t1
WHERE TRIM(t1.trans_name)  NOT IN (SELECT t2.payee_memo_name
								   FROM PAYEE t2);
COMMIT;
UPDATE USBANK_BROCK_INPUT t1
SET t1.payee_id = (SELECT MAX(t2.payee_id)
				   FROM PAYEE t2
                   WHERE t2.payee_memo_name =TRIM(t1.trans_name));
COMMIT;

INSERT INTO PAYEE(payee_memo_name)
SELECT DISTINCT TRIM(t1.trans_name)
FROM USBANK_MEGAN_INPUT AS t1
WHERE TRIM(t1.trans_name)  NOT IN (SELECT t2.payee_memo_name
								   FROM PAYEE t2);
COMMIT;
UPDATE USBANK_MEGAN_INPUT t1
SET t1.payee_id = (SELECT MAX(t2.payee_id)
				   FROM PAYEE t2
                   WHERE t2.payee_memo_name =TRIM(t1.trans_name));
COMMIT;

INSERT INTO PAYEE(payee_memo_name)
SELECT DISTINCT TRIM(t1.trans_memo) 
FROM CAP_ONE_INPUT AS t1
WHERE TRIM(t1.trans_memo) NOT IN (SELECT t2.payee_memo_name
								  FROM PAYEE t2);
COMMIT;
UPDATE CAP_ONE_INPUT t1
SET t1.payee_id = (SELECT MAX(t2.payee_id)
				   FROM PAYEE t2
                   WHERE t2.payee_memo_name = TRIM(t1.trans_memo));
COMMIT;

INSERT INTO PAYEE(payee_memo_name)
SELECT DISTINCT TRIM(t1.trans_memo) 
FROM CHASE_INPUT AS t1
WHERE TRIM(t1.trans_memo) NOT IN (SELECT t2.payee_memo_name
								  FROM PAYEE t2);
COMMIT;
UPDATE CHASE_INPUT t1
SET t1.payee_id = (SELECT MAX(t2.payee_id)
				   FROM PAYEE t2
                   WHERE t2.payee_memo_name = TRIM(t1.trans_memo));
COMMIT;

/*Grabbing the event _id forLegacy Transactions*/

UPDATE USBANK_CHECK_INPUT t1
SET t1.event_id = (SELECT MAX(t2.event_id)
                   FROM TRANS t2
                   WHERE CAST(t2.amount as CHAR) = CAST(t1.trans_amount as CHAR)
                     AND CAST(t2.trans_date AS CHAR) = CAST(t1.trans_date AS CHAR)
                     AND t2.payee_id = t1.payee_id
                     AND t2.account_id = t2.account_id);
COMMIT;
UPDATE USBANK_SAVE_INPUT t1
SET t1.event_id = (SELECT MAX(t2.event_id)
                   FROM TRANS t2
                   WHERE CAST(t2.amount as CHAR) = CAST(t1.trans_amount as CHAR)
                     AND CAST(t2.trans_date AS CHAR) = CAST(t1.trans_date AS CHAR)
                     AND t2.payee_id = t1.payee_id
                     AND t2.account_id = t2.account_id);
COMMIT;
UPDATE USBANK_BROCK_INPUT t1
SET t1.event_id = (SELECT MAX(t2.event_id)
                   FROM TRANS t2
                   WHERE CAST(t2.amount as CHAR) = CAST(t1.trans_amount as CHAR)
                     AND CAST(t2.trans_date AS CHAR) = CAST(t1.trans_date AS CHAR)
                     AND t2.payee_id = t1.payee_id
                     AND t2.account_id = t2.account_id);
COMMIT;
UPDATE USBANK_MEGAN_INPUT t1
SET t1.event_id = (SELECT MAX(t2.event_id)
                   FROM TRANS t2
                   WHERE CAST(t2.amount as CHAR) = CAST(t1.trans_amount as CHAR)
                     AND CAST(t2.trans_date AS CHAR) = CAST(t1.trans_date AS CHAR)
                     AND t2.payee_id = t1.payee_id
                     AND t2.account_id = t2.account_id);
COMMIT;
UPDATE CHASE_INPUT t1
SET t1.event_id = (SELECT MAX(t2.event_id)
                   FROM TRANS t2
                   WHERE CAST(t2.amount as CHAR) = CAST(t1.trans_amount as CHAR)
                     AND CAST(t2.trans_date AS CHAR) = CAST(t1.trans_date AS CHAR)
                     AND t2.payee_id = t1.payee_id
                     AND t2.account_id = t2.account_id);
COMMIT;
UPDATE CAP_ONE_INPUT t1
SET t1.event_id = (SELECT MAX(t2.event_id)
                   FROM TRANS t2
                   WHERE CAST(t2.amount as CHAR) = CAST(t1.trans_amount as CHAR)
                     AND CAST(t2.trans_date AS CHAR) = CAST(t1.trans_date AS CHAR)
                     AND t2.payee_id = t1.payee_id
                     AND t2.account_id = t2.account_id);
COMMIT;

/*Replacing Legacy Transactions with new*/
DELETE FROM TRANS
WHERE EXISTS (SELECT NULL
              FROM USBANK_CHECK_INPUT t2
              WHERE t2.account_id = account_id
                AND t2.payee_id = payee_id
                AND CAST(t2.trans_date AS CHAR) = CAST(trans_date AS CHAR));
COMMIT;
DELETE FROM TRANS
WHERE EXISTS (SELECT NULL
              FROM USBANK_SAVE_INPUT t2
              WHERE t2.account_id = account_id
                AND t2.payee_id = payee_id
                AND CAST(t2.trans_date AS CHAR) = CAST(trans_date AS CHAR));
COMMIT;
DELETE FROM TRANS
WHERE EXISTS (SELECT NULL
              FROM USBANK_BROCK_INPUT t2
              WHERE t2.account_id = account_id
                AND t2.payee_id = payee_id
                AND CAST(t2.trans_date AS CHAR) = CAST(trans_date AS CHAR));
COMMIT;
DELETE FROM TRANS
WHERE EXISTS (SELECT NULL
              FROM USBANK_MEGAN_INPUT t2
              WHERE t2.account_id = account_id
                AND t2.payee_id = payee_id
                AND CAST(t2.trans_date AS CHAR) = CAST(trans_date AS CHAR));
COMMIT;
DELETE FROM TRANS
WHERE EXISTS (SELECT NULL
              FROM CAP_ONE_INPUT t2
              WHERE t2.account_id = account_id
                AND t2.payee_id = payee_id
                AND CAST(t2.trans_date AS CHAR) = CAST(trans_date AS CHAR));
COMMIT;
DELETE FROM TRANS
WHERE EXISTS (SELECT NULL
              FROM CHASE_INPUT t2
              WHERE t2.account_id = account_id
                AND t2.payee_id = payee_id
                AND CAST(t2.trans_date AS CHAR) = CAST(trans_date AS CHAR));
COMMIT;
INSERT INTO TRANS(amount, trans_date, payee_id, account_id, trans_type, event_id)
SELECT t1.trans_amount, STR_TO_DATE(t1.trans_date, '%m/%d/%Y'), t1.payee_id, t1.account_id, t1.trans_type, t1.event_id
 FROM USBANK_CHECK_INPUT t1
UNION
SELECT t1.trans_amount, STR_TO_DATE(t1.trans_date, '%m/%d/%Y'), t1.payee_id, t1.account_id, t1.trans_type, t1.event_id
 FROM USBANK_SAVE_INPUT t1
UNION
SELECT t1.trans_amount, STR_TO_DATE(t1.trans_date, '%m/%d/%Y'), t1.payee_id, t1.account_id, t1.trans_type, t1.event_id
 FROM USBANK_BROCK_INPUT t1
UNION
SELECT t1.trans_amount, STR_TO_DATE(t1.trans_date, '%m/%d/%Y'), t1.payee_id, t1.account_id, t1.trans_type, t1.event_id
 FROM USBANK_MEGAN_INPUT t1
UNION
SELECT t1.trans_amount, STR_TO_DATE(t1.trans_date, '%m/%d/%Y'), t1.payee_id, t1.account_id, NULL, t1.event_id
 FROM CAP_ONE_INPUT t1
UNION
SELECT t1.trans_amount, STR_TO_DATE(t1.trans_date, '%m/%d/%Y'), t1.payee_id, t1.account_id, t1.trans_type, t1.event_id
 FROM CHASE_INPUT t1;