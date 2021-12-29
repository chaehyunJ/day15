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
	.box-inner{
		display: flex;
		justify-content: space-between;
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
		<div class="box-inner">
			<h3>인증번호 입력</h3>
			<div class="timer"></div>
		</div>
		<div>
			<input type="text" name="auth" placeholder="인증번호를 입력하세요">
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
	
	
	let second = 180
	let interval = 0
	
        function timer(){
		
			let min = Math.floor(second / 60) + ''
            let sec = second % 60 + ''
            if(min.length < 2) min = '0' + min
            if(sec.length < 2) sec = '0' + sec
            const format = min + ':' + sec
            const div = document.querySelector('.timer')
            div.innerText = format

            if(second <= 0){
            	div.style.color = 'red'
            	clearInterval(interval)
            	authMailForm.querySelector('input').placeholder = '유효시간이 지났습니다'
            	authMailForm.querySelector('input').disabled = 'disabled'
            	
            	authMailMsg.innerText = '인증번호를 다시 발송해주세요'
            	authMailMsg.style.color = 'red'
            }
            second -= 1
            
            
            
        }
	
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
				
				
				interval = setInterval(timer, 1000)
				// 메일을 보내고 나면 시간을 초기화한다
				second = 180
				
				// disabled : 비활성화 요소 선택, 클릭, 입력, 포커스를 받을 수 없는 요소
				authMailForm.querySelector('input').disabled = ''
				authMailForm.querySelector('input').placeholder = '인증번호를 입력하세요'
				authMailForm.querySelector('input').focus()
				
				authMailMsg.innerText = ''
			}
		})
	}
	
	function authMailHandler(event){
		event.preventDefault()
		if(second <= 0){
			alert('유효시간이 지났습니다. 다시 메일을 보내주세요')
			return
			// 유효시간이 만료되었다면 이후 코드를 진행하지 않는다
		}
		const auth = event.target.querySelector('input[name="auth"]')
		const url = cpath + '/getAuthResult/' + auth.value + '/'
		const opt = {
			method : 'get'
		}
		fetch(url, opt)
		.then(resp => resp.json())
		.then(json => {
			console.log(json)
			authMailMsg.innerText = json.message
			
			if(json.status == 'OK'){
				authMailMsg.style.color = 'bule'
				auth.disabled = 'disabled'
				
				// 인증에 통과했을 경우 진행할 수 있는 다음 버튼을 보여주거나, 기타 처리를 하면 된다
				
				clearInterval(interval)
				document.querySelector('.timer').innerHTML = ''
			}
			else{
				authMailMsg.style.color = 'red'
				auth.select()
			}
		})
		
	}
	
	sendMailForm.onsubmit = sendMailHandler
	authMailForm.onsubmit = authMailHandler
</script>
</body>
</html>