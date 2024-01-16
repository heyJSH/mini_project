package main.Trading;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Scanner;

import dao.SelectInfo;
import dto.TradingVo;
import main.MainMenu;
import util.DBManager;

//라이브러리 클래스 => OperatingSystemExchangesProject에서 실행
//2. 거래 화면
public class Trading {
	// 필드(속성)
	public String select = null;
	public String tradingMethod = null;
	
	public String fromTradingCurrency;	// 입력값에 따른 기준 화폐단위
	public String toTradingCurrency;	// 입력값에 따른 변환되는 화폐단위
	
	// 2. 거래 시작 화면 조회
//	유스케이스 ID: UC-U02
	public void startTrading(Scanner sc) {
//		Scanner sc = new Scanner(System.in);
		select = null;
//		boolean run = true;	// 항상 작동하는 프로그램
		SelectInfo selectInfo = new SelectInfo();	// 조회 클래스 객체 생성
		MainMenu mainMenu = new MainMenu();			// 메인 메뉴 객체 생성
		
		System.out.println("===============================================================");
		selectInfo.amount();	// 보유 달러 및 원화 조회
		System.out.println("===============================================================");
		System.out.println(" [거래 선택]");
		System.out.println(" 원화는 메뉴의 번호를 입력해 주세요.");
		System.out.println("| 1. 금액 충전 | 2. 원화/달러 거래 | 3. 메인 메뉴로 돌아가기 |");
		System.out.println("===============================================================");
		System.out.println(" 입력>> ");
		select = sc.nextLine();	// 입력값 할당
		switch(select) {
			case "1":		// 금액 충전
				System.out.println(" \n<<거래를 위한 금액 충전을 선택하셨습니다.>>");
				chargeAmount(sc);
				break;
			case "2":		// 원화/달러 거래
				System.out.println(" \n<<원화/달러 거래를 선택하셨습니다.>>");
				break;
			case "3":		// 메인 메뉴로 돌아가기
				System.out.println(" \n<<메인 메뉴를 선택하셨습니다.>>");
				mainMenu.mainMenu(sc);
				break;
			default:	// 잘못 입력한 경우
				mainMenu.wrong(sc);
				startTrading(sc);
				break;
		}
//		return select;
	}
	
	// 2-1. 거래 - 금액 충전
//	유스케이스 ID: UC-U03
	public void chargeAmount(Scanner sc) {
		select = null;
		SelectInfo selectInfo = new SelectInfo();	// 조회 클래스 객체 생성
		MainMenu mainMenu = new MainMenu();			// 메인 메뉴 클래스 객체 생성
		TradingVo chargeKRW = new TradingVo();		// TradingVo 클래스 객체 생성
		
		// 충전 금액(select = amount) => insert로 amount_krw에 삽입 해야 함
		double charge_krw = 0;
//		double amount_krw;		// trading_income 테이블의 amount_krw(보유 원화)
		
			System.out.println("===============================================================");
			selectInfo.amount();
			System.out.println("===============================================================");
			System.out.println(" [금액 충전]");
			System.out.println(" 충전할 금액(KRW, 원)을 입력하세요.");
			System.out.println(" 충전은 최소 1,000(원)부터 가능하며, 숫자만 입력 가능합니다.");
			System.out.println(" (만약, 메인 메뉴로 돌아가기를 원하면 숫자 0을 눌러주세요.)");
			System.out.println("===============================================================");
			System.out.println(" 입력>> ");
			select = sc.nextLine();
			
			if(!select.equals("0")) {
//				charge_krw = Integer.parseInt(select);		//String을 Int로 변환하여 사용 
				charge_krw = Double.parseDouble(select);	//String을 double로 변환하여 사용 
			} 
			if(select.equals("0")) {
				System.out.println(" \n<<메인 메뉴로 돌아갑니다.>>");
//				run = false;
				select = mainMenu.mainMenu(sc);
			} else if(charge_krw < 1000) {
				System.out.println(" \n<<충전은 최소 1,000(원)부터 가능합니다. 다시 입력해 주세요.>>");
				startTrading(sc);
			} else if(charge_krw >= 1000) {
				
				// [1]. 입력된 charge_krw가 amount_krw(trading_income 테이블)에 임시 저장
				chargeKRW.setAmount_krw(charge_krw);	// 입력값을 보관
//				run = false;
				
				// [2]. 그 결과(amount_krw)를 조회
////				TradingVo 객체를 String => double로 단계적 변환시키기
//				오류 떠서 못해먹겠네 ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
//				String str1 = selectInfo.amountKRW().toString();
//				double x = Double.valueOf(str1).doubleValue();
////				double 배열
//				double[] arr = {x, chargeKRW.getAmount_krw()};
////				합계 계산
//				double sum = Arrays.stream(arr).sum();
				
				
				System.out.println("\n===============================================================");
//				System.out.println(" 예상 보유 금액(KRW): " + sum + "(원)");
				System.out.println(" 충전 금액(KRW): " + chargeKRW.getAmount_krw() + "(원)");
				System.out.println(" 충전하시겠습니까?");
				System.out.println("| 1. 네 | 2. 아니오 |");
				System.out.println("===============================================================");
				System.out.println(" 입력>>");
				
				// [3]. 충전 확인 질문에 승낙하면, trading_income 테이블에 데이터 저장(insert)
				String answer = null;
				answer = sc.nextLine();
				
				switch(answer) {
					case "1":
						Connection conn = null;
						PreparedStatement pstmt = null;
						
						try {
							String sql = "INSERT INTO trading_income(trading_seq, ex_date, amount_krw) "
											+ "VALUES(trading_seq.NEXTVAL, SYSDATE, 1000)";
							conn = DBManager.getConnection();
							pstmt = conn.prepareStatement(sql);
							pstmt.setDouble(1, chargeKRW.getAmount_krw());	// 1번째 물음표, 입력값
							
							pstmt.executeUpdate();	// insert 쿼리문 결과 처리
							
						} catch(Exception e) {
							System.out.println("예외 발생시 처리할 코드: 쿼리문 삽입(원화 충전)");
						}
						DBManager.close(conn, pstmt);
//						return chargeKRW;
						
						System.out.println(" \n충전이 완료되었습니다. ▶ 보유한 원화: "
								+ chargeKRW.getAmount_krw() + "(원)");
						System.out.println("=================================================");
						System.out.println(" <<메인 메뉴로 돌아갑니다.>>");
						mainMenu.mainMenu(sc);
						break;
					case "2":
						System.out.println(" <<거래 시작 화면으로 돌아갑니다.>>");
						startTrading(sc);
						break;
					default:
						mainMenu.wrong(sc);
						startTrading(sc);
						break;
				}
			} 
			
	}

