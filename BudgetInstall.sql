SET SQL_SAFE_UPDATES=0;
DROP DATABASE IF EXISTS BUDGET;
CREATE DATABASE BUDGET;
USE BUDGET;
CREATE TABLE SP_EVENT(event_id          INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
					  event_name        VARCHAR(60) NOT NULL,
					  event_date        DATE);
CREATE TABLE CATEGORY(category_id       INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
					  category_name     VARCHAR(60) NOT NULL);
CREATE TABLE ACCOUNT(account_id         INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
					 account_name       VARCHAR(60) NOT NULL,
					 account_type       VARCHAR(60),
					 apr                DECIMAL(13,2));
CREATE TABLE PAYEE(payee_id             INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
				   payee_name           VARCHAR(60) NOT NULL,
				   category_id          INT(11));
CREATE TABLE TRANS(trans_id             INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
				   amount               DECIMAL(13,2) NOT NULL,
				   trans_date           DATE NOT NULL,
				   payee_id             INT(11) NOT NULL,
				   account_id           INT(11) NOT NULL,
				   trans_type           VARCHAR(60) NOT NULL,
				   event_id             INT(11));
CREATE TABLE PROJ_TRANS(trans_id        INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
						amount          DECIMAL(13,2) NOT NULL,
						trans_date      DATE NOT NULL,
						payee_id        INT(11),
						account_id      INT(11),
						trans_type      VARCHAR(60),
					    event_id        INT(11));
CREATE TABLE USBANK_CHECK_INPUT(trans_date    VARCHAR(255),
						        trans_type    VARCHAR(255),
						        trans_name    VARCHAR(255),
						        trans_memo    VARCHAR(255),   
                                trans_amount  VARCHAR(255));
CREATE TABLE USBANK_MEGAN_INPUT(trans_date    VARCHAR(255),
						        trans_type    VARCHAR(255),
						        trans_name    VARCHAR(255),
						        trans_memo    VARCHAR(255),   
                                trans_amount  VARCHAR(255));
CREATE TABLE USBANK_BROCK_INPUT(trans_date    VARCHAR(255),
						        trans_type    VARCHAR(255),
						        trans_name    VARCHAR(255),
						        trans_memo    VARCHAR(255),   
                                trans_amount  VARCHAR(255));
CREATE TABLE CHASE_INPUT(trans_type     VARCHAR(255),
						 swipe_date     VARCHAR(255),
						 trans_date     VARCHAR(255),
						 trans_memo     VARCHAR(255),   
						 trans_amount   VARCHAR(255));
CREATE TABLE CAP_ONE_INPUT(trans_date   VARCHAR(255),
						   card_number  VARCHAR(255),
						   trans_memo   VARCHAR(255),   
						   trans_debit  VARCHAR(255),
                           trans_credit VARCHAR(255));
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE SP_EVENT_maint(p_operation     VARCHAR(60),
													       p_event_id      INT(11),
													       p_event_name    VARCHAR(60),
														   p_event_date    DATE)
BEGIN
  CASE
    WHEN p_operation = "INSERT" THEN
      INSERT INTO BUDGET.SP_EVENT(event_name, event_date) 
      VALUES(p_event_name, p_event_date);
      COMMIT;
    WHEN p_operation = "UPDATE" THEN
      UPDATE BUDGET.SP_EVENT AS t1
      SET t1.event_name  = IFNULL(p_event_name, t1.event_name),
          t1.event_date  = IFNULL(p_event_date, t1.event_date)
      WHERE p_event_id = t1.event_id;
      COMMIT;
    WHEN p_operation = "DELETE" THEN
      DELETE FROM BUDGET.SP_EVENT WHERE p_event_id = event_id;
      UPDATE BUDGET.TRANS AS t1
	  SET t1.event_id = NULL
      WHERE t1.event_id = p_event_id;
      UPDATE BUDGET.PROJ_TRANS AS t1
	  SET t1.event_id = NULL
      WHERE t1.event_id = p_event_id;
      COMMIT;
  END CASE;
END$$
CREATE DEFINER=`root`@`localhost` PROCEDURE CATEGORY_maint(p_operation     VARCHAR(60),
														   p_category_id   INT(11),
														   p_category_name VARCHAR(60))
BEGIN
  CASE
    WHEN p_operation = "INSERT" THEN
      INSERT INTO BUDGET.CATEGORY(category_name) VALUES(p_category_name);
      COMMIT;
    WHEN p_operation = "UPDATE" THEN
      UPDATE BUDGET.CATEGORY AS t1
      SET t1.category_name = p_category_name
      WHERE p_category_id = t1.category_id;
      COMMIT;
    WHEN p_operation = "DELETE" THEN
      DELETE FROM BUDGET.CATEGORY WHERE p_category_id = category_id;
      UPDATE BUDGET.PAYEE AS t1
      SET t1.category_id = NULL
	  WHERE t1.category = p_category_id;
      COMMIT;
  END CASE;
END$$
CREATE DEFINER=`root`@`localhost` PROCEDURE ACCOUNT_maint(p_operation    VARCHAR(60),
														  p_account_id   INT(11),
														  p_account_name VARCHAR(60),
														  p_account_type VARCHAR(60),
														  p_apr          VARCHAR(60))
