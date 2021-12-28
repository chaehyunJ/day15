<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cpath">${ pageContext.request.contextPath }</c:set>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>home.jsp</title>
<style>
	h3{
		margin : 5px;
	}
	.box{
		width : 450px;
		box-sizing: border-box;
/* 		display: flex; */
/* 		flex-flow : column; */
/* 		justify-content: center; */
		border : 5px solid black;
		border-radius: 5px;
		margin-top : 10px;
		padding : 10px;
	}
	.hidden{
		display: none;
	}
</style>
</head>
<body>

<h1>day15_1 - hash,mail</h1>
<hr>

<form id="sendMailForm">
	<div class="box">
		<h3>이메일 주소 입력</h3>
		<div>
			<input type="email" name="email" placeholder="E-Mail" required autocomplete="off">
			<input type="submit" value="인증번호 전송">
		</div>
		<div id="sendMailMsg"></div>
	</div>
</form>

<form id="authMailForm" class="hidden">
	<div class="box">
		<h3>인증번호 입력</h3>
		<div>
			<input name="auth" placeholder="인증번호를 입력하세요">
			<input type="submit" value="인증">
		</div>
		<div id="authMailMsg"></div>
	</div>
</form>


<script>
	const cpath = '${ cpath }'
	const sendMailForm = document.getElementById('sendMailForm')
	const sendMailMsg = document.getElementById('sendMailMsg')
	const authMailForm = document.getElementById('authMailForm')
	const authMailMsg = document.getElementById('authMailMsg')
	
	
	function sendMailHandler(event){
		event.preventDefault()
		const email = event.target.querySelector('input[name="email"]')
		// Pathvariable 사용할 때 특수문자가 들어가면 인식을 못하는 경우도 있어서 /로 끊어주는 것이 좋다
		
		const url = cpath + '/mailto/' + email.value + '/'
		const opt = {
			method : 'get'
		}
		fetch(url, opt)
		.then(resp => resp.json())
		.then(json => {
			console.log(json)
			sendMailMsg.innerText = json.message
			sendMailMsg.style.color = json.status == 'OK' ? 'blue' : 'red'
			if(json.status == 'OK'){
				authMailForm.classList.remove('hidden')
				authMailForm.querySelector('input').focus()
			}
		})
	}
	
	sendMailForm.onsubmit = sendMailHandler
	
</script>
</body>
</html>