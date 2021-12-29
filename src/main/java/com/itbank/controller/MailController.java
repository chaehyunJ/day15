package com.itbank.controller;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.HashMap;
import java.util.Scanner;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import com.itbank.component.Hash;
import com.itbank.service.MailService;

@RestController
public class MailController {

	@Autowired private MailService mailService;
	@Autowired private Hash hash;
	
	@GetMapping("/mailto/{email}/")
	public HashMap<String, String> mailto(@PathVariable String email, HttpSession session) throws IOException{
		System.out.println("인증번호를 받을 이메일주소 : " + email);
		
		String authNumber = mailService.getAuthNumber();
		System.out.println("인증 번호 : " + authNumber);
		
		String hashNumber = hash.getHash(authNumber);
		
		System.out.println("인증 해시값 : " + hashNumber);
		
		// 세션은 클라이언트당 한개의 객체가 생성되니까 세션에 저장해두면 다른 클라이언트와 섞일 일이 없다
		session.setAttribute("hashNumber", hashNumber);
		
		// 이메일을 보내기 위해서는 계정 정보가 필요하다(web-inf 밑에 data폴더를 만들고 그 안에 account.dat안에 계정 정보를 담는다)
		
		
		// 계정 불러오려고 만듬
		String account = null;
		
		String filePath = session.getServletContext().getRealPath("/WEB-INF/data/account.dat");
		
		File f = new File(filePath);
		
		if(f.exists() == false) {
			System.out.println("메일 전송에 필요한 계정 정보가 없습니다");
			return null;
		}
		
		Scanner sc = new Scanner(f);
		
		while(sc.hasNext()) {
			account = sc.nextLine();
		}
		sc.close();
		// controller에서는 정보를 모으는 역할
		
		// 메일 보내는건 service에서 처리
		
		// result가 인증번호
		String result = mailService.sendMail(email, authNumber, account);
		
		HashMap<String, String> ret = new HashMap<String, String>();
		
		if(result.equals(authNumber)) {
			ret.put("status", "OK");
			ret.put("message", "인증번호가 발송되었습니다");
		}
		else {
			ret.put("status","FAIL");
			ret.put("message","인증번호가 발송되지 않았습니다 ");
		}
		return ret;
	}
	
	@GetMapping("/getAuthResult/{userNumber}/")
	public HashMap<String, String> getAuthResult(@PathVariable String userNumber, HttpSession session){
		
//		String userNumber1 = String.valueOf(userNumber);
		String sessionHash = (String)session.getAttribute("hashNumber");
		String userHash = hash.getHash(userNumber);
		
		// 이렇게 hash 값으로 입력값과 인증번호를 비교한다
		boolean flag = userHash.equals(sessionHash);
		
		System.out.println(sessionHash);
		System.out.println(userHash);
		System.out.println(flag);
		
		HashMap<String, String> ret = new HashMap<String, String>();
		ret.put("status", flag ? "OK" : "Fail");
		ret.put("message", flag ? "인증이 완료되었습니다" : "인증번호를 다시 확인해주세요");
		
		return ret;
	}
}
