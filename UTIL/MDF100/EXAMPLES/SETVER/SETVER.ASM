;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (C) Armourer (FIDOnet 2:461/29.444)
; ����⠭���� �㦭��� ����� ���ᨨ DOS ��� "�ᮡ� 㬭��" �ணࠬ�
;
; ����訢����� ���祪 ����, ���墠�뢠�騩 int 21h/fn 30h � �������騩
; �㦭�� ���祭��.
;
; �� ����䨪�樨 .com-䠩�� �ਢ������ � .exe-���� � ����� ��ࠡ��뢠����
; ��� .exe.
;
sizeofTSR	=	4	; ������ १����⭮� ��� SetVer � ��ࠣ���
				; (� ��⮬ ᮡ�⢥����� ����� MCB)
stacksize	=	9	; ������ �⥪� (� ᫮���), ����室��� ���
				; ���४⭮� ࠡ��� ���樠����樮���� ��楤���

;exehdr	struc		; ������� ��������� .exe-䠩��
;	sign		dw	'MZ'
;	partpage	dw	?
;	pagecount	dw	?
;	relocs		dw	?
;	hdrsize		dw	?
;	minmem		dw	?
;	maxmem		dw	?
;	_ss		dw	?
;	_sp		dw	?
;	chksum		dw	?
;	_ip		dw	?
;	_cs		dw	?
;	reloc_offs	dw	?
;	overlays	dw	?
;exehdr	ends


	locals
cseg	segment
	assume	cs:cseg

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ����᭮� ��� ��� .exe-䠩��
;
; ���⮨� �� ��� ��⥩:
; 1. ��ࠡ��稪 int 21h
;    ��᫥������ ����� �� ����祭�� ����� ���ᨨ DOS
; 2. ��ࠡ��稪 int 22h (terminate proc)
;    ����⠭�������� �ਣ������ ����� int 21h (��⠫쭮� ᤥ���� DOS ;)
; 3. ���樠����樮���� ����
;    ��⠭�������� ��� 1 � 2 � �ନ��� ࠡ���� �।� ��� �믮������ .exe
;
; ����� ᮤ�ন� �६���� �⥪ .exe-䠩��, ����� �������� 3 ���� ��
; ��砫쭮� ���樠����樨 ��⥩ 1 � 2
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ��ࠡ��稪 int21
;
; ��᫥������ �㭪�� 30h � �����頥� � AX �㦭� ����� ���ᨨ DOS
;
int21		proc	near

cmp_1b	=	$		; ���� ���⮪ ���������饣��� ����
				; (��� �஢�ન �� ����୮� ����訢����)

	cmp	ah, 30h		; ����ਬ ����� �㭪樨
	jne	@@exit

cmp_1e	=	$ + 2		; ����� �����稢����� ���� ���⮪

highnum	=	$ + 1		; �㦭� ����� ���ᨨ �� ���樠����樨 ������
lownum	=	$ + 2		; �����।�⢥��� � ��� ������� MOV
	mov	ax, 0		; ����㦠�� ����� ���ᨨ

cmp_2b	=	$

	xor	cx, cx		; ��� ����
	xor	dx, dx
	iret			; ��室�� �� ���뢠���

@@exit:				; �室�� �� 楯�窥 ��ࠡ��稪�� int 21h

cmp_2e	=	$ + 1

		db	0eah	; JMP far
old21_o:	dw	?
old21_s:	dw	?

int21		endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Terminate-��楤��
; ����砥� �ࠢ����� �� ��室� �� �᭮���� �ணࠬ��
;
; ����⠭�������� ����� int 21h �� ��室� �� �᭮���� �ணࠬ��
;
int22		proc	near

cmp_3b	=	$

	; ����⠭�������� �०��� ����� int 21h
	push	word ptr cs:[old21_s]
	pop	ds
	push	word ptr cs:[old21_o]
	pop	dx
	mov	ax, 2521h
	int	21h

	; �室�� ����� �� 楯�窥 ��ࠡ��稪��
cmp_3e	=	$ + 1
		db	0eah
old22_o:	dw	?
old22_s:	dw	?

int22		endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ���樠����樮���� ����
;
entry		proc	near

