TITLE     EX_PROG - Пример программы
          PAGE      ,132
;---------------------------------------

_STACK    SEGMENT   PARA  STACK  'STACK'
          db   64   dup  ('TSN ')
_STACK    ENDS

_DSEG     SEGMENT   PARA  PUBLIC 'DATA'

;---------------------------------------
msg       db        '* TSN * Association on line ...$'
;---------------------------------------

_DSEG     ENDS

;---------------------------------------
SUBTTL    Основная программа
          PAGE
;---------------------------------------

_CSEG     SEGMENT   PARA  PUBLIC 'CODE'

TSN       PROC      FAR
          ASSUME    CS:_CSEG, DS:_DSEG, SS: _STACK
          PUSH      DS
          MOV       AX,0
          PUSH      AX

;---------------------------------------
          MOV       DX,  seg  msg
          MOV       ds,dx
          MOV       dx,  offset    msg
          MOV       ah,  9
          INT       21h
;---------------------------------------

          RET
TSN       ENDP

_CSEG     ENDS

          END       TSN
