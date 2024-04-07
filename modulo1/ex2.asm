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
VETOR:		.byte 11, 0, "KELVINEVANGELISTANEIVA", 0

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

			.text

MAIN:		MOV		#VETOR,R5 		;inicializa R5 com o endereço do vetor
			CALL 	#MAIOR 			;chamar sub-rotina que procura a maior palavra de 16 bits nos elementos do vetor
			JMP 	$ 				;travar execucao ao retornar da sub-rotina

MAIOR:		MOV		@R5, R8			;armazena o tamanho do vetor em R8
			CLR		R7				;limpa onde sera armazenado a frequencia de aparicoes do maior elemento do vetor
			MOV		#0x0000, R6		;coloca o menor valor possivel em R6
			INCD		R5			;proxima palavra do vetor

COMPARA:	CMP		@R5, R6			;verifica se o elemento do vetor e maior do que o conteudo em R6
			JEQ		INC_FREQ		;caso comparacao seja igual a 0, entao aumentar frequencia de aparicoes do maior elemento no vetor
			JHS		CONTAS			;caso o conteudo em R5 seja menor do que o valor em R6, entao nao se deve atualizar o valor em R6
			MOV		@R5, R6			;lido quando o conteudo de R5 > R6
			MOV		#1, R7			;para a primeira aparicao de um novo elemento que seja o maior no vetor, atualizar a frequencia para uma aparicao
			JMP		CONTAS			;verificar se o loop deve encerrar

INC_FREQ:	INC 	R7				;aumentar a frequencia de aparicoes do maior elemento do vetor
			JMP		CONTAS			;verificar se o loop deve encerrar

CONTAS:  	INCD 	R5				;proxima palavra do vetor
			DEC 	R8				;contador: quantidade de vezes que o codigo precisa ocorrer em loop
			JNZ		COMPARA			;para contador diferente de 0, deve-se continuar comparando
			RET						;o vetor foi analisado por completo, fim da logica para encontrar o maior elemento do vetor

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
