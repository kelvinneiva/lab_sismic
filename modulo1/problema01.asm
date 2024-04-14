;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

;Escrever sub-rotina que representa com algarismos romanos um número entre 1 e 3999.

NUM			.equ		2005   				;Indicar número a ser convertido

;------------------------------------------------------------------------------
;entra com um numero de 0 ate 3999
;retorna o valor em algarismos romanos

 			MOV 		#NUM,R5 			;R5 = número a ser convertido
 			MOV 		#RESP,R6 			;R6 = ponteiro para escrever a resposta
 			CALL 		#ALG_ROM 			;chamar subrotina que converte o numeor para algarismos romanos
 			JMP 		$ 					;travar execução
 			NOP 							;exigido pelo montador

;------------------------------------------------------------------------------
;Sub-rotina ALG_ROM (Algarismos Romanos) - converte o
;------------------------------------------------------------------------------

ALG_ROM:	MOV			R5,R7				;copia o valor do numero a ser convertido para o dividendo
			MOV			#1000,R8			;inicia o divisor = 1000
			CLR			R9					;inicia quociente em 0
			CLR			R10					;inicia resto em 0
			CALL		#MILHAR_LOOP		;chamar a rotina que encontrara as unidades de milhar, centena, dezena e unidades do numero
 			RET

;------------------------------------------------------------------------------
;regiao de codigo destinada a encontrar as unidades de milhar, centena, dezena e unidades do numero a ser convertido
;------------------------------------------------------------------------------

MILHAR_LOOP:CMP			#1000,R7			;R7 < 1000 ?
			JLO			CENT				;ir se divisor > dividendo
			SUB			#1000,R7			;diminuir unidade de milhar do dividendo
			MOV			R7,R10				;resto = R7 - 1000
			INC			R9					;incrementa o quociente
			MOV.B		R9,&Q1000			;guarda as unidades de milhar
			JMP			MILHAR_LOOP			;voltar a divisao

CENT:		CLR			R9					;limpar o quociente
			CMP			#0,R10				;R10 == 0 ?
			JEQ			CENT_LOOP			;com resto == 0, entao nao substituir em R7
			MOV			R10,R7				;atualizar o dividendo sem as unidades de milhar do numero original
			MOV			#100,R8				;guarda o novo divisor
CENT_LOOP:	CMP			#100,R7				;R7 < 100 ?
			JLO			DEZEN				;ir se divisor > dividendo
			SUB			#100,R7				;diminuir a unidade de centena do dividendo
			MOV			R7,R10				;resto = R7 - 100
			INC			R9					;incrementa o quociente
			MOV.B		R9,&Q100			;guarda as centenas
			JMP			CENT_LOOP			;voltar a divisao

DEZEN:		CLR			R9					;limpa o quociente
			CMP			#0,R10				;R10 == 0 ?
			JEQ			DEZEN_LOOP			;com resto == 0, entao nao substituir em R7
			MOV			R10,R7				;atualizar o dividendo sem as unidades de milhar e centena do numero original
			MOV			#10,R8				;guarda o novo divisor
DEZEN_LOOP:	CMP			#10,R7				;R7 < 10 ?
			JLO			UNID				;ir se divisor > dividendo
			SUB			#10,R7				;diminuir a unidade de centena do dividendo
			MOV			R7,R10				;resto = R7 - 100
			INC			R9					;incrementa o quociente
			MOV.B		R9,&Q10				;guarda as dezenas
			JMP			DEZEN_LOOP			;voltar a divisao

UNID:		CMP			#0,R7				;resto == 0 ?
			JEQ			REST0				;com resto == 0 ir guardar 0 em Q1
			MOV.B		R7,&Q1				;guarda as unidades nao nula
			JMP			I_RM				;ir converter para algarismos romanos
REST0:		MOV.B		#0,&Q1				;guardar a unidade nula
			JMP			I_RM				;ir converter para algarismos romanos

;Regiao de conversao das unidades de milhar em romanos

I_RM:		MOV.B		Q1000,R11			;inicia o contador (I_RM := Inicio da ROM_MIL)
ROM_MIL:	CMP			#0,R11				;R11 == 0 ?
			JEQ			I_RC				;0 unidades de milhar, entao ir para as centenas
			MOV.B		ROM_M,0(R6)			;guarda um M onde o R6 aponta no vetor RESP
			DEC			R11					;contador - 1
			INC			R6					;proximo elemento do vetor
			JMP			ROM_MIL				;ir verificar se contador == 0

