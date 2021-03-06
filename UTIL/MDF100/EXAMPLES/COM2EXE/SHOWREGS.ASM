;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (C) Armourer (FIDOnet 2:461/29.444)
; ����� ᮤ�ন���� ॣ���஢ �� ���� .com �ணࠬ��
;
cseg	segment
	assume	cs:cseg
	org	100h

; ����� ��� �뢮�� ᮤ�ন���� ॣ����
show	macro	reg
	ifdif <reg>,<ax>
		mov	ax, reg
	endif
	call	show_ax
endm

; ��窠 �室�
start		proc	near

	; ��᫥����⥫쭮 �뢮��� ᮤ�ন��� ॣ���஢, 㪠������ � ᯨ᪥
	irp	reg, <ax,si,cs,bx,di,ds,cx,bp,es,dx,sp,ss>
		show	reg
	endm

	; �뢮� १����
	mov	dx, offset res
	mov	ah, 9
	int	21h
	retn

start		endp

; ��楤�� �뢮�� ᮤ�ন���� AX
show_ax		proc	near

	xchg	di, word ptr [curptr]		; ��६ 㪠��⥫� � DI

	push	ax
	call	out_al		; �뢮��� ���� 2 ����
	pop	ax
	mov	al, ah		; �뢮��� ���� 2 ����
	call	out_al

	add	di, 17		; �த�������� � ᫥���饬� ॣ�����

	xchg	di, word ptr [curptr]		; ����⠭�������� DI
	retn

	; �����⥫� �� ��᫥���� ���� ���� �뢮�� ��� ⥪�饣� ॣ����
curptr:		dw	offset regs_field

show_ax		endp


	; �뢮� ���� �� AL � ��⭠����筮� ����
out_al		proc	near
	db	0d4h, 10h	; AAM � ����䨪��஬ - ������� �� 16
	call	out_16		; �뢮��� ������� ����
	mov	al, ah		; ������ - ������


		; �뢮� ��⭠����筮� ���� �� AL
	out_16		proc	near
		cmp	al, 0ah		; �᫨ �����, � �� ok
		jc	@@ok
		add	al, 'A'-'0' - 0ah	; ������塞 ࠧ���� � ����
	@@ok:	add	byte ptr [di], al	; ��襬 ���� �� ����
		dec	di			; � ���室�� � ᫥���饩
		retn
	out_16		endp


out_al		endp


	; ���⠢�� � ⠡��窠 � १���⮬ ࠡ���
res:
       db 13,10,'�����������������������������������������������������'
       db 13,10,'� (C)  ANS  (Armourer)	    ShowRegs	 FreeWare'
       db 13,10,'� FIDOnet 2:461/29.444	     V 1.00	SourceWare'
       db 13,10,'�'
       db 13,10,'�	  Proc Regs at Start of .com in DOS'
       db 13,10,'�	�������������������������������������'


	; ��砫� �ଠ�஢������ ���� � ���祭�ﬨ ॣ���஢
	; ���������� �� ࠡ�� show_ax

       db 13,10,'�	� AX:000'

regs_field:
       db		       '0      SI:0000      CS:0000'
       db 13,10,'�	� BX:0000      DI:0000      DS:0000'
       db 13,10,'�	� CX:0000      BP:0000      ES:0000'
       db 13,10,'�	� DX:0000      SP:0000      SS:0000'


       db 13,10,'�	�'
       db 13,10,'�'
       db 13,10,'�'
db 13,10,10
db '$'

cseg	ends
end	start
