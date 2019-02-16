;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (C) Armourer (FIDOnet 2:461/29.444)
; Показ содержимого регистров при старте .com программы
;
cseg	segment
	assume	cs:cseg
	org	100h

; Макрос для вывода содержимого регистра
show	macro	reg
	ifdif <reg>,<ax>
		mov	ax, reg
	endif
	call	show_ax
endm

; Точка входа
start		proc	near

	; Последовательно выводим содержимое регистров, указанных в списке
	irp	reg, <ax,si,cs,bx,di,ds,cx,bp,es,dx,sp,ss>
		show	reg
	endm

	; Вывод результата
	mov	dx, offset res
	mov	ah, 9
	int	21h
	retn

start		endp

; Процедура вывода содержимого AX
show_ax		proc	near

	xchg	di, word ptr [curptr]		; Берем указатель в DI

	push	ax
	call	out_al		; Выводим первые 2 цифры
	pop	ax
	mov	al, ah		; Выводим вторые 2 цифры
	call	out_al

	add	di, 17		; Продвигаемся к следующему регистру

	xchg	di, word ptr [curptr]		; Восстанавливаем DI
	retn

	; Указатель на последнюю цифру поля вывода для текущего регистра
curptr:		dw	offset regs_field

show_ax		endp


	; Вывод байта из AL в шестнадцатиричном виде
out_al		proc	near
	db	0d4h, 10h	; AAM с модификатором - деление на 16
	call	out_16		; Выводим младшую цифру
	mov	al, ah		; Теперь - старшую


		; Вывод шестнадцатиричной цифры из AL
	out_16		proc	near
		cmp	al, 0ah		; Если меньше, то все ok
		jc	@@ok
		add	al, 'A'-'0' - 0ah	; Добавляем разницу в цифрах
	@@ok:	add	byte ptr [di], al	; Пишем цифру на место
		dec	di			; и переходим к следующей
		retn
	out_16		endp


out_al		endp


	; Заставка и табличка с результатом работы
res:
       db 13,10,'╒════════════════════════════════════════════════════'
       db 13,10,'│ (C)  ANS  (Armourer)	    ShowRegs	 FreeWare'
       db 13,10,'│ FIDOnet 2:461/29.444	     V 1.00	SourceWare'
       db 13,10,'│'
       db 13,10,'│	  Proc Regs at Start of .com in DOS'
       db 13,10,'│	╒════════════════════════════════════'


	; Начало форматированного поля со значениями регистров
	; Заполняется при работе show_ax

       db 13,10,'│	│ AX:000'

regs_field:
       db		       '0      SI:0000      CS:0000'
       db 13,10,'│	│ BX:0000      DI:0000      DS:0000'
       db 13,10,'│	│ CX:0000      BP:0000      ES:0000'
       db 13,10,'│	│ DX:0000      SP:0000      SS:0000'


       db 13,10,'│	│'
       db 13,10,'│'
       db 13,10,'│'
db 13,10,10
db '$'

cseg	ends
end	start