;Regiao de conversao das centenas em romanos

I_RC:		MOV.B		Q100,R11			;inicia o contador (I_RC := Inicio da ROM_CEN)
ROM_CEN:	CMP			#0,R11				;contador == 0 ?
			JEQ			I_RD				;0 centenas, entao ir para as dezenas
			CMP.B		#4,Q100				;Q100 < 4 ?
			JEQ			C4					;ir substituir Q100 por CD
			JHS			C_BT_4				;ir verificar se Q100 == 9
			MOV.B		ROM_C,0(R6)			;guarda um C onde o R6 aponta no vetor RESP
			DEC			R11					;contador - 1
			INC			R6					;proximo elemento do vetor
			JMP			ROM_CEN				;ir verificar se contador == 0

			;caso centena == 4

C4:			MOV.B		ROM_C,0(R6)			;guarda um C onde o R6 aponta no vetor RESP (C4 := Centena e 4)
			INC			R6					;proximo elemento do vetor
			MOV.B		ROM_D,0(R6)			;guarda um D onde o R6 aponta no vetor RESP
			INC			R6					;proximo elemento do vetor
			JMP			I_RD				;0 centenas, entao ir para as dezenas

			;caso 9 > centena > 4

C_BT_4:		MOV.B		Q100,R15
			CMP.B		#9,Q100				;Q100 == 900 ? (C_BT_4 := Centena e maior do que 4)
			JEQ			C9					;Q100 == 900
			MOV.B		ROM_D,0(R6)			;centena a partir de 5 até 8, colocar o D de 500 na resposta
			INC			R6					;proxima posicao do vetor
			MOV.B		Q100,R12			;inicia o contador02
			SUB			#5,R12				;guarda as centenas restantes // contador02 de C a serem concatenados na resposta
CONCAT_C:	CMP			#0,R12				;0 centenas restantes?
			JEQ			I_RD				;como R12 == 0, entao ir para as dezenas
			MOV.B		ROM_C,0(R6)			;guarda um C onde o R6 aponta no vetor RESP
			DEC			R12					;contador02 - 1
			INC			R6					;proximo elemento do vetor
			JMP			CONCAT_C			;ir verificar se contador02 == 0

			;caso centena == 9

C9:			MOV.B		ROM_C,0(R6)			;guarda um C onde o R6 aponta no vetor RESP (C9 := Centena e 9)
			INC			R6					;proximo elemento do vetor
			MOV.B		ROM_M,0(R6)			;guarda um M onde o R6 aponta no vetor RESP
			INC			R6					;proximo elemento do vetor
			JMP			I_RD				;0 centenas, entao ir para as dezenas

;Regiao de conversao das dezenas em romanos

I_RD:		MOV.B		Q10,R11				;inicia o contador (I_RD := Inicio da ROM_DEZ)
ROM_DEZ:	CMP			#0,R11				;contador == 0 ?
			JEQ			I_RU				;0 dezenas, entao ir para as unidades
			CMP.B		#4,Q10				;Q10 < 4 ?
			JEQ			D4					;ir substituir Q10 por XL
			JHS			D_BT_4				;ir verificar se Q10 == 9
			MOV.B		ROM_X,0(R6)			;guarda um X onde o R6 aponta no vetor RESP
			DEC			R11					;contador - 1
			INC			R6					;proximo elemento do vetor
			JMP			ROM_DEZ				;ir verificar se contador == 0

			;caso dezena == 4

D4:			MOV.B		ROM_X,0(R6)			;guarda um X onde o R6 aponta no vetor RESP (D4 := Dezena e 4)
			INC			R6					;proximo elemento do vetor
			MOV.B		ROM_L,0(R6)			;guarda um L onde o R6 aponta no vetor RESP
			INC			R6					;proximo elemento do vetor
			JMP			I_RU				;0 dezenas, entao ir para as unidades

			;caso 9 > dezena > 4

D_BT_4:		CMP.B		#9,Q10				;Q100 == 900 ? (C_BT_4 := Centena e maior do que 4)
			JEQ			D9					;Q100 == 900
			MOV.B		ROM_L,0(R6)			;dezena a partir de 5 até 8, colocar o L de 50 na resposta
			INC			R6					;proxima posicao do vetor
			MOV.B		Q10,R12				;inicia o contador02
			SUB			#5,R12				;guarda as dezenas restantes // contador02 de X a serem concatenados na resposta
