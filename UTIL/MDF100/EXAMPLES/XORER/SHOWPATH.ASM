;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (C) Armourer (2:461/29.444 aka 2:461/35.444)
; ����� ��� ����᪠ �� environment
;
cseg	segment
	assume	cs:cseg
	org	100h
start	proc	near
	; �� �嬠 - �� ᠬ�� ���� ��᫥ ��ࠡ�⪨ �ᯠ���騪�
	; �ࠢ����� �㤥� ��।��� �� begin
	; ��室��
@@exit:
	retn

begin:
	; ��⠭�������� ES:DI �� environment
	push	word ptr ds:[2ch]
	pop	es

	; �饬 �ਧ��� ���� environment - db 1
	xor	di, di
	mov	al, 1
	mov	cx, 7fffh	; �᫨ ���� �� ������
	cld
	repne	scasb

	; �� �᫨ ��-⠪� �� ��諨
	or	cx, cx
	je	@@exit

	; ��� �㦥� DS:SI
	push	es
	pop	ds
	xchg	si, di

	; �ய�᪠�� 1 ���� - db 0
	lodsb

	; �뢮��� ��ப�
@@next:	
	lodsb
	int	29h
	or	al, al
	jne	@@next

	; ��室 � ��砥 �ᯥ� ���᪮�
	retn
	
start	endp
	; ����� ���� �窨 ����
	; ��� ��஢騪� Simplest / Universal Protector 1.00
	dw	offset begin

cseg	ends
end	start
