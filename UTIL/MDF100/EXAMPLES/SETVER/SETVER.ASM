;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (C) Armourer (FIDOnet 2:461/29.444)
; Подстановка нужного номера версии DOS для "особо умных" программ
;
; Навешивается кусочек кода, перехватывающий int 21h/fn 30h и возвращающий
; нужное значение.
;
; При модификации .com-файлы приводятся к .exe-виду и дальше обрабатываются
; как .exe.
;
sizeofTSR	=	4	; Размер резидентной части SetVer в параграфах
				; (с учетом собственного блока MCB)
stacksize	=	9	; Размер стека (в словах), необходимый для
				; корректной работы инициализационной процедуры

;exehdr	struc		; Структура заголовка .exe-файла
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
; Навесной код для .exe-файла
;
; Состоит из трех частей:
; 1. Обработчик int 21h
;    Отслеживает запрос на получение номера версии DOS
; 2. Обработчик int 22h (terminate proc)
;    Восстанавливает оригинальный вектор int 21h (остальное сделает DOS ;)
; 3. Инициализационаая часть
;    Устанавливает части 1 и 2 и формирует рабочую среду для выполнения .exe
;
; Также содержит временный стек .exe-файла, которым пользуется 3 часть при
; начальной инициализации частей 1 и 2
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Обработчик int21
;
; Отслеживает функцию 30h и возвращает в AX нужный номер версии DOS
;
int21		proc	near

cmp_1b	=	$		; Первый участок неизменяющегося кода
				; (для проверки на повторное навешивание)

	cmp	ah, 30h		; Смотрим номер функции
	jne	@@exit

cmp_1e	=	$ + 2		; Здесь заканчивается первый участок

highnum	=	$ + 1		; Нужный номер версии при инициализации пишется
lownum	=	$ + 2		; непосредственно в код команды MOV
	mov	ax, 0		; Загружаем номер версии

cmp_2b	=	$

	xor	cx, cx		; Так надо
	xor	dx, dx
	iret			; Выходим из прерывания

@@exit:				; Уходим по цепочке обработчиков int 21h

cmp_2e	=	$ + 1

		db	0eah	; JMP far
old21_o:	dw	?
old21_s:	dw	?

int21		endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Terminate-процедура
; Получает управление при выходе из основной программы
;
; Восстанавливает вектор int 21h при выходе из основной программы
;
int22		proc	near

cmp_3b	=	$

	; Восстанавливаем прежний вектор int 21h
	push	word ptr cs:[old21_s]
	pop	ds
	push	word ptr cs:[old21_o]
	pop	dx
	mov	ax, 2521h
	int	21h

	; Уходим дальше по цепочке обработчиков
cmp_3e	=	$ + 1
		db	0eah
old22_o:	dw	?
old22_s:	dw	?

int22		endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Инициализационная часть
;
entry		proc	near

cmp_4b	=	$

	; Сохраняем рабочие регистры
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	es
	push	ds

	; Сохраняем адрес terminate-процедуры (ее вызовет DOS при завершении
	; программы)
	push	word ptr ds:[0ah]	; IP
	pop	word ptr cs:[old22_o]
	push	word ptr ds:[0ch]	; CS
	pop	word ptr cs:[old22_s]

	; Откусываем кусочек от своего MCB
	push	ds
	pop	ax
	dec	ax
	mov	ds, ax
	sub	word ptr ds:[3], sizeofTSR	; Уменьшаем размер текущего MCB
	add	ax, word ptr ds:[3]		; Вычисляем сегмент нашего MCB
	inc	ax
	mov	bl, 'M'				; Блок программы - не последний
	xchg	bl, byte ptr ds:[0]		; Наш блок будет иметь признак
						; блока программы
	mov	es, ax
	mov	byte ptr es:[0], bl
	push	word ptr ds:[1]			; Владелец этого MCB - основная
	pop	word ptr es:[1]			; программа
	mov	word ptr es:[3], sizeofTSR-1	; Размер блока

	; Переносим резидентную часть в новый блок
	inc	ax
	mov	es, ax		; В ES - сегмент резидентного кода
	push	cs
	pop	ds
	xor	si, si
	xor	di, di
	mov	cx, offset entry
	cld
	rep	movsb

	; Устанавливаем вектора
	; Устанавливаем вектор int 21h
	xor	ax, ax
	mov	ds, ax
	cli
	xchg	word ptr ds:[21h*4], ax		; Берем IP
	mov	word ptr es:[old21_o], ax
	mov	ax, es
	xchg	word ptr ds:[21h*4+2], ax	; Берем CS
	mov	word ptr es:[old21_s], ax
	sti

	; Устанавливаем адрес terminate-процедуры в PSP
	pop	ds			; Восстанавливавем сегмент PSP
	mov	word ptr ds:[0ah], offset int22		; IP
	mov	word ptr ds:[0ch], es			; CS

	; Настраиваем сегмент основной точки входа и основного стека 
	mov	ax, cs
	add	word ptr cs:original_cs, ax
	add	word ptr cs:original_ss, ax

	; Восстанавливаем рабочие регистры
	pop	es
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	; Восстанавливаем стек
	cli
	pop	ss
	mov	sp, word ptr cs:original_sp
	sti

	; Старт основного файла
	jmp	dword ptr cs:[original_ip]

