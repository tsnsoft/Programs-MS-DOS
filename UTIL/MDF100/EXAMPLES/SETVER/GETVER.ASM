;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (C) Armourer (FIDOnet 2:461/29.444)
; �뤠� ����� ���ᨨ DOS
;
cseg	segment
	assume cs:cseg
	org	100h

start	proc	near

	mov	ah, 30h		; ����砥� ����� ���ᨨ DOS
	int	21h

	mov	dl, al		; �८�ࠧ㥬 ��� � �⠡���� ���
	add	dl, '0'
	mov	al, ah
	aam
	add	ax, '00'
	push	ax

	mov	ah, 2		; �뢮��� ᮮ⢥�����饥 �᫮
	int	21h

	mov	dl, '.'
	int	21h

	pop	dx
	xchg	dl, dh
	int	21h

	mov	dl, dh
	int	21h

	retn

start	endp
cseg	ends
end	start
