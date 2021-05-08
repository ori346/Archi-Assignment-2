;%macro alloc 1
   ; section .data
  ;  stack: resb %1
 ;   section .text
;%endmacro 
    section .data
    msg: db "hello world %s",0x0a ,0x00
    len: dd -$msg
    section .bss
    stack: resb 16
section .text
  align 16
  global main
  extern printf
  extern fprintf 
  extern fflush
  extern malloc 
  extern calloc 
  extern free 
  extern gets 
  extern getchar 
  extern fgets 
  extern stdout
  extern stdin
  extern stderr

main:                       	
        push ebp              		; save Base Pointer (bp) original value
        mov ebp, esp         		; use Base Pointer to access stack contents (do_Str(...) activation frame)
        pushad                   	; push all signficant registers onto stack (backup registers values)
        mov ecx, dword [ebp+8]		; get function argument on stack
        cmp cl, 'q'
        je finish
        push ecx
        push msg
        call printf
        add esp, 8

        finish:                                 
            popad                    	; restore all previously used registers
            mov eax,0         		; return value 0 no error oucrired 
            mov esp, ebp			; free function activation frame
            pop ebp				; restore Base Pointer previous value (to returnt to the activation frame of main(...))
            ret				; returns from assFunc function