cmp_4b	=	$

	; ���࠭塞 ࠡ�稥 ॣ�����
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	es
	push	ds

	; ���࠭塞 ���� terminate-��楤��� (�� �맮��� DOS �� �����襭��
	; �ணࠬ��)
	push	word ptr ds:[0ah]	; IP
	pop	word ptr cs:[old22_o]
	push	word ptr ds:[0ch]	; CS
	pop	word ptr cs:[old22_s]

	; ����뢠�� ���祪 �� ᢮��� MCB
	push	ds
	pop	ax
	dec	ax
	mov	ds, ax
	sub	word ptr ds:[3], sizeofTSR	; �����蠥� ࠧ��� ⥪�饣� MCB
	add	ax, word ptr ds:[3]		; ����塞 ᥣ���� ��襣� MCB
	inc	ax
	mov	bl, 'M'				; ���� �ணࠬ�� - �� ��᫥����
	xchg	bl, byte ptr ds:[0]		; ��� ���� �㤥� ����� �ਧ���
						; ����� �ணࠬ��
	mov	es, ax
	mov	byte ptr es:[0], bl
	push	word ptr ds:[1]			; �������� �⮣� MCB - �᭮����
	pop	word ptr es:[1]			; �ணࠬ��
	mov	word ptr es:[3], sizeofTSR-1	; ������ �����

	; ��७�ᨬ १������� ���� � ���� ����
	inc	ax
	mov	es, ax		; � ES - ᥣ���� १����⭮�� ����
	push	cs
	pop	ds
	xor	si, si
	xor	di, di
	mov	cx, offset entry
	cld
	rep	movsb

	; ��⠭�������� �����
	; ��⠭�������� ����� int 21h
	xor	ax, ax
	mov	ds, ax
	cli
	xchg	word ptr ds:[21h*4], ax		; ��६ IP
	mov	word ptr es:[old21_o], ax
	mov	ax, es
	xchg	word ptr ds:[21h*4+2], ax	; ��६ CS
	mov	word ptr es:[old21_s], ax
	sti

	; ��⠭�������� ���� terminate-��楤��� � PSP
	pop	ds			; ����⠭��������� ᥣ���� PSP
	mov	word ptr ds:[0ah], offset int22		; IP
	mov	word ptr ds:[0ch], es			; CS

	; ����ࠨ���� ᥣ���� �᭮���� �窨 �室� � �᭮����� �⥪� 
	mov	ax, cs
	add	word ptr cs:original_cs, ax
	add	word ptr cs:original_ss, ax

	; ����⠭�������� ࠡ�稥 ॣ�����
	pop	es
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	; ����⠭�������� �⥪
	cli
	pop	ss
	mov	sp, word ptr cs:original_sp
	sti

	; ���� �᭮����� 䠩��
	jmp	dword ptr cs:[original_ip]

cmp_4e	=	$

entry		endp

		; �०��� ���祭�� ॣ���஢
original_ip:	dw	?	; ��� JMP FAR ���쬥� ���⮢� IP
original_cs:	dw	0	; � CS
original_sp:	dw	?	; ��� MOV ����� ���⮢� SP

		; �६���� �⥪ .exe-䠩��
		dw	stacksize dup(?)	; ����⢥��� �⥪
original_ss:	dw	0	; ��� POP �������� ���⮢� SS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ��楤�� ���樠����樨 �⥪� ⠪, ��� �㦭� ��� .com
;
; �� ��楤�� ��ࢮ� ����砥� �ࠢ����� �� ���� �८�ࠧ�������� 䠩��
;
cominit		proc	near
	mov	word ptr ds:[0], bp		; ���࠭塞 BP �� �����
	mov	bp, sp				; ������� int 20h � PSP
	mov	word ptr [bp], 0
	mov	bp, word ptr ds:[0]
	mov	word ptr ds:[0], 20cdh		; ����⠭�������� int 20h
	db	0e9h		; jmp 100h
jstart:	dw	-2
cominit		endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ���⭮� �८�ࠧ������: �� .exe � .com
;
exe2com		proc	near

	; �஢�ઠ ���������
	add	word ptr minmem, sizeofTSR	; ���४�� �⠫������ ����
						; MinMem
	mov	si, offset maxmem
	mov	di, 0ch
	mov	cx, 4
	rep	cmpsw
	jne	not_our_com

	cmpsw					; IP �ய�᪠��
	cmpsw
	jne	not_our_com

	; �஢�ઠ ���⮢��� ����
	mov	si, offset cominit		; �⠫��
	mov	di, word ptr es:[14h]		; ���� ���⮢��� ����
	sub	di, 0e0h			; � 䠩��
	mov	cx, offset jstart - offset cominit
	rep	cmpsb
	jne	not_our_com

	; ��१��� 墮�� (cominit) � ������ (��������� ;)
	push	es
	pop	ax
	add	ax, 2
	mov	es, ax				; ��१��� ���������

	; ��१��� 墮��
	sub	di, 20h + offset jstart - offset cominit

	pop	ax
	jmp	exit

