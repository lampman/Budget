-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `financeApp_DDL`()
BEGIN

  DROP TABLE IF EXISTS TRANS;

  CREATE TABLE TRANS(trans_id             VARCHAR(10000),
                     amount	          DECIMAL(13,2),
                     trans_date           DATE,
                     payee_id             VARCHAR(10000),
                     account_id           VARCHAR(10000),
		     trans_type           VARCHAR(60),
                     event_id             VARCHAR(10000),
                     trans_ext_id         VARCHAR(10000));

  DROP TABLE IF EXISTS PAYEE;

  CREATE TABLE PAYEE(payee_id             VARCHAR(10000), 
                     payee_name           VARCHAR(60),
                     category_id          VARCHAR(10000),
                     ext_id               VARCHAR(10000));
  
  DROP TABLE IF EXISTS CATEGORY;
  
  CREATE TABLE CATEGORY(category_id       VARCHAR(10000),
                        category_name     VARCHAR(60));

  DROP TABLE IF EXISTS ACCOUNT;

  CREATE TABLE ACCOUNT(account_id         VARCHAR(10000),
                       account_name       VARCHAR(60),
                       account_type       VARCHAR(60),
                       balance            DECIMAL(13,2),
	               apr                DECIMAL(13,2),
                       ext_id             VARCHAR(10000));

  DROP TABLE IF EXISTS PROJ_TRANS;

  CREATE TABLE PROJ_TRANS(proj_trans_id   VARCHAR(10000),
                          amount          DECIMAL(13,2),
                          trans_date      DATE,
                          payee_id        VARCHAR(10000),
                          account_id      VARCHAR(10000),
                          trans_type      VARCHAR(60),
                          event_id        VARCHAR(10000));

  DROP TABLE IF EXISTS SP_EVENT;

  CREATE TABLE SP_EVENT(event_id          VARCHAR(10000),
		        event_name        VARCHAR(60),
                        event_date        DATE);
                   
END
