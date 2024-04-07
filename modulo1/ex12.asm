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

VETOR: 			.byte 6,"GDDEFC"

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
				.text

				;DEFINICAO - Varrer := por o maior valor mais a direita do vetor

MAIN:			MOV 	#VETOR,R5				;incializar R5 com o endereço do vetor
				MOV.B	@R5,R8					;inicializa o contador
				MOV.B	@R5,R9					;inicializa a quantidade de varridas no vetor
				DEC		R9						;n - 1 varridas
 				CALL 	#ORDENA	 				;chamar sub-rotina
TRAPP:			JMP 	$ 						;travar execução
 				NOP								;exigido pelo montador

ORDENA:			INC 	R5						;R5 aponta para o proximo elemento do vetor
				MOV 	R5, R6					;guarda o elemento do vetor em R6
				INC 	R6						;aponta para o proximo elemento do vetor
				CMP.B 	@R5, 0(R6)				;verifica se elemento do vetor a direita < elemento do vetor a esquerda
				JNC		TROCA					;se elemento do vetor a direita < elemento do vetor a esquerda, entao trocar os elementos a disposicao de posicao
				JMP		INCREMENTA				;elemento a direita e maior, logo ir comparar elemento a direita(ja se tem) e proximo (a direita do que ja se tem)
				NOP

TROCA:			MOV.B	@R6,R7					;armazenar temporariamente o menor valor dos dois comparados em R7
				MOV.B	@R5,0(R6)				;mover elemento da esquerda para a direita no vetor
				MOV.B	R7,0(R5)				;trazer o elemento menor para a esquerda do vetor

INCREMENTA:		DEC.B	R8						;menos um laco a se repetir | menos um no contador
				JZ		VARR					;se contador == 0, entao ir ajustar varreduras
				JMP 	ORDENA					;voltar as comparacoes
	 			RET

VARR:			DEC		R9						;-1 varrida a se fazer
				JZ		TRAPP					;caso R9 == 0, entao encerrar execucao
				MOV		#VETOR,R5				;voltar o ponteiro para o comeco do vetor
				MOV		@R5,R8					;resetar contador
				JMP		ORDENA					;varrer o vetor novamente
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
