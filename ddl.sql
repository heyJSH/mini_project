--SET FOREIGN_KEY_CHECKS = 0;
-- DROP TABLE exchanges CASCADE CONSTRAINTS;
-- DROP TABLE calculate CASCADE CONSTRAINTS; 
-- DROP TABLE trading_income CASCADE CONSTRAINTS;
    -- CASCADE CONSTRAINTS�� �ܷ�Ű ���� ��� ���� ����������

-- ���̺� ����
--==================================================================
-- exchanges ���̺� ����
DROP TABLE exchanges;
-- calculate ���̺� ����
--DROP TABLE calculate;
-- trading_income ���̺� ����
DROP TABLE trading_income;
--SET FOREIGN_KEY_CHECKS = 1;

-- Ŀ��
--==================================================================
COMMIT;

-- [exchanges ���̺�] �� ȯ�� ����
--==================================================================
-- exchanges ���̺� ����
CREATE TABLE exchanges (
    ex_date DATE NOT NULL,
    currency_name VARCHAR2(5) NOT NULL,
    base_rate NUMBER NOT NULL,
    purchase_krw NUMBER NOT NULL,
    selling_krw NUMBER NOT NULL,
    PRIMARY KEY (ex_date)
);
-- exchanges ���̺� ������ ����(DB������ ���� ����)
--INSERT INTO exchanges VALUES ('2023-12-20', 'USD', 1.30050, 1323.25, 1277.75);
--INSERT INTO exchanges VALUES (to_char(sysdate, 'yyyy-mm-dd'), 'USD', 1089.049, 1108.107, 1069.990);

-- exchanges ���̺� ������ ����(DELETE)
--DELETE exchanges;
-- exchanges ���̺� ��� ���� ��ȸ
SELECT TO_CHAR(ex_date, 'YYYY-MM-DD') AS ex_date, currency_name, base_rate, purchase_krw, selling_krw
    FROM exchanges;
SELECT * FROM exchanges;
-- exchanges ���̺� ����(sysdate) ���� ��ȸ
SELECT TO_CHAR(ex_date, 'YYYY-MM-DD') AS ex_date
        , base_rate, purchase_krw, selling_krw
    FROM exchanges 
    WHERE TO_CHAR(ex_date, 'YYYY-MM-DD') 
        IN TO_CHAR(SYSDATE, 'YYYY-MM-DD');
-- 52�� ��¥ ��ȸ(LEVEL ���)
SELECT TO_CHAR(SYSDATE + LEVEL - 1, 'YYYY-MM-DD') DT
        , LEVEL
    FROM DUAL
    CONNECT BY LEVEL <= (SYSDATE - (SYSDATE-365))
;
-- exchanges ���̺� - 52���� base_rate �ּҰ�, �ִ밪 ��ȸ
SELECT MIN(base_rate), MAX(base_rate) FROM exchanges, ( SELECT TO_CHAR(SYSDATE + LEVEL - 1, 'YYYY-MM-DD') DT, LEVEL FROM DUAL CONNECT BY  LEVEL <= (SYSDATE - (SYSDATE-365)));
-- exchanges ���̺� - 52���� base_rate �ּҰ�, �ִ밪 ��ȸ
SELECT MIN(base_rate), MAX(base_rate)
    FROM exchanges
        , ( SELECT TO_CHAR(SYSDATE + LEVEL - 1, 'YYYY-MM-DD') DT
                , LEVEL
            FROM DUAL
            CONNECT BY LEVEL <= (SYSDATE - (SYSDATE-365))
        );
-- exchanges ���̺� - 
-- exchanges ���̺� - ���� ȯ�� �������� ����ֱ�, ����
-- ex_date: SYSDATE
-- currency_name: USD
-- base_rate: ����
-- purchase_krw = base_rate * 1.0175
-- selling_krw = base_rate * 0.9825
-- ���� ���� ��ȸ
SELECT DBMS_RANDOM.VALUE( 1, 10 ) AS randomRate
                FROM DUAL;
-- ���� ȯ�� ��ȸ(min_ȯ�� <= random_52�� ȯ�� <= max_ȯ��)
SELECT DBMS_RANDOM.VALUE( B.min_rate, B.max_rate ) random_rate
    FROM DUAL D
        , (SELECT MIN(base_rate) as min_rate, MAX(base_rate) as max_rate
                    FROM exchanges
                        , ( SELECT TO_CHAR(SYSDATE + LEVEL - 1
                                    , 'YYYY-MM-DD') DT
                                    , LEVEL
                                FROM DUAL
                                CONNECT BY LEVEL <= (SYSDATE - (SYSDATE-365))
                            )
            ) B;
            