exe2com		endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; �������� ���� setver �� .exe-䠩��
;
remove		proc	near
	pop	si			; ����⠭�������� �⥪

	; ����� DI 㪠�뢠�� �� original_ss
	mov	ax, word ptr es:[di]
	add	word ptr es:[0eh], ax
	sub	di, offset original_ss - original_sp

	; ����� DI 㪠�뢠�� �� original_sp
	push	word ptr es:[di]
	pop	word ptr es:[10h]
	dec	di
	dec	di

	; ����� DI 㪠�뢠�� �� original_cs
	mov	ax, word ptr es:[di]
	add	word ptr es:[16h], ax
	dec	di
	dec	di

	; ����� DI 㪠�뢠�� �� original_ip
	push	word ptr es:[di]
	pop	word ptr es:[14h]

	; ����⠭�������� (��᪮�쪮 �� �������� ;) ����� ��室���� 䠩��
	sub	di, offset original_ip

	; ���४��㥬 ����� � ���������
	xor	ax, ax
	call	setlen
	mov	word ptr es:[4], dx	; ��᫮ 512-������ ��࠭��
	mov	word ptr es:[2], ax	; ��᫮ ���� �� ��᫥���� ��࠭��

	push	di			; ���࠭塞 ����� 䠩��

	; �஢��塞 - �� ��訩 �� �� .com ?
	cmp	word ptr es:[6], 0	; ��᫮ �室�� � ⠡��� ��६�饭��
	je	exe2com

not_our_com:
	pop	di	; ����⠭�������� ����� (� ����� �஢�ન � exe2com
			; ����� ���᭨����, �� �� - �� ��� .com, � ��
			; �� ����� �८�ࠧ����� ���, � DI �㤥� 㦥 �ᯮ�祭)
exit:
	; CX � DX ����塞
	xor	cx, cx
	xor	dx, dx

	retf
remove		endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Startup-��楤��
;
; ����砥� �� �室�:
;	ES:0	- �室��� 䠩�
;	DI	- ����� �室���� 䠩��
;	SS:BP	- ��������� ��ப�
;
; �⤠�� �� ��室�:
;	DI	- ����� ������ � ����ᮬ
;	DX	- 0
;	CX	- 0
;
startup		proc	near

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; �஢��塞, �� ����� 䠩� ��� �����⨫�
	; �᫨ �� 㦥 �� ��ࠡ�⠭ setver'�� - ᭨���� ��� setver'�
	;
	; �஢��塞 ⨯ 䠩��
	cmp	word ptr es:[0], 'ZM'
	jne	setver			; .com-䠩�� �⯠���� :)

	push	di			; ���࠭塞 ����� 䠩��

	; �ࠢ������ ���⮢� ��� � ⥬, �� �����
	; ����砥� ���� ����
	mov	di, word ptr es:[16h]	; ���⮢� ���� .exe (CS)
	add	di, word ptr es:[8]	; ������ ��������� (� ��ࠣ���)
	mov	cl, 4
	shl	di, cl			; � DI - ��砫� ���⪠ ��� �ࠢ�����
	xor	si, si			; ���饭�� cmp_1b � ᥣ���� ���� .mdf
	mov	bx, offset cmp_table	; BX 㪠�뢠�� �� ⠡���� ������

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ��楤�� �ࠢ����� ���� setver � ���⮢� ����� � .exe-䠩��
;
; ��� �ࠢ����� �ᯮ������� ����� � ���������� (�� ᮤ�ঠ�� ������)
; ���⪠� ����. �� ����� ࠧ��饭� � ⠡��� cmp_table, �� ������
; 㪠�뢠�� BX.
; �ࠢ����� ��稭�����, ��� ���筮, � ����樨 DS:SI � ES:DI
;
compare		proc	near

	mov	cx, word ptr [bx]	; ����� ���⪠
	inc	bx
	inc	bx
	or	cx, cx			; �ਧ��� ����砭�� ⠡����
	je	remove			; �� ����砥� ����稥 �筮� �����
					; ���⮢��� ���� setver � .exe-䠩��
	cld
	rep	cmpsb			; �ࠢ������

	add	si, word ptr [bx]	; ���室�� � ��砫� ���⪠
	add	di, word ptr [bx]
	inc	bx
	inc	bx

	or	cx, cx			; ��������� �� ⮫쪮 �� �஢�७��� ?
	je	compare			; ��������� - �த������ �ࠢ�����

