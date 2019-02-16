;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (C) Armourer (2:461/29.444 aka 2:461/35.444)
; Показ пути запуска из environment
;
cseg	segment
	assume	cs:cseg
	org	100h
start	proc	near
	; Это хохма - на самом деле после отработки распаковщика
	; управление будет передано на begin
	; Выходим
@@exit:
	retn

begin:
	; Устанавливаем ES:DI на environment
	push	word ptr ds:[2ch]
	pop	es

	; Ищем признак конца environment - db 1
	xor	di, di
	mov	al, 1
	mov	cx, 7fffh	; Если вдруг не найдем
	cld
	repne	scasb

	; Это если все-таки не нашли
	or	cx, cx
	je	@@exit

	; Нам нужен DS:SI
	push	es
	pop	ds
	xchg	si, di

	; Пропускаем 1 байт - db 0
	lodsb

	; Выводим строку
@@next:	
	lodsb
	int	29h
	or	al, al
	jne	@@next

	; Выход в случае успеха поисков
	retn
	
start	endp
	; Здесь адрес точки старта
	; для шифровщика Simplest / Universal Protector 1.00
	dw	offset begin

cseg	ends
end	start
