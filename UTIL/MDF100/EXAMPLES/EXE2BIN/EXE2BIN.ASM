;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (C) Armourer (FIDOnet 2:461/29.444 aka 2:461/35.444)
; �८�ࠧ���⥫� EXE -> BIN
; (����� exe2bin.mdf ��� Universal Modifier 1.00)
;
; ���������� ���� ���������⥩ Universal Modifier :) ,
; � ⠪�� �����뢠��, ��� ���४⭮ ��� � DOS � ��砥 �訡��
;
cseg	segment
	assume	cs:cseg

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Startup-��楤��
;
; ��� ࠡ��� �믮���� ������ ���, �������� �᭮����� ���� ���,
; ���⮬� �����頥�� ���祭�� -- DI - ����� ����� 䠩�� (��᫥ ��१����
; ���������), CX - 0, DX - ����।���� ;)
;
start	proc	near
	push	es
	pop	ds

	xor	bx, bx			; �������� ����⠭� ;)

	; �஢��塞 ᨣ������ EXE-䠩��
	mov	dx, offset @@invalid_signature
	cmp	word ptr ds:[bx], 'ZM'
	jne	@@err_exit

	; ������ ��६�饭�� ������ ���� ���⮩
	mov	dx, offset @@not_0_relocations
	cmp	word ptr ds:[6], bx
	jne	@@err_exit

	; �� �᫮��� �믮����� - 㬥��蠥� ࠧ��� 䠩�� �� ��� ���������
	mov	si, word ptr ds:[8]
	shl	si, 1
	shl	si, 1
	shl	si, 1
	shl	si, 1

	; ������ � SI ����� ����� ��������� � ����� -
	; � ⠪�� ���� ��ࢮ�� ���� �� ����������
	mov	cx, di
	sub	cx, si
	xor	di, di
	cld
	rep	movsb

	; �� ��ࠬ���� �� ��室� 㦥 ��⠭������ ;)

	; �����頥��� � Universal Modifier
	retf

	; �뢮� ᮮ�饭�� � ��室 � DOS (� ��砥 �訡��)
@@err_exit:
	push	cs
	pop	ds
	mov	ah, 9
	int	21h

	; ���ࠥ� � �⥪� ᬥ饭�� ��室�
	pop	ax

	; ������ �㤠 ���� int 20h � PSP Universal Modifier
	push	bx

	; ��室�� � DOS
	retf

@@invalid_signature:
	db	'This file hasn',39,'t a valid EXE signature (',39,'MZ',39,')'
	db	13,10,'$'

@@not_0_relocations:
	db	'The relocation table of this file is not empty.',13,10,'$'

start	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ���� startup-��楤��� ��� Universal Modifier
;
	dw	offset start
cseg	ends
end	start
