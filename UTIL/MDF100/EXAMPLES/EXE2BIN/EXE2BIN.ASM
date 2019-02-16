;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (C) Armourer (FIDOnet 2:461/29.444 aka 2:461/35.444)
; Преобразователь EXE -> BIN
; (Модуль exe2bin.mdf для Universal Modifier 1.00)
;
; Иллюстрирует широту возможностей Universal Modifier :) ,
; а также показывает, как корректно выйти в DOS в случае ошибки
;
cseg	segment
	assume	cs:cseg

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Startup-процедура
;
; Всю работу выполняет именно она, никакого основного кода нет,
; поэтому возвращаемые значения -- DI - новая длина файла (после отрезания
; заголовка), CX - 0, DX - неопределен ;)
;
start	proc	near
	push	es
	pop	ds

	xor	bx, bx			; Полезная константа ;)

	; Проверяем сигнатуру EXE-файла
	mov	dx, offset @@invalid_signature
	cmp	word ptr ds:[bx], 'ZM'
	jne	@@err_exit

	; Таблица перемещений должна быть пустой
	mov	dx, offset @@not_0_relocations
	cmp	word ptr ds:[6], bx
	jne	@@err_exit

	; Все условия выполнены - уменьшаем размер файла за счет заголовка
	mov	si, word ptr ds:[8]
	shl	si, 1
	shl	si, 1
	shl	si, 1
	shl	si, 1

	; Теперь в SI лежит длина заголовка в байтах -
	; а также адрес первого байта за заголовком
	mov	cx, di
	sub	cx, si
	xor	di, di
	cld
	rep	movsb

	; Все параметры на выходе уже установлены ;)

	; Возвращаемся в Universal Modifier
	retf

	; Вывод сообщения и выход в DOS (в случае ошибки)
@@err_exit:
	push	cs
	pop	ds
	mov	ah, 9
	int	21h

	; Убираем со стека смещение выхода
	pop	ax

	; Кладем туда адрес int 20h в PSP Universal Modifier
	push	bx

	; Выходим в DOS
	retf

@@invalid_signature:
	db	'This file hasn',39,'t a valid EXE signature (',39,'MZ',39,')'
	db	13,10,'$'

@@not_0_relocations:
	db	'The relocation table of this file is not empty.',13,10,'$'

start	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Адрес startup-процедуры для Universal Modifier
;
	dw	offset start
cseg	ends
end	start