BEGIN
  CASE
    WHEN p_operation = "INSERT" THEN
      INSERT INTO BUDGET.ACCOUNT(account_name,account_type,apr,ext_id)
      VALUES(p_account_name,p_account_type,p_apr,p_ext_id);
      COMMIT;
    WHEN p_operation = "UPDATE" THEN
      UPDATE BUDGET.ACCOUNT AS t1
      SET t1.account_name = IFNULL(p_account_name, t1.account_name),
		  t1.account_type = IFNULL(p_account_type, t1.account_type),
          t1.apr          = IFNULL(p_apr, t1.apr)
      WHERE p_account_id = t1.account_id;
      COMMIT;
    WHEN p_operation = "DELETE" THEN
      DELETE FROM BUDGET.ACCOUNT WHERE p_account_id = account_id;
	  UPDATE BUDGET.TRANS AS t1
      SET t1.account_id = 0
      WHERE t1.account_id = p_account_id;
	  UPDATE BUDGET.PROJ_TRANS AS t1
      SET t1.account_id = 0
      WHERE t1.account_id = p_account_id;
      COMMIT;
  END CASE;
END$$
CREATE DEFINER=`root`@`localhost` PROCEDURE PAYEE_maint(p_operation     VARCHAR(60),
												        p_payee_id      INT(11),
														p_payee_name    VARCHAR(60),
                                                        p_category_id   INT(11))
BEGIN
  CASE
    WHEN p_operation = "INSERT" THEN
      INSERT INTO BUDGET.PAYEE(payee_name, category_id) VALUES(p_payee_name, p_category_id);
      COMMIT;
    WHEN p_operation = "UPDATE" THEN
      UPDATE BUDGET.PAYEE AS t1
      SET t1.payee_name  = IFNULL(p_payee_name, t1.payee_name),
          t1.category_id = IFNULL(p_category_id, t1.category_id)
      WHERE p_payee_id = t1.payee_id;
      COMMIT;
    WHEN p_operation = "DELETE" THEN
      DELETE FROM BUDGET.PAYEE WHERE p_payee_id = payee_id;
      UPDATE BUDGET.TRANS AS t1
      SET t1.payee_id = 0
	  WHERE t1.payee_id = p_payee_id;
	  UPDATE BUDGET.PROJ_TRANS AS t1
      SET t1.payee_id = 0
	  WHERE t1.payee_id = p_payee_id;     
      COMMIT;
  END CASE;
END$$
CREATE DEFINER=`root`@`localhost` PROCEDURE TRANS_maint(p_operation     VARCHAR(60),
													    p_trans_id INT(11),
													    p_amount        DECIMAL(13,2),
														p_trans_date    DATE,
                                                        p_payee_id      INT(11),
                                                        p_account_id    INT(11),
                                                        p_trans_type    VARCHAR(60),
                                                        p_event_id      INT(11))
BEGIN
  CASE
    WHEN p_operation = "INSERT" THEN
      INSERT INTO BUDGET.TRANS(amount, trans_date, payee_id,
							   account_id, trans_type, event_id) 
      VALUES(p_amount, p_trans_date, p_payee_id, p_account_id, p_trans_type, p_event_id);
      COMMIT;
    WHEN p_operation = "UPDATE" THEN
      UPDATE BUDGET.TRANS AS t1
      SET t1.amount      = IFNULL(p_amount, t1.amount),
          t1.trans_date  = IFNULL(p_trans_date, t1.trans_date),
          t1.payee_id    = IFNULL(p_payee_id, t1.payee_id),
		  t1.account_id	 = IFNULL(p_account_id,t1.account_id),
          t1.trans_type  = IFNULL(p_trans_type, t1.trans_type),
          t1.event_id    = IFNULL(p_event_id, t1.event_id)
      WHERE p_trans_id = t1.trans_id;
      COMMIT;
    WHEN p_operation = "DELETE" THEN
      DELETE FROM BUDGET.TRANS WHERE p_trans_id = trans_id;
      COMMIT;
  END CASE;
END$$
CREATE DEFINER=`root`@`localhost` PROCEDURE PROJ_TRANS_maint(p_operation     VARCHAR(60),
												             p_trans_id INT(11),
														     p_amount        DECIMAL(13,2),
                                                             p_trans_date    DATE,
                                                             p_payee_id      INT(11),
                                                             p_account_id    INT(11),
                                                             p_trans_type    VARCHAR(60),
                                                             p_event_id      INT(11))
BEGIN
  CASE
    WHEN p_operation = "INSERT" THEN
      INSERT INTO BUDGET.PROJ_TRANS(amount, trans_date, payee_id,
                                    account_id, trans_type, event_id) 
      VALUES(p_amount, p_trans_date, p_payee_id, p_account_id, p_trans_type, p_event_id);
      COMMIT;
    WHEN p_operation = "UPDATE" THEN
      UPDATE BUDGET.PROJ_TRANS AS t1
      SET t1.amount      = IFNULL(p_amount, t1.amount),
          t1.trans_date  = IFNULL(p_trans_date, t1.trans_date),
          t1.payee_id    = IFNULL(p_payee_id, t1.payee_id),
		  t1.account_id	 = IFNULL(p_account_id,t1.account_id),
          t1.trans_type  = IFNULL(p_trans_type, t1.trans_type),
          t1.event_id    = IFNULL(p_event_id, t1.event_id)
      WHERE p_trans_id = t1.trans_id;
      COMMIT;
    WHEN p_operation = "DELETE" THEN
      DELETE FROM BUDGET.PROJ_TRANS WHERE p_trans_id = trans_id;
      COMMIT;
  END CASE;
END$$