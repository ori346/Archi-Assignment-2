section	.rodata	
  msg: db "hello world %", 10 ,0
  format: db "%o" ,10 , 0
  
section .data
    size_i:             ; Used to determine the size of the structure
    struc node
        info: resd  1
        next: resd  1
    endstruc
    len: equ $ - size_i  ; Size of the data type

    nullMes:    db  'Null pointer - the list is empty', 10 , 0
    addMes:     db  'Adding a new element', 10,0
    printMes:   db  'Printing a linked list:',10, 0
    cleanMes:   db  'Cleaning an element',10, 0
    doneCleanMes:   db  'Ready for cleaning...',10, 0
    emptyListMes:    db  '- empty list -', 10, 0
    ms: dd 0
    an: dd 0
    size: dd 0
    maxSize: dd 80
    res: dd 0
section .bss
    prim:   resd  1
    currNum: resb 80
    input: resb 80
    stack: resb 63  
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
        jmp getUserInput
        mov ecx , dword[ebp + 12]
        mov ecx , dword [ecx +4]
        push ecx
        push format
      call printf
      add esp, 8
        mov eax ,1
        mov ebx,0
        mov edx,0
        ;mov eax,dword[ecx]
        ;cmp byte[eax], 'q'
        ;je finish
      print:  
        push dword[input]
        push format
        call printf
        add esp, 8

      finish:
            push dword[prim]
            call printl
            popad                    	; restore all previously used registers
            mov eax,0         		; return value 0 no error oucrired 
            mov esp, ebp			; free function activation frame
            pop ebp				; restore Base Pointer previous value (to returnt to the activation frame of main(...))
            ret				; returns from assFunc function

nextLink:
    push dword[res]
    push prim
    call addl
    push dword[prim]
    call printl
    mov dword[res],0 
    add eax ,[input]
    add eax,32
    mov [input] ,eax
  
convert:
    cmp dword[input],0
    je finish
    mov eax, 0 ;eax = current digit
    mov ebx, 1 ;ebx = current base
    mov ecx ,0 ; current result
    mov edx ,0 ;the current postion
    rol dword[input], 8
  conLoop:
    cmp byte[input], 0
    je nextLink
    sub byte[input],'0'
    mov al, byte[input]
    mul ebx
    rol dword[input] ,8
    mov edx , [an]
    inc edx
    mov dword[an] ,edx 
    shl ebx,3
    add dword[res], eax
    push dword[res]
    push format
    call printf
    add esp, 8
    mov eax,0
    mov edx ,[an]
    cmp edx,4
    jne conLoop
    jmp print
    jne conLoop
    jmp print
    
getUserInput:
    mov eax ,0
    push input
    call gets
    add esp,4
    jmp convert
    ;need to inerpret the user input and act by that
    mov eax, dword[eax] ;derefrence input
    jmp print
    cmp byte[eax], 'q'
    je finish
    cmp byte[eax], 'd'
    ;je duplcite 
    cmp byte[eax], 'p'
    jmp popAndprint
    cmp byte[eax], '&'
    jmp myAnd
    cmp byte[eax] , '*'
    ;jmp myMul 
    cmp byte[eax], '+'
    ;je myAdd
    jmp convert 

popAndprint: 
  push eax
  mov eax, dword[stack]
  push eax
  push format
  call printf
  add esp , 8
  sub dword[size] , 1
  jmp getUserInput

duplcite: 
    push eax
    mov eax , dword[stack]
    inc dword[size]
    mov dword[stack] ,eax
    pop eax
    jmp getUserInput

myAnd:
  pushad
  mov eax,[stack]
  dec dword[size]
  mov ebx, [stack]
  dec dword[size]
  and eax, ebx
  ;print eax 


addl:
    push ebp            ; Save the stack
    mov ebp, esp

    push eax            ; Save the registers
    push ebx

    push len            ; Size to get from the heap and pass the size to the malloc function
    call malloc         ; Call the malloc function - now eax has the address of the allocated memory

    mov ebx, [ebp + 12]
    mov [eax + info], ebx    ; Add the element to the node data field
    mov dword [eax + next], 0   ; Address of the next element is NULL, because it is the last element in the list

    mov ebx, [ebp + 8]  ; Retrieve the address to the first element
    cmp dword [ebx], 0
    je null_pointer

    mov ebx, [ebx]      ; This parameter was the address of the address
                        ; Now it is the address of the first element, in this case, not null
    ; If it is not NULL, find the address of the last element
    mov [ebx + next], eax   ; Last element is this one from the newly allocated memory block

go_out:
    pop ebx             ; Restore registers
    pop eax

    mov esp, ebp
    pop ebp
    ret 8               ; Return to the caller function and cleaning the stack

null_pointer:
    mov [ebx], eax      ; Point the address of the first element to the allocated memory
    jmp go_out

push ebp            ; Save the stack
    mov ebp, esp

    push eax            ; Save the registers
    push ebx

    push len            ; Size to get from the heap and pass the size to the malloc function
    call malloc         ; Call the malloc function - now eax has the address of the allocated memory

    mov ebx, [ebp + 12]
    mov [eax + info], ebx    ; Add the element to the node data field
    mov dword [eax + next], 0   ; Address of the next element is NULL, because it is the last element in the list  

    mov ebx, [ebp + 8]  ; Retrieve the address to the first element
    cmp dword [ebx], 0
    je null_pointer

    mov ebx, [ebx]      ; This parameter was the address of the address
                        ; Now it is the address of the first element, in this case, not null
    ; If it is not NULL, find the address of the last element

    mov [eax + next], ebx   ; Last element is this one from the newly allocated memory block
    mov [prim] , eax
              ; Return to the caller function and cleaning the stack


donePop:
    pop ecx
    pop edx                     ; Done - restore the registers and return to the calling procedure
    pop ebx         

    mov esp, ebp
    pop ebp
    ret 4

cleanup:
    push ebp                    ; Save the stack pointer
    mov ebp, esp

    push eax                    ; Save the working registers

    mov eax, [ebp + 8]          ; Retrieve the parameters
    cmp eax, 0                  ; If the address is NULL, then it is past the end of the list
    je doneCleaning             ; No more recursive calls; print an appropriate message

    push dword [eax + next]     ; Push the address of the next element as parameter for the next call to this procedure
    call cleanup


    push eax                    ; Push the address of the current element as parameter for the free function
    call free
    add esp, 4                  ; Aaargh I hate these unpredictable stdlib procedures!

doneAll:                        ; Prepare to exit the procedure
    pop eax
    mov esp, ebp
    pop ebp
    ret 4

doneCleaning:                   ; Print a message that the last element was passed to the procedure
    jmp doneAll

printl:
    push ebp
    mov ebp, esp

    push ebx
    mov ebx, [ebp + 8]  ; Address of the first element
    cmp ebx, 0
    je emptyList
    push eax
    push printMes       ; Print message "Printing a linked list"
    call printf
    add esp, 4
    pop eax
  

next_char:

    mov ebx, [ebx + next]
    cmp ebx, 0
    jne next_char


done:
    pop ebx
    mov esp, ebp
    pop ebp
    ret 4

emptyList:
    jmp done
