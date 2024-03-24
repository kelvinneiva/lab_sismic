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

PE4:		CLR			R5 			;Zerar R5
 			MOV 		#4,R6 		;Colocar o número 4 em R6

LOOP: 		CALL 		#SUBROT 	;Chamar subrotina "SUBROT"
 			DEC 		R6 			;Decrementar R6
 			JNZ 		LOOP 		;Se diferente de zero, ir para LOOP ;Its stands for "Jump if Not Zero" ;Jump back to LOOP if R6 is not zero
 			NOP 					;Nenhuma operação
 			JMP 		$ 			;Travar execução num laço infinito
 			NOP 					;Nenhuma operação

SUBROT:		ADD			#1,R5 		;Somar 1 em R5
 			ADD 		#1,R5 		;Somar 1 em R5
 			RET 					;Retornar

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
            