compare		endp

	pop	di			; ����⠭�������� ����� 䠩��

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ����⢥��� ��⠭���� �������㠫쭮�� setver'�
	;
setver:
	mov	si, sp			; ��� ���४⭮�� ������

	; ��⠥� �� ��������� ��ப� ����� ���ᨨ
	mov	ax, word ptr [bp]
	cmp	ah, '.'			; �� ����� ���ᨨ ?
	je	@@checkhigh		; �� - �஢��塞 ���

	; �� ��⠫쭮� - �� �㪠���� ;)
@@vererr:
	; ����� ���ᨨ DOS 㪠��� ���ࠢ��쭮
	; �뢮��� ᮮ�. ᮮ�饭��
	mov	dx, offset @@vererrmsg

todos:
	; �뢮� ᮮ�饭�� � �뫥� � DOS
	mov	ah, 9
	int	21h

	; �뫥⠥� � DOS
	mov	sp, si			; ������ � �⥪ ���� int 20h
	pop	ax			; � PSP Universal Modifier'�
	xor	ax, ax
	push	ax
	retf				; ����⢥��� ��室 � DOS

check_ax:
	; �஢�ઠ - � AX ������ ���� ��㯠�������� ASCII-�᫮ �� 0 �� 99
	; ������ �᫮ ��ॢ������ � ������� ���
	call	check_al
	xchg	al, ah

check_al:
	; �஢�ઠ - � AL ������ ���� ASCII-��� �� 0 �� 9
	; ������ ��� ��ॢ������ � ������� ���
	sub	al, '0'
	jc	@@vererr	; ���誮� ����
	cmp	al, 10
	jnc	@@vererr	; ���誮� �����
	retn

@@checkhigh:
	; �஢��塞 � ��࠭塞 ���訩 ����� ���ᨨ (1 ���)
	call	check_al		; �஢��塞 ���४⭮��� ���襩 ����
	mov	byte ptr highnum, al	; ���࠭塞 ���訩 ����� ���ᨨ

	; �஢��塞 � ��࠭塞 ����訩 ����� ���ᨨ (2 ����)
	mov	ax, word ptr [bp+2]	; ��६ ᫥���騥 2 ����
	call	check_ax		; �஢��塞 ���४⭮���
	aad				; ����砥� ����訩 ����� ���ᨨ
	mov	byte ptr lownum, al	; ���࠭塞 ����訩 ����� ���ᨨ

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ��蠥� �� 䠩� ��� setver
	;
	; �஢��塞 ⨯ 䠩��
	cmp	word ptr es:[0], 'ZM'
	je	@@exe

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; �ॢ�頥� .com � .exe ��⥬ �ਯ��뢠��� ���������
	;
	; ��⠭�������� � ��������� ���⮢� ���� �� cominit
	add	word ptr _ip, di

	; �����뢠�� cominit
	mov	si, offset cominit
	mov	cx, offset jstart - offset cominit
	cld
	rep	movsb
	lodsw			; ��६ ᬥ饭�� �� jmp near
	sub	ax, di		; ���४��㥬 ���
	stosw

	; �ਢ���� � ᮮ⢥��⢨� ����� � ���������
	mov	ax, 20h			; ����� ��������� ��� ��襣� .com
	call	setlen
	mov	word ptr pagecount, dx	; � DX - �᫮ ��࠭��
	mov	word ptr partpage, ax	; � � AX - ����� ��᫥���� ��࠭���,

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

@@exe:
	; ����� � ��� �� ����� ES:0 ����� .exe-䠩�
	; � � DI ����� ��� �����

	;;;;;;;;;;;;;;;;;;;;;;
	; ����訢��� ᢮� ���

	; ��ࠢ������ ����� 䠩�� �� �࠭��� ��ࠣ��
	add	di, 15
	and	di, 0fff0h

	; ���࠭塞 ����� ��� �室� � �⥪
	mov	ax, di				; ���� CS
	shr	ax, 1
	shr	ax, 1
	shr	ax, 1
	shr	ax, 1
	sub	ax, word ptr es:[8]		; ���⠥� ࠧ��� ���������
	sub	word ptr original_cs, ax	; ��� ���� �㤥� ᪮�४�-
						; ஢��� CS �� ����
	sub	word ptr original_ss, ax	; �� �� ��� SS

	push	ax				; CS == SS
	xchg	ax, word ptr es:[16h]		; ���� CS ��६ � AX
	add	word ptr original_cs, ax	; ���࠭塞 ���� CS
	pop	ax
	xchg	ax, word ptr es:[0eh]		; ��६ ���� SS � AX
	add	word ptr original_ss, ax	; ���࠭塞 ���� SS

	mov	ax, offset entry		; ���� IP
	xchg	ax, word ptr es:[14h]		; ���� IP ��६ � AX
	mov	word ptr original_ip, ax	; ���࠭塞 ���� IP

	mov	ax, offset original_ss		; ���� SP
	xchg	ax, word ptr es:[10h]		; ���� SP ��६ � AX
	mov	word ptr original_sp, ax	; ���࠭塞 ���� SP

	; �����稢��� ���� minmem - �⮡� ����� 㢥७����� � ����稨
	; ����室����� ��ꥬ� �����
	add	word ptr es:[0ah], sizeofTSR
	jnc	@@minmem_correct
	sub	word ptr es:[0ah], sizeofTSR

