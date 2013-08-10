SET SQL_SAFE_UPDATES=0;
DROP DATABASE IF EXISTS BUDGET;
CREATE DATABASE BUDGET;
USE BUDGET;
CREATE TABLE TRANS(trans_id             INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
				   amount               DECIMAL(13,2) NOT NULL,
				   trans_date           DATE NOT NULL,
				   payee_id             INT(11) NOT NULL,
				   account_id           INT(11) NOT NULL,
				   trans_type           VARCHAR(60) NOT NULL,
				   event_id             INT(11));
CREATE TABLE PAYEE(payee_id             INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
				   payee_name           VARCHAR(60) NOT NULL,
				   category_id          VARCHAR(10000));
CREATE TABLE CATEGORY(category_id       INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
					  category_name     VARCHAR(60) NOT NULL);
CREATE TABLE ACCOUNT(account_id         INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
					 account_name       VARCHAR(60) NOT NULL,
					 account_type       VARCHAR(60),
					 apr                DECIMAL(13,2));
CREATE TABLE PROJ_TRANS(proj_trans_id   INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
						amount          DECIMAL(13,2) NOT NULL,
						trans_date      DATE NOT NULL,
						payee_id        INT(11),
						account_id      INT(11),
						trans_type      VARCHAR(60),
					    event_id        VARCHAR(10000));
CREATE TABLE SP_EVENT(event_id          INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
					  event_name        VARCHAR(60) NOT NULL,
					  event_date        DATE);
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE ACCOUNT_maint(p_operation    VARCHAR(60),
														  p_account_id   INT(11),
														  p_account_name VARCHAR(60),
														  p_account_type VARCHAR(60),
														  p_apr          VARCHAR(60),
														  p_ext_id       VARCHAR(10000))
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
          t1.apr =          IFNULL(p_apr, t1.apr),
          t1.ext_id =       IFNULL(p_ext_id, t1.ext_id)
      WHERE p_account_id = t1.account_id;
      COMMIT;
    WHEN p_operation = "DELETE" THEN
      DELETE FROM BUDGET.ACCOUNT WHERE p_account_id = t1.account_id;
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
      DELETE FROM BUDGET.CATEGORY WHERE p_category_id = t1.category_id;
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
      DELETE FROM BUDGET.PAYEE WHERE p_payee_id = t1.payee_id;
      COMMIT;
  END CASE;
END$$