CONCAT_X:	CMP			#0,R12				;0 dezenas restantes?
			JEQ			I_RU				;com R12 == 0, entao ir para as unidades
			MOV.B		ROM_X,0(R6)			;guarda um X onde o R6 aponta no vetor RESP
			DEC			R12					;contador02 - 1
			INC			R6					;proximo elemento do vetor
			JMP			CONCAT_X			;ir verificar se contador02 == 0

			;caso dezena == 9

D9:			MOV.B		ROM_X,0(R6)			;guarda um X onde o R6 aponta no vetor RESP (D9 := Dezena e 9)
			INC			R6					;proximo elemento do vetor
			MOV.B		ROM_C,0(R6)			;guarda um C onde o R6 aponta no vetor RESP
			INC			R6					;proximo elemento do vetor
			JMP			I_RU				;0 dezenas, entao ir para as unidades

;Regiao de conversao das unidades em romanos

I_RU:		MOV.B		Q1,R11				;inicia o contador (I_RU:= Inicio da ROM_UNI)
ROM_UNI:	CMP			#0,R11				;R11 == 0 ?
			JEQ			FIM					;resposta completa
			CMP.B		#4,Q1				;Q1 < 4 ?
			JEQ			U4					;ir substituir Q1 por IV
			JHS			U_BT_4				;ir verificar se Q1 == 9
			MOV.B		ROM_I,0(R6)			;guarda um I onde o R6 aponta no vetor RESP
			DEC			R11					;contador - 1
			INC			R6					;proximo elemento do vetor
			JMP			ROM_UNI				;ir verificar se contador == 0
			NOP

			;caso unidade == 4

U4:			MOV.B		ROM_I,0(R6)			;guarda um I onde o R6 aponta no vetor RESP (U4 := Unidade e 4)
			INC			R6					;proximo elemento do vetor
			MOV.B		ROM_V,0(R6)			;guarda um V onde o R6 aponta no vetor RESP
			INC			R6					;proximo elemento do vetor
			JMP			FIM					;0 unidades, entao encerrar o codigo

			;caso 9 > unidade > 4

U_BT_4:		CMP.B		#9,Q1				;Q100 == 900 ? (C_BT_4 := Centena e maior do que 4)
			JEQ			U9					;Q100 == 900
			MOV.B		ROM_V,0(R6)			;unidades a partir de 5 até 8, colocar o V de 5 na resposta
			INC			R6					;proxima posicao do vetor
			MOV.B		Q1,R12				;inicia o contador02
			SUB			#5,R12				;guarda as unidades restantes // contador02 de I a serem concatenados na resposta
CONCAT_I:	CMP			#0,R12				;0 unidades restantes?
			JEQ			FIM					;como R12 == 0, entao encerrar o codigo
			MOV.B		ROM_I,0(R6)			;guarda um I onde o R6 aponta no vetor RESP
			DEC			R12					;contador02 - 1
			INC			R6					;proximo elemento do vetor
			JMP			CONCAT_I			;ir verificar se contador02 == 0

			;caso unidade == 9

U9:			MOV.B		ROM_I,0(R6)			;guarda um I onde o R6 aponta no vetor RESP (U9 := Unidade e 9)
			INC			R6					;proximo elemento do vetor
			MOV.B		ROM_X,0(R6)			;guarda um X onde o R6 aponta no vetor RESP
			INC			R6					;proximo elemento do vetor
			JMP			FIM					;0 unidades, entao encerrar o codigo

;------------------------------------------------------------------------------
;permite encerrar o programa

FIM:		MOV.B		#0,0(R6)			;finzalizar com zeros pedido pela questao
			RET								;fim do programa

;------------------------------------------------------------------------------

 			.data
; Local para armazenar a resposta (RESP = 0x2400)
RESP: 		.byte		"RRRRRRRRRRRRRRRRRR",0

Q1000:		.byte		0x00				;armazena a unidade de milhar do numero de entrada
Q100:		.byte		0x00				;armazena a centena do numero de entrada
Q10:		.byte		0x00				;armazena a dezena do numero de entrada
Q1:			.byte		0x00				;armazena as unidades do numero de entrada

;Algarismos Romanos definidos
ROM_I:		.byte		"I"
ROM_V:		.byte		"V"
ROM_X:		.byte		"X"

ROM_L:		.byte		"L"
ROM_C:		.byte		"C"

ROM_D:		.byte		"D"
ROM_M:		.byte		"M"

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
