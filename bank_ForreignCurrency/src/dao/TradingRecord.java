package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Scanner;
import dto.ExchangesVo;
import dto.TradingVo;
import main.OperatingSystem;
import util.DBManager;
// 3. 거래 기록 조회 화면
// 유스케이스 ID: UC-U05
public class TradingRecord {
//라이브러리 클래스 => OperatingSystemExchangesProject에서 실행
   
   public String select;
   public MainMenu mainMenu = new MainMenu();
   public Trading trading = new Trading();
   public OperatingSystem oSystem = new OperatingSystem();
   public TradingVo tVo;
   public ExchangesVo eVo;
   
   public int trading_seq = 0;
   public double amount_usd = 0;            // 보유 달러
   public double amount_krw = 0;            // 보유 원화
//   public double Pamount_krwT = 0;            // 총 매수 금액(원)
//   public double Samount_krwT = 0;            // 총 매도 금액(원)
//   public double RevenueRateT = 0;            // 총 수익률(%)
   public double base_rate = 0;            // 매매 기준율, 현재 환율
   public double purchase_krw = 0;            // 달러 살때(원)
   public double selling_krw = 0;            // 달러 팔때(원)
//   public double flucMinW = 0;               // 52주 변동폭(Min)
//   public double flucMaxW = 0;               // 52주 변동폭(Max)
//   public double flucMinT = 0;               // 금일 변동폭(Min)         // api 크롤링으로 실시간 조회가 아니므로 금일은 변동폭이 없음
//   public double flucMaxT = 0;               // 금일 변동폭(Max)
   
   // 52주 변동폭 조회
   public static ExchangesVo flucWeeks() {
      ExchangesVo flucW = new ExchangesVo();
      String sql = "SELECT TO_CHAR(ex_date, 'YYYY-MM-DD') AS ex_date, currency_name, base_rate, purchase_krw, selling_krw FROM exchanges";
         
         PreparedStatement pstmt = null;
         ResultSet rs = null;
         Connection conn = null;
         
         try {
            conn = DBManager.getConnection();   // DB 연결
            
            
//            (3단계) PreparedStatement 객체 생성
            pstmt = conn.prepareStatement(sql);      // 쿼리문 실행
            /* 교수님 예시
            pstmt.setInt(1, code);         // 1: 물음표 순서, code: 물음표 값
             */
            
            
//            (4단계) SQL문 실행 결과 처리
            rs = pstmt.executeQuery();         // 쿼리문 결과 처리
            
//            rs.next(): 다음 행(row)을 확인(반환값타입: boolean)
//            if(rs.next()) {      // if는 한번만 실행하므로 반복실행은 while
            while(rs.next()) {
               String ex_date = rs.getString("ex_date");
               String currency_name = rs.getString("currency_name");
               double base_rate = rs.getDouble("base_rate");
               double purchase_krw = rs.getDouble("purchase_krw");
               double selling_krw = rs.getDouble("purchase_krw");
               
//               System.out.print(ex_date + "\t");
//               System.out.print(currency_name + "\t");
//               System.out.print(base_rate + "\t");
//               System.out.print(purchase_krw + "\t");
//               System.out.print(selling_krw + "\n");
               
               flucW.setEx_date(ex_date);
               flucW.setCurrency_name(currency_name);
               flucW.setBase_rate(base_rate);
               flucW.setPurchase_krw(purchase_krw);
               flucW.setSelling_krw(selling_krw);
               
            }
         } catch(Exception e) {
            System.out.println("예외 발생시 처리할 코드: 쿼리문 조회");
         }
         DBManager.close(conn, pstmt, rs);      // DB 닫기
      return flucW;
   }
   
   
   // 3. 거래 기록 조회 화면
   public void tradingRecord(Scanner sc) {
      select = null;
//      tVo = oSystem.trading_incomeAllInfo();
      
      tVo = Trading.amountKRW();         // 현재 보유금액(원화)
      amount_krw = tVo.getAmount_krw();   
      tVo = Trading.amountUSD();         // 현재 보유금액(달러)
      amount_usd = tVo.getAmount_usd();
      eVo = Trading.exchangesInfo();      // 달러 환율
      base_rate = eVo.getBase_rate();
      purchase_krw = eVo.getPurchase_krw();
      selling_krw = eVo.getSelling_krw();
      
//      trading_seq = tVo.getTrading_seq();
//      if(trading_seq == 0) {
//         System.out.println("\n <<현재 거래된 내역이 없습니다. 메인 메뉴로 이동합니다.>>");
//         mainMenu.mainMenu(sc);
//      } else {
         System.out.println("\n <<거래 기록 조회>>");
         System.out.println("===============================================================");
         System.out.println(" | 0. 메인 메뉴로 돌아가기 |");
         System.out.println("===============================================================");
         System.out.println(" [거래 기록]");
         System.out.println(" - 보유한 달러:\t" + amount_usd + "\t(달러)");
         System.out.println(" - 보유한 원화:\t" + amount_krw + "\t(원)");
//         System.out.println(" - 총 매수 금액:\t" + Pamount_krwT + "\t(원)");
//         System.out.println(" - 총 매도 금액:\t" + Samount_krwT + "\t(원)");
//         System.out.println(" - 총 수익률:\t" + RevenueRateT + "\t(%)");
         System.out.println(" - 매매 기준률:\t" + base_rate + "\t");
         System.out.println(" - 달러 살 때:\t" + purchase_krw + "\t(원)");
         System.out.println(" - 달러 팔 때:\t" + selling_krw + "\t(원)");
//         System.out.println(" - 52주 변동폭:\t" + flucMinW + " ~ " + flucMaxW);
//         System.out.println(" - 금일 변동폭:\t" + flucMinT + " ~ " + flucMaxT);
         
         select = sc.nextLine();
         switch(select) {
            case "0":
               System.out.println("\n <<메인 메뉴로 돌아갑니다.>>");
               mainMenu.mainMenu(sc);
               break;
            default:
               mainMenu.wrong(sc);
               tradingRecord(sc);
               break;
         }
//      } // if-else 중괄호
   }
}