@@minmem_correct:
	; �����뢠�� � 墮�� ᢮� ���
	xor	si, si
	mov	cx, offset cominit
	rep	movsb

	; ���४��㥬 ����� 䠩��
	xor	ax, ax			; ����� ��������� 㦥 ��⥭� � DI
	call	setlen
	mov	word ptr es:[4], dx	; ��᫮ 512-������ ��࠭��
	mov	word ptr es:[2], ax	; ��᫮ ���� �� ��᫥���� ��࠭��

@@exit:
	xor	cx, cx
	xor	dx, dx
	retf


	; ����饭�� startup-��楤���
@@vererrmsg:
	db	'Need desired DOS version as a parameter',13,10,'$'


startup		endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ��楤�� ���᫥��� ����� 䠩�� ��� ����� �� � ��������� .exe
;
; �� �室�:  DI - ����� 䠩�� � �����, AX - ����� ���������
;
; �� ��室�: DX - �᫮ ��࠭��, AX - ����� ��᫥���� ��࠭���
;
setlen		proc	near

	add	ax, di			; ����� 䠩�� ���� ����� ���������
	xor	dx, dx
	mov	dl, ah
	shr	dx, 1
	inc	dx
	and	ah, 1

	retn
setlen		endp


	; ������ ������ ��� ��楤��� compare
	;
	; ����� � ⠡��� ��⠢���� ����
	; ��ࢮ� ᫮�� � ��� - ����� �ࠢ��������� ���⪠,
	; ��஥ - ᬥ饭�� � ᫥���饬� �����.
	; �।���������� (� ��砥 ᮢ������� ����), �� ��᫥ �ࠢ�����
	; ��।���� ���⪠ ॣ�����-㪠��⥫� ᮤ�ঠ� ���� ᫥���饣�
	; ���� ��᫥ ��᫥����� �஢�७����
cmp_table:
	dw	offset cmp_1e - offset cmp_1b	; ����� ��ࢮ�� ���⪠
	dw	offset cmp_2b - offset cmp_1e	; ���饭�� ��ண� ���⪠

	dw	offset cmp_2e - offset cmp_2b	; ����� ��ண� ���⪠
	dw	offset cmp_3b - offset cmp_2e	; ���饭�� ���쥣� ���⪠

	dw	offset cmp_3e - offset cmp_3b
	dw	offset cmp_4b - offset cmp_3e

	dw	offset cmp_4e - offset cmp_4b
	dw	offset original_ss - offset cmp_4e	; ��᫥ �ࠢ�����
							; ��᫥����� ���⪠
							; DI �㤥� 㪠�뢠��
							; �� original_ss

	dw	0				; �ਧ��� ����砭�� �ࠢ�����

	; ��������� ��� .com-䠩��, �ॢ���騩 ��� � .exe
header:
		dw	'ZM'	; �������� .exe-䠩��
partpage:	dw	?	; ����� ��᫥���� ��࠭���
pagecount:	dw	?	; ��᫮ ��࠭��
numrelocs:	dw	0	; ��᫮ ��६�饭��
headersize:	dw	2	; ������ ��������� .exe (� ��ࠣ���)
minmem:		dw	1000h	; �������쭮 ����室��� ࠧ��� �����
maxmem:		dw	1000h	;
_ss:		dw	-10h	; ������� �⥪� == ᥣ����� PSP
_sp:		dw	-2	; �����⥫� �⥪�
checksum:	dw	0	; Dummy field ;)
_ip:		dw	100h	; start IP
_cs:		dw	-10h	; start CS
reltable:	dw	0	; ������ ��६�饭�� (����� ;)
overlaynum:	dw	0	; �᭮���� �����


	; ���� startup-��楤��� ��� Universal Modifier
		dw	offset	startup

cseg	ends
end
