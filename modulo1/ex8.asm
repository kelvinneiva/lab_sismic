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

;----------------------------------------------------------------------------
; Segmento de dados inicializados (0x2400)
;----------------------------------------------------------------------------

			.data
SEQ_FIB:	.word 	0, 1

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
			.text

EXP8:		MOV		#SEQ_FIB,R5				;armazena os dois ultimos elementos da sequencia de Fibonacci
			CALL	#FIB					;chama a funcao Fibonacci que armazena o maior numero da sequencia de Fibonacci que se pode representar com 16 bits em R10
			JMP		$						;trap que prende o laco de execucao do codigo
			NOP								;ignorar

FIB:		MOV		@R5,R6					;guarda o primeiro termo em r6
			INCD	R5						;move o ponteiro
			ADD		@R5,R6					;soma o primeiro ao segundo termo
			JNC		LB1						;verifica se cabe em uma palavra
			MOV		@R5,R10					;houve carry na soma; portanto, armazene o ultimo valor que cabe em uma palavra de 16 bits
			RET								;ir para trap em EXP08

LB1:		INCD	R5						;prox posicao de memoria (de 16 em 16 bits de memoria)
			MOV		R6,0(R5)				;lb1 faz os ponteiros andarem na sequencia, por consequencia, "esquecerem" os termos anteriores
			DECD	R5						;
			JMP		FIB						;ir calcular o proximo termo da sequencia
			NOP								;ignorar

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