-- ���� ȯ�� ��ȸ(min_ȯ�� <= random_52�� ȯ�� <= max_ȯ��)
SELECT DBMS_RANDOM.VALUE( B.min_rate, B.max_rate ) random_rate FROM DUAL D, (SELECT MIN(base_rate) as min_rate, MAX(base_rate) as max_rate FROM exchanges, ( SELECT TO_CHAR(SYSDATE + LEVEL - 1, 'YYYY-MM-DD') DT, LEVELFROM DUAL CONNECT BY LEVEL <= ( TO_CHAR(SYSDATE, 'YYYY-MM-DD') - ( TO_CHAR(SYSDATE-365, 'YYYY-MM-DD') )))) B;
-- ���� ȯ���� ���� �ü� ��ȸ(min_ȯ�� <= random_52�� ȯ�� <= max_ȯ��)
SELECT A.random_rate
        , (A.random_rate * 1.0175) AS purchase_rate
        , (A.random_rate * 0.9825) AS selling_krw
    FROM (SELECT DBMS_RANDOM.VALUE( B.min_rate, B.max_rate ) random_rate
                FROM DUAL D
                    , (SELECT MIN(base_rate) as min_rate
                            , MAX(base_rate) as max_rate
                        FROM exchanges
                            , ( SELECT TO_CHAR(SYSDATE + LEVEL - 1
                                    , 'YYYY-MM-DD') DT
                                    , LEVEL
                                FROM DUAL
                                CONNECT BY LEVEL <= (SYSDATE - (SYSDATE-365))
                                )
                        ) B
            ) A ;
-- EXCHANGES ���̺��� ����(SYSDATE)��¥�� ������ RANDOM ��ȸ�ϱ�
SELECT DISTINCT DECODE(ex_date, NULL, ex_date, TO_CHAR(SYSDATE, 'YYYY-MM-DD') ) AS today
    FROM exchanges;
    
-- EXCHANGES ���̺��� ����(SYSDATE)��¥�� ������ 0������ ��ȸ�ϱ�
--    SELECT DECODE(str1, str2, str3, str4) FROM DUAL;
--    str1 = str2 �̸�, str3�� ��ȯ
--    str1 != str2 �̸�, str4�� ��ȯ
SELECT DISTINCT DECODE(TO_CHAR(ex_date), NULL, TO_CHAR(ex_date), 0) AS today
    FROM exchanges;

commit; 
rollback;


-- [calculate ���̺�] �� ���
--==================================================================
-- calculate ���̺� ����
--CREATE TABLE calculate (
--    ex_date DATE,
--    dollar_gap NUMBER,
--    appropriate_rate NUMBER,
--    revenue_rate NUMBER
--);
-- calculate ���̺� ��� ���� ��ȸ
--SELECT * FROM calculate;

-- [trading_income ���̺�] �� �ŷ� �Է°�
--==================================================================
-- trading_income ���̺� ����
CREATE TABLE trading_income (
    trading_seq NUMBER ,
    ex_date DATE NOT NULL,
    trading_method VARCHAR2(10) ,
    amount_krw NUMBER,
    amount_usd NUMBER,
    PRIMARY KEY (trading_seq)
);
-- trading_income ���̺� ��� ���� ��ȸ
SELECT * FROM trading_income;
-- trading_income ���̺� - �� amount_krw, �� amount_usd ��ȸ
SELECT SUM(amount_krw) AS amount_krw, SUM(amount_usd) AS amount_usd
    FROM trading_income;

--DROP SEQUENCE trading_seq;
-- trading_income ������ �Է�(insert)
--INSERT INTO trading_income VALUES(trading_seq.NEXTVAL, '2023-12-20', '�ż�', 1302.17 * 1, 1);'
-- trading_income ���̺��� amount_krw�� ������ �Է�(insert) => ��ȭ ����(KRW)
INSERT INTO trading_income(trading_seq, ex_date, amount_krw) VALUES(trading_seq.NEXTVAL, SYSDATE, 1000);
-- �ż�(purchase)�϶�
--INSERT INTO trading_income
--    VALUES(trading_seq.NEXTVAL
--            , TO_CHAR(SYSDATE, 'YYYY-MM-DD'), '�ż�'
--            , -1*(SELECT purchase_krw 
--                FROM exchanges 
--                WHERE ex_date 
--                    = TO_CHAR(SYSDATE, 'YYYY-MM-DD'))
--            , 1*(SELECT purchase_krw 
--                FROM exchanges 
--                WHERE ex_date 
--                    = TO_CHAR(SYSDATE, 'YYYY-MM-DD'))
--            );

-- trading_income ������ ����(delete)
DELETE trading_income;

commit;
--rollback;

-- trading_income ���̺��� �ŷ�����(trading_seq) ������ ����
CREATE SEQUENCE trading_seq
INCREMENT BY    1
START WITH      1
MAXVALUE        1000
NOCYCLE;

-- trading_income ���̺��� �ŷ�����(trading_seq) ������ ����
DROP SEQUENCE trading_seq;
---------------------------------------------------
--������ ã��
SELECT SEQUENCE_NAME, MIN_VALUE, MAX_VALUE, INCREMENT_BY, CYCLE_FLAG 
FROM USER_SEQUENCES;
---------------------------------------------------


-- calcutale ���̺��� ex_date �÷��� �ܷ�Ű�� ���
-- (exchanges ���̺��� ex_date �÷��� ���)
--==================================================================
--ALTER TABLE calculate ADD FOREIGN KEY (ex_date) REFERENCES exchanges(ex_date);


