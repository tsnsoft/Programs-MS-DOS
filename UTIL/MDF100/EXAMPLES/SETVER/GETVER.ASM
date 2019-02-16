;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (C) Armourer (FIDOnet 2:461/29.444)
; Выдача номера версии DOS
;
cseg	segment
	assume cs:cseg
	org	100h

start	proc	near

	mov	ah, 30h		; Получаем номер версии DOS
	int	21h

	mov	dl, al		; Преобразуем его в читабельный вид
	add	dl, '0'
	mov	al, ah
	aam
	add	ax, '00'
	push	ax

	mov	ah, 2		; Выводим соответствующее число
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
