;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (C) Armourer (FIDOnet 2:461/29.444)
; �८�ࠧ������ .com-䠩��� � .exe � �������
; (����� com2exe.mdf ��� Universal Modifier 1.00)
;
cseg	segment
	assume	cs:cseg

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ��楤�� ���樠����樨 �⥪� ⠪, ��� �㦭� ��� .com
;
; �� ��楤�� ��ࢮ� ����砥� �ࠢ����� �� ���� �८�ࠧ�������� 䠩��
;
cominit		proc	near

	mov	word ptr ds:[0], bp	; ��஥ ���祭�� BP ��࠭塞 � PSP
	mov	bp, sp			; �� ���� ������� int 20h
	mov	word ptr [bp], 0
	mov	bp, word ptr ds:[0]
	mov	word ptr ds:[0], 20cdh

	db	0e9h		; jmp 100h
jstart:	dw	-2
cominit		endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Startup-��楤��
;
; ����砥� �� �室�:
;	ES:0	- �室��� 䠩�
;	DI	- ����� �室���� 䠩��
;	SS:BP	- ��������� ��ப�
;
; �⤠�� �� ��室�:
;	DI	- ����� ������
;	DX	- 0
;	CX	- 0
;
; �᫨ �� �室� ��������� 䠩� ⨯� .com, �� �८�ࠧ���� � .exe
;
; �᫨ �� �室� ��������� .exe-䠩�, �믮������ �஢�ઠ �� ᮢ�������
; ���⮢��� ���� � ⥬, �� ������ com2exe � 䠩���� ⨯� .com
; �᫨ �� ᮢ������, 䠩� �८�ࠧ���� ���⭮ � .com
;
startup		proc	near

	cmp	word ptr es:[0], 'ZM'
	je	@@exe

	; �஢��塞 - �� ᫨誮� �� ������ 䠩� ?
	mov	dx, offset toolong
	cmp	di, -(offset startup)
	jnc	@@2dos

	; �ॢ�頥� .com � .exe ��⥬ �ਯ��뢠��� ���������
	; ��⠭�������� � ��������� ���⮢� ���� �� cominit
	add	word ptr _ip, di

	; �����뢠�� cominit
	xor	si, si
	mov	cx, offset jstart
	cld
	rep	movsb
	lodsw			; ��६ ᬥ饭�� �� jmp near
	sub	ax, di		; ���४��㥬 ���
	stosw

	; �ਢ���� � ᮮ⢥��⢨� ����� � ���������
	mov	ax, di			; ����� 䠩��...
	add	ax, 20h			; ...���� ����� ���������
	call	calc_len		; ��⠭��������

	; ��७�ᨬ ��� �����
	mov	si, di
	add	di, 20h - 1		; ����� 䨪⨢���� .exe-���������
	push	di
	std
@@1:
	dec	si
	mov	al, byte ptr es:[si]
	stosb
	jne	@@1

	; ����뢠�� ���������
	mov	di, si
	mov	si, offset header
	mov	cx, 1ch			; ����� 䨪⨢���� .exe-���������
	cld
	rep	movsb

	pop	di		; ����⠭�������� ����� 䠩��
	inc	di

@@exit:
	xor	cx, cx
	xor	dx, dx
	retf

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ���⭮� �८�ࠧ������ .exe � .com
@@exe:
	; �०�� �ᥣ� �஢��塞, �뫮 �� �� �����-� .com,
	; �८�ࠧ������ ��⥬ ���� � .exe

	mov	ax, di			; �ࠧ� ��६ ����� 䠩��

	; �஢�ઠ ���� ���樠����樨
	std
	sub	di, 2
	sub	word ptr jstart, di	; ��४��㥬 ���� ���室�
	add	word ptr jstart, 20h	; � �⠫���
	mov	si, offset jstart
	mov	cx, si
	rep	cmpsb
	je	@@pass1

	; �᫨ ���⭮� �८�ࠧ������ ����������, �뢮��� ᮮ�饭�� �
	; �뢠�������� � DOS
@@imposs:
	mov	dx, offset imp2conv

@@2dos:
	mov	ah, 9
	int	21h
	pop	ax
	xor	ax, ax
	push	ax
	retf


@@pass1:
	; ���⮢� ���, �த�, � ���浪�.
	; �஢��塞 ���������

	; ���४��㥬 ᮮ⢥�����騥 ���� � �⠫����� ���������
	add	word ptr _ip, di	; ���⮢� IP
	sub	word ptr _ip, 20h

	call	calc_len		; ����� 䠩��

	; �ࠢ������ �, �� ����� � ��砫� ��⮢��� 䠩��, � �⠫����
	mov	bp, di			; ���࠭塞 ����� 䠩��
	xor	di, di
	mov	si, offset header
	mov	cx, 1ch
	cld
	rep	cmpsb
	jnz	@@imposs

	; �⠪, ��諮 �६� �������஢���.
	; �������� 䠩� �� ���� ���������
	add	di, 4			; 4 ���� ��᫥ ��������� - �� �����
	sub	bp, di			; ����� 䠩�� ��᫥ 㤠����� ���������
	mov	si, di
	xor	di, di
	mov	cx, bp
	push	es
	pop	ds
	rep	movsb

	; ��室��
	mov	di, bp
	jmp	@@exit
	
startup		endp


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ��⠭���� ᮮ⢥������� ����� � �⠫����� ��������� .exe-䠩��
	; �� �室� � AX ������ ������ ����� 䠩�� � �����
	;
calc_len	proc	near

	xor	dx, dx
	mov	dl, ah
	shr	dx, 1
	inc	dx
	and	ah, 1
	mov	word ptr pagecount, dx	; � DX - �᫮ ��࠭��
	mov	word ptr partpage, ax	; � � AX - ����� ��᫥���� ��࠭���,

	retn
calc_len	endp


	; ��������� ��� .com-䠩��, �ॢ���騩 ��� � .exe
header:
		dw	'ZM'	; �������� .exe-䠩��
partpage:	dw	?	; ����� ��᫥���� ��࠭���
pagecount:	dw	?	; ��᫮ ��࠭��
numrelocs:	dw	0	; ��᫮ ��६�饭��
headersize:	dw	2	; ������ ��������� .exe (� ��ࠣ���)
minmem:		dw	1000h	; �������쭮 ����室��� ��ꥬ �����
maxmem:		dw	1000h	; ���ᨬ��쭮 ����室��� ��ꥬ �����
_ss:		dw	-10h	; ������� �⥪� == ᥣ����� PSP
_sp:		dw	-2	; �����⥫� �⥪�
checksum:	dw	0	; Dummy field ;)
_ip:		dw	100h	; start IP
_cs:		dw	-10h	; start CS
reltable:	dw	0	; ������ ��६�饭�� (����� ;)
overlaynum:	dw	0	; �᭮���� �����


	; ����饭�� � ������������ ᪮�����஢��� .exe � .com
imp2conv:
	db	'Sorry, but I can',39,'t to convert this file back to .com'
	db	13,10,'$'


	; ����饭�� � ������������ ᪮�����஢��� ������ 䠩�
toolong:
	db	'Sorry, but this file too long to convert to .exe'
	db	13,10,'$'

	; ���� startup-��楤��� ��� Universal Modifier
		dw	offset	startup

cseg	ends
end
