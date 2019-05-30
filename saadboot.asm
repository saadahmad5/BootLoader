bits 16 			;16-bit Real Mode
org 0x7c00 			;BIOS boot origin 

jmp main 			;Jumps to main procedure 

				;Appending zeroes at end of each dup char array

ProgramName db "Saad Ahmad FAST Boot Loader", 0x0						;Dup of Define Bytes

Description db "This is my bootloader program written in assembly language.", 0x0

MyInfo db "Student at FAST-NUCES. Roll no. 15I-0305.", 0x0

RestartMsg db "Press any key to reboot...", 0x0 
 
CharShow:			;Print characters to the screen
    lodsb 			;Load string byte from al 
    or al, al			;Updating al register if there any value except zero
    jz NewLine			;Jumps to complete label when dup char array finishes as it finds zero, appended at end of each char array
    mov ah, 0x0e 		;Moving 0x0e 14h to AH register to print character
    int 0x10 			;BIOS Interrupt 0x10 10h - Used to print characters on the screen via Video Memory 
    jmp CharShow 		;Loop   	

NewLine:			;Now it will print empty new line 
    mov al, 0			;null terminator '\0'
    stosb       		;Store string byte 0 as al has 0 to have a cleared string

    mov al, 0x0d		;ASCII of 14 Carriage Return (similar to Home button) comes at beginning of line
    mov ah, 0x0E		;Moving 0x0e 14h to AH register to print character
    int 0x10			;BIOS Interrupt 0x10 10h

    mov al, 0x0A 		;ASCII of 10 New Line (similar to Enter Key)
    mov ah, 0x0E		;Moving 0x0e 14h to AH register to print character
    int 0x10			;BIOS Interrupt 10h

    ret				;Return back where procedure called

Reboot:				;Reboot the Machine Procedure 
    mov si, RestartMsg		;RestartMsg Variable address to SI register		
    call CharShow		;Calling the Line Print Procedure
    call GetPressedKey 		;Key press detector

    db 0x0ea			;Sends us to the end of the memory to reboot the device 
    dw 0x0000 
    dw 0xffff 
 
GetPressedKey:			;Gets the pressed key
    mov ah, 0			;AH=0x00 0h is buffered input
    int 0x16  			;BIOS Keyboard Interrupt 
    ret 			;Return back where procedure called

main:				;Main Procedure
   cli 				;Clear interrupts 
   
				;Setting up Code, Data, and Stack Segments
   mov ax,cs              
   mov ds,ax   
   mov es,ax               
   mov ss,ax                
   sti 				;Enable interrupts 

   mov si, ProgramName		;Providing ProgramName var to si register 
   call CharShow 		;Calling Print Line procedure

   call NewLine			;Procedure to show a new line

   mov si, Description		;Providing Description var to si register
   call CharShow 		;Calling Print Line procedure

   call NewLine			;Procedure to show a new line

   mov si, MyInfo		;Providing MyInfo var to si register
   call CharShow		;Calling Print Line Procedure

   call NewLine			;Procedure to show a new line

   call Reboot 			;Calling Reboot Procedure

				;Boot sector comprises of512 bytes therefore I'm filling rest of with Nulls using times
   times 510 - ($-$$) db 0 	;Fill the rest of the bootloader program with zeros 
   dw 0xAA55 			;Boot signature