	// 2-2. 원화/달러 거래
//	유스케이스 ID: UC-U04
	public void trading(Scanner sc) {
		select = null;
		
		SelectInfo selectInfo = new SelectInfo();	// 조회 클래스 객체 생성
		MainMenu mainMenu = new MainMenu();			// 메인 메뉴 객체 생성
		TradingVo trade = new TradingVo();
		
		System.out.println("==================================================");
		selectInfo.amount();	// 보유 달러 및 원화 조회
		System.out.println("==================================================");
		System.out.println(" [원화/달러 거래]");
		System.out.println("| 1. 매수 | 2. 매도 | 3. 메인 메뉴로 돌아가기 |");
		System.out.println("==================================================");
		System.out.println(" 입력>> ");
		
		// 2-2-1. 거래방법(매수/매도) 선택
		select = sc.nextLine();
		switch(select) {
			case "1":
				this.tradingMethod = "매수";
				trade.setTrading_method(tradingMethod);	// 임시저장
				System.out.println("\n <<거래 방법 - " + tradingMethod + ">>");
				System.out.println("==================================================");
				currency(sc);
				break;
			case "2":
				if(trade.getTrading_method() == null) {
					System.out.println(" 보유한 달러 기록이 없으므로");
					System.out.println(" 현재는 매수만 가능합니다.");
				}
				this.tradingMethod = "매도";
				trade.setTrading_method(tradingMethod);	// 임시저장
				System.out.println("\n <<거래 방법 - " + tradingMethod + ">>");
				System.out.println("==================================================");
				currency(sc);
				break;
			case "3":
				System.out.println(" <<메인 메뉴로 돌아갑니다.>>");
				mainMenu.mainMenu(sc);
				break;
			default:
				mainMenu.wrong(sc);
				trading(sc);
				break;
		}
	}
	
	// 2-2-2. 거래 기준 화폐(원화/달러) 선택
	public void currency(Scanner sc) {
		select = null;
		
		SelectInfo selectInfo = new SelectInfo();	// 조회 클래스 객체 생성
		MainMenu mainMenu = new MainMenu();			// 메인 메뉴 객체 생성
		TradingVo trade = new TradingVo();
		
		System.out.println("==================================================");
		selectInfo.amount();	// 보유 달러 및 원화 조회
		System.out.println("==================================================");
		System.out.println(" [화폐 단위 선택]");
		System.out.println(" 입력을 원하는 화폐 단위의 번호를 입력해 주세요.");
		System.out.println("| 1. 원화(KRW) | 2. 달러(USD) |");
		System.out.println("==================================================");
		System.out.println(" 입력>> ");
		
		select = sc.nextLine();
		
		switch(select) {
			case "1":	// 입력 화폐 단위: 원화(KRW)
				this.fromTradingCurrency = "원화(KRW)";
				this.toTradingCurrency = "달러(USD)";
				System.out.println("\n <<입력 화폐 단위: " + fromTradingCurrency + ">>");
				System.out.println(" " + fromTradingCurrency + " => " + toTradingCurrency);
				break;
			case "2":	// 입력 화폐 단위: 달러(USD)
				this.fromTradingCurrency = "달러(USD)";
				this.toTradingCurrency = "원화(KRW)";
				System.out.println("\n <<입력 화폐 단위: " + fromTradingCurrency + ">>");
				System.out.println(" " + fromTradingCurrency + " => " + toTradingCurrency);
				break;
			default:
				mainMenu.wrong(sc);
				trading(sc);
				break;
		}
	}
	
	// 2-2-3. 거래 금액 입력
	public void inputTradingAmount(Scanner sc) {
		select = "0";
		
		System.out.println("===============================================================");
		
	}
	
	
}
