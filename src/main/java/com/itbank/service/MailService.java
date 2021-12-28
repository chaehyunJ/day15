package com.itbank.service;

import java.util.Properties;
import java.util.Random;

import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.springframework.stereotype.Service;

@Service
public class MailService {

	public String getAuthNumber() {
		Random ran = new Random();
		String authNumber = "";
		for(int i = 0; i < 6; i++) {
			authNumber += ran.nextInt(9);
		}
		return authNumber;
	}

	// 대상 주소, 인증번호(내용), 메일 전송에 필요한 계정 정보를 받아서 메일을 보낸다
	public String sendMail(String email, String authNumber, String account) {
		
		// 1. 메일 발송 시 필요한 내용
		String host = "smtp.naver.com";	// Simple Mail Transfer Protocol
		int port = 465;
		final String username = account.split("/")[0];
		final String password = account.split("/")[1];
		
		String subject = "[KGITBANK] 인증번호 입니다";
		String body = String.format("인증번호는[%s]입니다\n\n", authNumber);
		
		
		// 2. 메일 발송 서버에 대한 인증 및 속성을 설정 (HashMap)
		// 직렬화 되어있어서 파일을 전송할 수 있다 (key-value)
		Properties props = System.getProperties();
		props.put("mail.smtp.host", host);				// 메일을 보낼 서버 이름
		props.put("mail.smtp.port", port);				// 메일을 보낼 서버 포트
		props.put("mail.smtp.auth", "true");			// 메일을 보낼때 인증이 필요한가
		props.put("mail.smtp.ssl.enable", "true");		// 메일 보낼때 암호화 처리 하는가
		props.put("mail.smtp.ssl.trust", host);			// 메일 보내는 신뢰할 수 있는 서버가 어디인가
		
		
		// 보낸 과정
		// connection, statement 랑 비슷
		Session mailSession = Session.getDefaultInstance(props, new Authenticator() {
			String un = username;
			String pw = password;
			
			// 익명의 내부 클래스
			// 접속하는 곳
			@Override
			protected PasswordAuthentication getPasswordAuthentication() {
				// TODO Auto-generated method stub
				// 패스워드 인증방식을 사용
				// 이걸로 로그인
				return new PasswordAuthentication(un, pw);
			}
		});
		
		mailSession.setDebug(true); 		// 메일 보내는 과정의 디버깅을 화면에 출력하기로 설정
		
		// 메일 보낼 내용 - message를 구성한다
		// 보낼 걸 객체로 준비
		Message mimeMessage = new MimeMessage(mailSession);
		
		try {
			
			// 보내는 사람의 주소
			mimeMessage.setFrom(new InternetAddress(username + "@naver.com"));
			
			// 받는 사람의 주소
			
			// internetAddress : 자바 소켓
			mimeMessage.setRecipient(Message.RecipientType.TO, new InternetAddress(email));
			
			mimeMessage.setSubject(subject);	// 제목
			
			mimeMessage.setText(body); 			// 내용
			
			// 전송
			Transport.send(mimeMessage);
			
		} catch (MessagingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			System.out.println("주소가 잘못되었습니다");
		}
		// 보낸 인증번호를 다시 반환하도록 함 (body에 포함된 인증번호를 반환)
		return authNumber;
	}

}