cmp_4e	=	$

entry		endp

		; Прежние значения регистров
original_ip:	dw	?	; Отсюда JMP FAR возьмет стартовый IP
original_cs:	dw	0	; и CS
original_sp:	dw	?	; Отсюда MOV вытащит стартовый SP

		; Временный стек .exe-файла
		dw	stacksize dup(?)	; Собственно стек
original_ss:	dw	0	; Отсюда POP поднимет стартовый SS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Процедура инициализации стека так, как нужно для .com
;
; Это процедура первой получает управление при старте преобразованного файла
;
cominit		proc	near
	mov	word ptr ds:[0], bp		; Сохраняем BP по адресу
	mov	bp, sp				; команды int 20h в PSP
	mov	word ptr [bp], 0
	mov	bp, word ptr ds:[0]
	mov	word ptr ds:[0], 20cdh		; Восстанавливаем int 20h
	db	0e9h		; jmp 100h
jstart:	dw	-2
cominit		endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Обратное преобразование: из .exe в .com
;
exe2com		proc	near

	; Проверка заголовка
	add	word ptr minmem, sizeofTSR	; Коррекция эталонного поля
						; MinMem
	mov	si, offset maxmem
	mov	di, 0ch
	mov	cx, 4
	rep	cmpsw
	jne	not_our_com

	cmpsw					; IP пропускаем
	cmpsw
	jne	not_our_com

	; Проверка стартового кода
	mov	si, offset cominit		; Эталон
	mov	di, word ptr es:[14h]		; Адрес стартового кода
	sub	di, 0e0h			; в файле
	mov	cx, offset jstart - offset cominit
	rep	cmpsb
	jne	not_our_com

	; Отрезаем хвост (cominit) и голову (заголовок ;)
	push	es
	pop	ax
	add	ax, 2
	mov	es, ax				; Отрезали заголовок

	; Отрезали хвост
	sub	di, 20h + offset jstart - offset cominit

	pop	ax
	jmp	exit

exe2com		endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Удаление кода setver из .exe-файла
;
remove		proc	near
	pop	si			; Восстанавливаем стек

	; Сейчас DI указывает на original_ss
	mov	ax, word ptr es:[di]
	add	word ptr es:[0eh], ax
	sub	di, offset original_ss - original_sp

	; Сейчас DI указывает на original_sp
	push	word ptr es:[di]
	pop	word ptr es:[10h]
	dec	di
	dec	di

	; Сейчас DI указывает на original_cs
	mov	ax, word ptr es:[di]
	add	word ptr es:[16h], ax
	dec	di
	dec	di

	; Сейчас DI указывает на original_ip
	push	word ptr es:[di]
	pop	word ptr es:[14h]

	; Восстанавливаем (насколько это возможно ;) длину исходного файла
	sub	di, offset original_ip

	; Корректируем длину в заголовке
	xor	ax, ax
	call	setlen
	mov	word ptr es:[4], dx	; Число 512-байтных страниц
	mov	word ptr es:[2], ax	; Число байт на последней странице

	push	di			; Сохраняем длину файла

	; Проверяем - не бывший ли это .com ?
	cmp	word ptr es:[6], 0	; Число входов в таблице перемещений
	je	exe2com

not_our_com:
	pop	di	; Восстанавливаем длину (в процессе проверки в exe2com
			; может выясниться, что это - не наш .com, и мы
			; не можем преобразовать его, а DI будет уже испорчен)
exit:
	; CX и DX обнуляем
	xor	cx, cx
	xor	dx, dx

	retf
