section .text
	global _start
_start:
	mov rbp, rsp ; reset the rbp


	; create the fd/setup sockets
	mov rax, 41 ; sets syscall to sys_socket
	mov rdi, 2 ; AF_INET
	mov rsi, 1; SOCK_STREAM
	mov rdx, 0 ;???? IP PROTO IP?
	;mov rdi, msg
	syscall
	mov r8, rax ; contains the fd



	; create the fd/setup sockets sys_BIND
	mov rax, 49 ; sys_connect
	mov rdi, r8 ; sets fd
	push qword 0x0 ; 32 bits long (char array of 8)
	mov r9, 16777343
	push qword r9 ;address here through inet pton, long s_addr 2130706433 = 127.0.0.1 2147483902
	push word 23569; unsinged short port, htons(3490) 16 bit port (shorts are 16 bit)
	push word 2; sin family; AF_INET
	mov rsi, rsp; socket addr struct ; push everything in reverse
	mov rdx, 96 ;length of address
	syscall
	add rsp, 96 ; Removed the pushed stuff :)


	; 46 - sys_listen
	mov rax, 50 ; sys_sendmsg
	mov rdi, r8 ; sets fd
	mov rsi, 5
	syscall




	; ; 46 - sys_sendmsg
	; mov rax, 44 ; sys_sendmsg
	; mov rdi, r8 ; sets fd
	; push 0x61616161
	; mov rsi, rsp; buffer 
	; mov rdx, 4; length
	; ; push qword 0x0 ; 32 bits long (char array of 8)
	; ; mov r9, 16777343
	; ; push qword r9 ;address here through inet pton, long s_addr 2130706433 = 127.0.0.1 2147483902
	; ; push word 23569; unsinged short port, htons(3490) 16 bit port (shorts are 16 bit)
	; ; push word 2; sin family; AF_INET

	; ; mov r8, rsp ;sockaddr
	; ; mov r9, 96 ; length
	; syscall
	; add rsp, 96 ; Removed the pushed stuff :)


	jmp whileloop

whileloop:
	;accept in here
	mov rax, 43 ; sys_sendmsg
	mov rdi, 3 ; sets fd make this dynamic
	mov rsi, rsp
	sub rsi, 128
	mov rdx, rsp
	syscall
	push rax


	pop rdi
	; ;sendto
	; mov rax, 44 ; sendto
	; ;mov rdi, 3 ; fd
	; pop rdi
	; mov rsi, msg ;message
	; mov rdx, 5 ; length
	; mov r10, 0 ; flags ; so after all that we just need the fd xD this is why its important to clean up when disconnected
	; ; mov r8, rsp ; sockaddr struct
	; ; sub r8, 128 ; actual address
	; ; mov r9, rsp ; length of addstruct
	; syscall


	;sys_receve from
	mov rax, 45 ; recvfrom
	mov rdi, rdi ; doesnt change
	mov rsi, rsp ; setting it rsp-8 down
	sub rsi, 256 ; 512 covers it fine
	mov rdx, 256 ; length
	syscall
	push rdi

	;write the output
	mov rax, 1
	mov rdi, 1
	mov rsi, rsp
	sub rsi, 256
	mov rdx, 256
	syscall



	;send response


	
	;sendto
	mov rax, 44 ; sendto
	;mov rdi, 3 ; fd
	pop rdi
	mov rsi, resp ;message
	mov rdx, lenResp ; length
	syscall

	;close socket
	mov rax, 3
	syscall

	jmp whileloop
exit:
	xor edi,edi ; return value = 0
	mov eax,60 ; system call num sys_exit
	syscall ; hello kernel

section .data
	msg db 'hello'
	resp db 'HTTP/1.1 200 OK',10,'Host: 127.0.0.1',10,'Connection: close',10,'Content-Type: Text/html; charset=UTF-8',10,'Content-Length: 32',10,'Accept-Ranges: bytes',10,10,'<html>Assembly Webserver!</html>',10
	lenResp equ $-resp