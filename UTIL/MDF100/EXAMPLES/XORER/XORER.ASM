;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (C) Armourer (2:461/29.444 aka 2:461/35.444)
; ���⥩�� ��஢�� 䠩�� �� xor
; (����� xorer.mdf ��� universal modifier 1.00)
;
; ����室���� �᫮��� ��� ���४⭮� ࠡ��� �⮩ �����:
; ��᫥���� ��� ���� ���頥���� 䠩�� ������ ᮤ�ঠ�� ���� �窨 �室�
; (�� ����� �⫨����� �� 100h, �� ᢮��� � 㬠 ����ᯠ���騪�)
; �᫨ 䠩� �� �⢥砥� �⮬� �ॡ������, �� ����� ����� �ਢ��� ���
; � ��⢥��⢨� �� � ������� hex-mode �� ����७��� ।����
; Volkov Commander'� ;)
;
cseg	segment	para
	assume	cs:cseg
	locals

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; �᭮���� ��� �����
;
; �㤥� �ਯ�ᠭ � ����� �ᯮ��塞��� 䠩��
; � ��砫� �ᯮ��塞��� 䠩�� �㤥� ������� CALL main
;
main	proc	near
	; ��६ ���� ��ࢮ�� ������஢������ ����
	pop	di

	; ��६ 楫���� ���� ��� �᪮��஢����� ����
	xchg	si, di		; � SI �� ���� .com-�ணࠬ� ����� 100h

	; ��᪮���㥬 䠩�
len	=	$ + 1		; ���� ᫮�� � ������ ����஢������ 䠩��
	mov	cx, 0

	mov	al, 73h		; ���祭�� ��஢����

@@decode_loop:
	xor	byte ptr [si], al
	movsb
	loop	@@decode_loop

	; ����㥬
	jmp	[di - 2]

main	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; �� ��楤�� ����� �� xor �, �� �� ����, ��⥬ � ����� ��஢�����
; ������ �����뢠�� ����஢騪.
; "��樠���" �� ����஢騪 �।�⠢��� ᮡ�� CALL �� ��楤��� main,
; ����ᠭ��� � ����� 䠩��
;
; ��᫥���� ��� ���� ���㥬��� 䠩�� ������ ᮤ�ঠ�� ���� �窨 �室�
;
; �� ���� �� ����� ES:0 ����� �����, �������騥 ��஢��,
; � DI ᮤ�ঠ�� ����� ��� ������
;
; �����頥� � DI ����� ����஢����� ������, � CX - 3,
; � DX - ���� CALL main
; 
startup	proc	near
	; ���饭�� ���⮢�� �窨 �� ���쬥� �� 䠩��

	; ���࠭�塞 ���� ��᫥����� ���� �� 墮�⮬ ������
	push	di

	; � ��� �� ��襬 � ���� ��砫쭮�� CALL
	mov	word ptr ds:[start+1], di	; ��䨪� �㦥� ��� ��㯮��
						; Tasm'�, ����� ���� �⠢��
						; ��䨪� cs:

	; ���࠭塞 ����� ���㥬�� ������ ��� main
	; (� ����� ��஢�� ����� ������ �� �������)
	mov	word ptr ds:[len], di

	; �����뢠�� ��楤��� �᪮��஢���� � 墮��� ������
	xor	si, si
	mov	cx, offset startup
	cld
	rep	movsb

	; ����⠭�������� ���� ��᫥����� ���� �� 墮�⮬ 䠩��
	pop	si

	; ����㥬 �����
	mov	al, 73h		; ��� ��஢����

@@encode_loop:
	xor	byte ptr es:[si-1], al	; SI 㪠�뢠�� �� ����, ᫥���騩
	dec	si			; �� ⥬, ����� �㦭� �ᯠ������
	jne	@@encode_loop	; �஬� ⮣�, ⠪�� �������� ���� ���
				; ����������� ᤥ���� ���⮩ 横� �� SI == 0,
				; ��࠭���� �� �⮬, �� ���� �� ����� 0
				; ⮦� �㤥� ����஢��.

	; ����� � DI ����� ����� ����� 䠩�� (��� ��� ���⮢��� call)
	; ��⠭�������� CX � DX
	mov	cx, 3			; ����� ���⮢��� CALL
	mov	dx, offset start	; ���� ���⮢��� CALL

	; �����頥��� � protect
	retf
startup	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ��� CALL �������� � ��砫� ����஢������ 䠩��, � ���� ���室�
; ���४������ ⠪, �⮡� 㪠�뢠�� �� ����஢騪, �ਯ�ᠭ�� � �����
; 䠩��
;
start:	
	db	0e8h		; CALL near ptr �� ᫥������ �������
	dw	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ����� ����� ���� startup-��楤��� ��� universal modifier
;
dw	offset startup

cseg	ends
end	main