remove		endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Startup-процедура
;
; Получает на входе:
;	ES:0	- входной файл
;	DI	- длина входного файла
;	SS:BP	- командная строка
;
; Отдает на выходе:
;	DI	- длина данных с навесом
;	DX	- 0
;	CX	- 0
;
startup		proc	near

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Проверяем, на какой файл нас напустили
	; Если он уже был обработан setver'ом - снимаем код setver'а
	;
	; Проверяем тип файла
	cmp	word ptr es:[0], 'ZM'
	jne	setver			; .com-файлы отпадают :)

	push	di			; Сохраняем длину файла

	; Сравниваем стартовый код с тем, что имеем
	; Получаем адрес старта
	mov	di, word ptr es:[16h]	; Стартовый адрес .exe (CS)
	add	di, word ptr es:[8]	; Размер заголовка (в параграфах)
	mov	cl, 4
	shl	di, cl			; В DI - начало участка для сравнения
	xor	si, si			; Смещение cmp_1b в сегменте кода .mdf
	mov	bx, offset cmp_table	; BX указывает на таблицу данных

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Процедура сравнения кода setver со стартовым кодом в .exe-файле
;
; Для сравнения используются данные о неизменных (не содержащих данных)
; участках кода. Эти данные размещены в таблице cmp_table, на которую
; указывает BX.
; Сравнение начинается, как обычно, с позиции DS:SI и ES:DI
;
compare		proc	near

	mov	cx, word ptr [bx]	; Длина участка
	inc	bx
	inc	bx
	or	cx, cx			; Признак окончания таблицы
	je	remove			; Это означает наличие точной копии
					; стартового кода setver в .exe-файле
	cld
	rep	cmpsb			; Сравниваем

	add	si, word ptr [bx]	; Переходим к началу участка
	add	di, word ptr [bx]
	inc	bx
	inc	bx

	or	cx, cx			; Совпадает ли только что проверенное ?
	je	compare			; Совпадает - продолжаем сравнение

compare		endp

	pop	di			; Восстанавливаем длину файла

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Собственно установка индивидуального setver'а
	;
setver:
	mov	si, sp			; Для корректного возврата

	; Читаем из командной строки номер версии
	mov	ax, word ptr [bp]
	cmp	ah, '.'			; Это номер версии ?
	je	@@checkhigh		; Да - проверяем его

	; Все остальное - от лукавого ;)
@@vererr:
	; Номер версии DOS указан неправильно
	; Выводим соотв. сообщение
	mov	dx, offset @@vererrmsg

todos:
	; Вывод сообщения и вылет в DOS
	mov	ah, 9
	int	21h

	; Вылетаем в DOS
	mov	sp, si			; Кладем в стек адрес int 20h
	pop	ax			; в PSP Universal Modifier'а
	xor	ax, ax
	push	ax
	retf				; Собственно выход в DOS

check_ax:
	; Проверка - в AX должно быть неупакованное ASCII-число от 0 до 99
	; Заодно число переводится в двоичную форму
	call	check_al
	xchg	al, ah

check_al:
	; Проверка - в AL должна быть ASCII-цифра от 0 до 9
	; Заодно цифра переводится в двоичную форму
	sub	al, '0'
	jc	@@vererr	; Слишком мало
	cmp	al, 10
	jnc	@@vererr	; Слишком много
	retn

@@checkhigh:
	; Проверяем и сохраняем старший номер версии (1 цифра)
	call	check_al		; Проверяем корректность старшей цифры
	mov	byte ptr highnum, al	; Сохраняем старший номер версии

	; Проверяем и сохраняем младший номер версии (2 цифры)
	mov	ax, word ptr [bp+2]	; Берем следующие 2 цифры
	call	check_ax		; Проверяем корректность
	aad				; Получаем младший номер версии
	mov	byte ptr lownum, al	; Сохраняем младший номер версии

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Вешаем на файл код setver
	;
	; Проверяем тип файла
	cmp	word ptr es:[0], 'ZM'
	je	@@exe

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Превращаем .com в .exe путем приписывания заголовка
	;
	; Устанавливаем в заголовке стартовый адрес на cominit
	add	word ptr _ip, di

	; Дописываем cominit
	mov	si, offset cominit
	mov	cx, offset jstart - offset cominit
	cld
	rep	movsb
	lodsw			; Берем смещение из jmp near
	sub	ax, di		; Корректируем его
	stosw

	; Приводим в соответствие длину в заголовке
	mov	ax, 20h			; Длина заголовка для бывшего .com
	call	setlen
	mov	word ptr pagecount, dx	; В DX - число страниц
	mov	word ptr partpage, ax	; а в AX - длина последней страницы,

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

