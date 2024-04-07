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
;declarar vetor com 16 elementos de 1 byte "KELVINEVANGNEIVA"

VETOR:		.byte	16,"KELVINEVANGNEIVA"

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

			.text

MAIN:		MOV		#VETOR,R5	;inicializar como o endereço do vetor em R5
			CALL	#MENOR		;chamar SUB_ROT
			JMP		$			;travar execucao ao retornar da sub_rot

MENOR:		MOV.B	@R5,R8		;inicializa o contador em R8
			CLR		R7			;limpa o valor em R7 para 0 | sera a frequencia de aparicoes do menor elemento no vetor
			MOV.B	#0xFF,R6	;armazena em R6 o maior valor possivel em 1 byte
			INC		R5			;aponta para o proximo elemento do vetor

LOOP:		CMP.B	@R5,R6		;compara o elemento apontado no vetor com o valor em R6 e atualiza os valores das flags CVZN
			JEQ		FREQ		;chama quando @R5 == R6
			JLO		NEXT		;se C == '0', entao ir para NEXT
			MOV.B	@R5,R6		;armazenar em R6 o menor valor encontrado em @R5
			MOV.B	#1,R7		;resetar o valor de repeticoes

NEXT:		INC		R5			;próximo elemento do VETOR
			DEC		R8			;contador de elementos restantes a se verificar se e o menor valor
			JNZ		LOOP		;se contador = 0, então ir para MAIN
			RET					;contador == 0

FREQ:		INC 	R7			;repeticao de elemento no vetor
			JMP		NEXT		;voltar de onde chamou em LOOP
			NOP					;coloquei por causa do warning

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
            
