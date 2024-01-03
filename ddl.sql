--SET FOREIGN_KEY_CHECKS = 0;
-- DROP TABLE exchanges CASCADE CONSTRAINTS;
-- DROP TABLE calculate CASCADE CONSTRAINTS; 
-- DROP TABLE trading_income CASCADE CONSTRAINTS;
    -- CASCADE CONSTRAINTS는 외래키 적용 상관 없이 삭제가능함

-- 테이블 삭제
--==================================================================
-- exchanges 테이블 삭제
DROP TABLE exchanges;
-- calculate 테이블 삭제
--DROP TABLE calculate;
-- trading_income 테이블 삭제
DROP TABLE trading_income;
--SET FOREIGN_KEY_CHECKS = 1;

-- 커밋
--==================================================================
COMMIT;

-- [exchanges 테이블] → 환율 정보
--==================================================================
-- exchanges 테이블 생성
CREATE TABLE exchanges (
    ex_date DATE NOT NULL,
    currency_name VARCHAR2(5) NOT NULL,
    base_rate NUMBER NOT NULL,
    purchase_krw NUMBER NOT NULL,
    selling_krw NUMBER NOT NULL,
    PRIMARY KEY (ex_date)
);
-- exchanges 테이블에 데이터 삽입(DB연동을 위한 예시)
--INSERT INTO exchanges VALUES ('2023-12-20', 'USD', 1.30050, 1323.25, 1277.75);
--INSERT INTO exchanges VALUES (to_char(sysdate, 'yyyy-mm-dd'), 'USD', 1089.049, 1108.107, 1069.990);

-- exchanges 테이블 데이터 삭제(DELETE)
--DELETE exchanges;
-- exchanges 테이블 모든 정보 조회
SELECT TO_CHAR(ex_date, 'YYYY-MM-DD') AS ex_date, currency_name, base_rate, purchase_krw, selling_krw
    FROM exchanges;
SELECT * FROM exchanges;
-- exchanges 테이블 오늘(sysdate) 정보 조회
SELECT TO_CHAR(ex_date, 'YYYY-MM-DD') AS ex_date
        , base_rate, purchase_krw, selling_krw
    FROM exchanges 
    WHERE TO_CHAR(ex_date, 'YYYY-MM-DD') 
        IN TO_CHAR(SYSDATE, 'YYYY-MM-DD');
-- 52주 날짜 조회(LEVEL 사용)
SELECT TO_CHAR(SYSDATE + LEVEL - 1, 'YYYY-MM-DD') DT
        , LEVEL
    FROM DUAL
    CONNECT BY LEVEL <= (SYSDATE - (SYSDATE-365))
;
-- exchanges 테이블 - 52주의 base_rate 최소값, 최대값 조회
SELECT MIN(base_rate), MAX(base_rate) FROM exchanges, ( SELECT TO_CHAR(SYSDATE + LEVEL - 1, 'YYYY-MM-DD') DT, LEVEL FROM DUAL CONNECT BY  LEVEL <= (SYSDATE - (SYSDATE-365)));
-- exchanges 테이블 - 52주의 base_rate 최소값, 최대값 조회
SELECT MIN(base_rate), MAX(base_rate)
    FROM exchanges
        , ( SELECT TO_CHAR(SYSDATE + LEVEL - 1, 'YYYY-MM-DD') DT
                , LEVEL
            FROM DUAL
            CONNECT BY LEVEL <= (SYSDATE - (SYSDATE-365))
        );
-- exchanges 테이블 - 
-- exchanges 테이블 - 금일 환율 랜덤으로 집어넣기, 수식
-- ex_date: SYSDATE
-- currency_name: USD
-- base_rate: 랜덤
-- purchase_krw = base_rate * 1.0175
-- selling_krw = base_rate * 0.9825
-- 랜덤 숫자 조회
SELECT DBMS_RANDOM.VALUE( 1, 10 ) AS randomRate
                FROM DUAL;
-- 랜덤 환율 조회(min_환율 <= random_52주 환율 <= max_환율)
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
            