@@exe:
	; Сейчас у нас по адресу ES:0 лежит .exe-файл
	; и в DI лежит его длина

	;;;;;;;;;;;;;;;;;;;;;;
	; Навешиваем свой код

	; Выравниваем длину файла на границу параграфа
	add	di, 15
	and	di, 0fff0h

	; Сохраняем старую точку входа и стек
	mov	ax, di				; Новый CS
	shr	ax, 1
	shr	ax, 1
	shr	ax, 1
	shr	ax, 1
	sub	ax, word ptr es:[8]		; Вычитаем размер заголовка
	sub	word ptr original_cs, ax	; Так легче будет скорректи-
						; ровать CS при старте
	sub	word ptr original_ss, ax	; То же для SS

	push	ax				; CS == SS
	xchg	ax, word ptr es:[16h]		; Старый CS берем в AX
	add	word ptr original_cs, ax	; Сохраняем старый CS
	pop	ax
	xchg	ax, word ptr es:[0eh]		; Берем старый SS в AX
	add	word ptr original_ss, ax	; Сохраняем старый SS

	mov	ax, offset entry		; Новый IP
	xchg	ax, word ptr es:[14h]		; Старый IP берем в AX
	mov	word ptr original_ip, ax	; Сохраняем старый IP

	mov	ax, offset original_ss		; Новый SP
	xchg	ax, word ptr es:[10h]		; Старый SP берем в AX
	mov	word ptr original_sp, ax	; Сохраняем старый SP

	; Увеличиваем поле minmem - чтобы иметь уверенность в наличии
	; необходимого объема памяти
	add	word ptr es:[0ah], sizeofTSR
	jnc	@@minmem_correct
	sub	word ptr es:[0ah], sizeofTSR

@@minmem_correct:
	; Дописываем в хвост свой код
	xor	si, si
	mov	cx, offset cominit
	rep	movsb

	; Корректируем длину файла
	xor	ax, ax			; Длина заголовка уже учтена в DI
	call	setlen
	mov	word ptr es:[4], dx	; Число 512-байтных страниц
	mov	word ptr es:[2], ax	; Число байт на последней странице

@@exit:
	xor	cx, cx
	xor	dx, dx
	retf


	; Сообщения startup-процедуры
@@vererrmsg:
	db	'Need desired DOS version as a parameter',13,10,'$'


startup		endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Процедура вычисления длины файла для записи ее в заголовок .exe
;
; На входе:  DI - длина файла в байтах, AX - длина заголовка
;
; На выходе: DX - число страниц, AX - длина последней страницы
;
setlen		proc	near

	add	ax, di			; Длина файла плюс длина заголовка
	xor	dx, dx
	mov	dl, ah
	shr	dx, 1
	inc	dx
	and	ah, 1

	retn
setlen		endp


	; Таблица данных для процедуры compare
	;
	; Слова в таблице составляют пары
	; Первое слово в паре - длина сравниваемого участка,
	; второе - смещение к следующему участку.
	; Предполагается (в случае совпадения кода), что после сравнения
	; очередного участка регистры-указатели содержат адрес следующего
	; байта после последнего проверенного
cmp_table:
	dw	offset cmp_1e - offset cmp_1b	; Длина первого участка
	dw	offset cmp_2b - offset cmp_1e	; Смещение второго участка

	dw	offset cmp_2e - offset cmp_2b	; Длина второго участка
	dw	offset cmp_3b - offset cmp_2e	; Смещение третьего участка

	dw	offset cmp_3e - offset cmp_3b
	dw	offset cmp_4b - offset cmp_3e

	dw	offset cmp_4e - offset cmp_4b
	dw	offset original_ss - offset cmp_4e	; После сравнения
							; последнего участка
							; DI будет указывать
							; на original_ss

	dw	0				; Признак окончания сравнения

	; Заголовок для .com-файла, превращающий его в .exe
header:
		dw	'ZM'	; Сигнатура .exe-файла
partpage:	dw	?	; Длина последней страницы
pagecount:	dw	?	; Число страниц
numrelocs:	dw	0	; Число перемещений
headersize:	dw	2	; Размер заголовка .exe (в параграфах)
minmem:		dw	1000h	; Минимально необходимый размер памяти
maxmem:		dw	1000h	;
_ss:		dw	-10h	; Сегмент стека == сегменту PSP
_sp:		dw	-2	; Указатель стека
checksum:	dw	0	; Dummy field ;)
_ip:		dw	100h	; start IP
_cs:		dw	-10h	; start CS
reltable:	dw	0	; Таблица перемещений (пустая ;)
overlaynum:	dw	0	; Основной модуль


	; Адрес startup-процедуры для Universal Modifier
		dw	offset	startup

cseg	ends
end
