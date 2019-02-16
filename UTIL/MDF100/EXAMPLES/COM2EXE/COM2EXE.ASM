;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (C) Armourer (FIDOnet 2:461/29.444)
; Преобразование .com-файлов в .exe и наоборот
; (Модуль com2exe.mdf для Universal Modifier 1.00)
;
cseg	segment
	assume	cs:cseg

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Процедура инициализации стека так, как нужно для .com
;
; Это процедура первой получает управление при старте преобразованного файла
;
cominit		proc	near

	mov	word ptr ds:[0], bp	; Старое значение BP сохраняем в PSP
	mov	bp, sp			; на месте команды int 20h
	mov	word ptr [bp], 0
	mov	bp, word ptr ds:[0]
	mov	word ptr ds:[0], 20cdh

	db	0e9h		; jmp 100h
jstart:	dw	-2
cominit		endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Startup-процедура
;
; Получает на входе:
;	ES:0	- входной файл
;	DI	- длина входного файла
;	SS:BP	- командная строка
;
; Отдает на выходе:
;	DI	- длина данных
;	DX	- 0
;	CX	- 0
;
; Если на входе присутствует файл типа .com, он преобразуется в .exe
;
; Если на входе присутствует .exe-файл, выполняется проверка на совпадение
; стартового кода с тем, что делает com2exe с файлами типа .com
; Если все совпадает, файл преобразуется обратно в .com
;
startup		proc	near

	cmp	word ptr es:[0], 'ZM'
	je	@@exe

	; Проверяем - не слишком ли длинный файл ?
	mov	dx, offset toolong
	cmp	di, -(offset startup)
	jnc	@@2dos

	; Превращаем .com в .exe путем приписывания заголовка
	; Устанавливаем в заголовке стартовый адрес на cominit
	add	word ptr _ip, di

	; Дописываем cominit
	xor	si, si
	mov	cx, offset jstart
	cld
	rep	movsb
	lodsw			; Берем смещение из jmp near
	sub	ax, di		; Корректируем его
	stosw

	; Приводим в соответствие длину в заголовке
	mov	ax, di			; Длина файла...
	add	ax, 20h			; ...плюс длина заголовка
	call	calc_len		; Устанавливаем

	; Переносим код повыше
	mov	si, di
	add	di, 20h - 1		; Длина фиктивного .exe-заголовка
	push	di
	std
@@1:
	dec	si
	mov	al, byte ptr es:[si]
	stosb
	jne	@@1

	; Вписываем заголовок
	mov	di, si
	mov	si, offset header
	mov	cx, 1ch			; Длина фиктивного .exe-заголовка
	cld
	rep	movsb

	pop	di		; Восстанавливаем длину файла
	inc	di

@@exit:
	xor	cx, cx
	xor	dx, dx
	retf

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Обратное преобразование .exe в .com
@@exe:
	; Прежде всего проверяем, было ли это когда-то .com,
	; преобразованным затем нами в .exe

	mov	ax, di			; Сразу берем длину файла

	; Проверка кода инициализации
	std
	sub	di, 2
	sub	word ptr jstart, di	; Коректируем адрес перехода
	add	word ptr jstart, 20h	; в эталоне
	mov	si, offset jstart
	mov	cx, si
	rep	cmpsb
	je	@@pass1

	; Если обратное преобразование невозможно, выводим сообщение и
	; вываливаемся в DOS
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
	; Стартовый код, вроде, в порядке.
	; Проверяем заголовок

	; Корректируем соответствующие поля в эталонном заголовке
	add	word ptr _ip, di	; стартовый IP
	sub	word ptr _ip, 20h

	call	calc_len		; Длина файла

	; Сравниваем то, что имеем в начале тестового файла, с эталоном
	mov	bp, di			; Сохраняем длину файла
	xor	di, di
	mov	si, offset header
	mov	cx, 1ch
	cld
	rep	cmpsb
	jnz	@@imposs

	; Итак, пришло время конвертировать.
	; Перетягиваем файл на место заголовка
	add	di, 4			; 4 байта после заголовка - от балды
	sub	bp, di			; Длина файла после удаления заголовка
	mov	si, di
	xor	di, di
	mov	cx, bp
	push	es
	pop	ds
	rep	movsb

	; Выходим
	mov	di, bp
	jmp	@@exit
	
startup		endp


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Установка соответствующих полей в эталонном заголовке .exe-файла
	; На входе в AX должна лежать длина файла в байтах
	;
calc_len	proc	near

	xor	dx, dx
	mov	dl, ah
	shr	dx, 1
	inc	dx
	and	ah, 1
	mov	word ptr pagecount, dx	; В DX - число страниц
	mov	word ptr partpage, ax	; а в AX - длина последней страницы,

	retn
calc_len	endp


	; Заголовок для .com-файла, превращающий его в .exe
header:
		dw	'ZM'	; Сигнатура .exe-файла
partpage:	dw	?	; Длина последней страницы
pagecount:	dw	?	; Число страниц
numrelocs:	dw	0	; Число перемещений
headersize:	dw	2	; Размер заголовка .exe (в параграфах)
minmem:		dw	1000h	; Минимально необходимый объем памяти
maxmem:		dw	1000h	; Максимально необходимый объем памяти
_ss:		dw	-10h	; Сегмент стека == сегменту PSP
_sp:		dw	-2	; Указатель стека
checksum:	dw	0	; Dummy field ;)
_ip:		dw	100h	; start IP
_cs:		dw	-10h	; start CS
reltable:	dw	0	; Таблица перемещений (пустая ;)
overlaynum:	dw	0	; Основной модуль


	; Сообщение о невозможности сконвертировать .exe в .com
imp2conv:
	db	'Sorry, but I can',39,'t to convert this file back to .com'
	db	13,10,'$'


	; Сообщение о невозможности сконвертировать длинный файл
toolong:
	db	'Sorry, but this file too long to convert to .exe'
	db	13,10,'$'

	; Адрес startup-процедуры для Universal Modifier
		dw	offset	startup

cseg	ends
end