-- 랜덤 환율 조회(min_환율 <= random_52주 환율 <= max_환율)
SELECT DBMS_RANDOM.VALUE( B.min_rate, B.max_rate ) random_rate FROM DUAL D, (SELECT MIN(base_rate) as min_rate, MAX(base_rate) as max_rate FROM exchanges, ( SELECT TO_CHAR(SYSDATE + LEVEL - 1, 'YYYY-MM-DD') DT, LEVELFROM DUAL CONNECT BY LEVEL <= ( TO_CHAR(SYSDATE, 'YYYY-MM-DD') - ( TO_CHAR(SYSDATE-365, 'YYYY-MM-DD') )))) B;
-- 랜덤 환율에 따른 시세 조회(min_환율 <= random_52주 환율 <= max_환율)
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
-- EXCHANGES 테이블에서 현재(SYSDATE)날짜가 없으면 RANDOM 조회하기
SELECT DISTINCT DECODE(ex_date, NULL, ex_date, TO_CHAR(SYSDATE, 'YYYY-MM-DD') ) AS today
    FROM exchanges;
    
-- EXCHANGES 테이블에서 현재(SYSDATE)날짜가 없으면 0값으로 조회하기
--    SELECT DECODE(str1, str2, str3, str4) FROM DUAL;
--    str1 = str2 이면, str3을 반환
--    str1 != str2 이면, str4을 반환
SELECT DISTINCT DECODE(TO_CHAR(ex_date), NULL, TO_CHAR(ex_date), 0) AS today
    FROM exchanges;

commit; 
rollback;


-- [calculate 테이블] → 계산
--==================================================================
-- calculate 테이블 생성
--CREATE TABLE calculate (
--    ex_date DATE,
--    dollar_gap NUMBER,
--    appropriate_rate NUMBER,
--    revenue_rate NUMBER
--);
-- calculate 테이블 모든 정보 조회
--SELECT * FROM calculate;

-- [trading_income 테이블] → 거래 입력값
--==================================================================
-- trading_income 테이블 생성
CREATE TABLE trading_income (
    trading_seq NUMBER ,
    ex_date DATE NOT NULL,
    trading_method VARCHAR2(10) ,
    amount_krw NUMBER,
    amount_usd NUMBER,
    PRIMARY KEY (trading_seq)
);
-- trading_income 테이블 모든 정보 조회
SELECT * FROM trading_income;
-- trading_income 테이블 - 총 amount_krw, 총 amount_usd 조회
SELECT SUM(amount_krw) AS amount_krw, SUM(amount_usd) AS amount_usd
    FROM trading_income;

--DROP SEQUENCE trading_seq;
-- trading_income 데이터 입력(insert)
--INSERT INTO trading_income VALUES(trading_seq.NEXTVAL, '2023-12-20', '매수', 1302.17 * 1, 1);'
-- trading_income 테이블의 amount_krw에 데이터 입력(insert) => 원화 충전(KRW)
INSERT INTO trading_income(trading_seq, ex_date, amount_krw) VALUES(trading_seq.NEXTVAL, SYSDATE, 1000);
-- 매수(purchase)일때
--INSERT INTO trading_income
--    VALUES(trading_seq.NEXTVAL
--            , TO_CHAR(SYSDATE, 'YYYY-MM-DD'), '매수'
--            , -1*(SELECT purchase_krw 
--                FROM exchanges 
--                WHERE ex_date 
--                    = TO_CHAR(SYSDATE, 'YYYY-MM-DD'))
--            , 1*(SELECT purchase_krw 
--                FROM exchanges 
--                WHERE ex_date 
--                    = TO_CHAR(SYSDATE, 'YYYY-MM-DD'))
--            );

-- trading_income 데이터 삭제(delete)
DELETE trading_income;

commit;
--rollback;

-- trading_income 테이블의 거래순서(trading_seq) 시퀀스 생성
CREATE SEQUENCE trading_seq
INCREMENT BY    1
START WITH      1
MAXVALUE        1000
NOCYCLE;

-- trading_income 테이블의 거래순서(trading_seq) 시퀀스 삭제
DROP SEQUENCE trading_seq;
---------------------------------------------------
--시퀀스 찾기
SELECT SEQUENCE_NAME, MIN_VALUE, MAX_VALUE, INCREMENT_BY, CYCLE_FLAG 
FROM USER_SEQUENCES;
---------------------------------------------------


-- calcutale 테이블의 ex_date 컬럼을 외래키로 사용
-- (exchanges 테이블의 ex_date 컬럼을 사용)
--==================================================================
--ALTER TABLE calculate ADD FOREIGN KEY (ex_date) REFERENCES exchanges(ex_date);


