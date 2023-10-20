.586
.MODEL FLAT, C


; Funcions definides en C
printChar_C PROTO C, value:SDWORD
printInt_C PROTO C, value:SDWORD
clearscreen_C PROTO C
clearArea_C PROTO C, value:SDWORD, value1: SDWORD
printMenu_C PROTO C
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C
printBoard_C PROTO C, value: DWORD
initialPosition_C PROTO C
rand PROTO C, value:SDWORD

.code   
   
;;Macros que guarden y recuperen de la pila els registres de proposit general de la arquitectura de 32 bits de Intel  
Push_all macro
	push eax
   	push ebx
    push ecx
    push edx
    push esi
    push edi
endm


Pop_all macro
	pop edi
   	pop esi
   	pop edx
   	pop ecx
   	pop ebx
   	pop eax
endm
   
   
public C posCurScreenP1, getMoveP1, moveCursorP1, movContinuoP1, openP1, openContinuousP1, setupBoard
                         

extern C opc: SDWORD, row:SDWORD, col: BYTE, carac: BYTE, carac2: BYTE, gameCards: BYTE, tauler: BYTE, indexMat: SDWORD
extern C rowScreen: SDWORD, colScreen: SDWORD, RowScreenIni: SDWORD, ColScreenIni: SDWORD
extern C rowIni: SDWORD, colIni: BYTE
extern C gameCards: BYTE, firstVal: SDWORD, firstCol: BYTE, firstRow: SDWORD, cardTurn: SDWORD, totalPairs: SDWORD, totalTries: SDWORD
extern C cards: BYTE

;****************************************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funció de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funció gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
; Paràmetres d'entrada : 
; Cap
;    
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy proc
   push ebp
   mov  ebp, esp
   Push_all

   ; Quan cridem la funció gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els paràmetres s'han de passar per la pila
      
   mov eax, [colScreen]
   push eax
   mov eax, [rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
   Pop_all

   mov esp, ebp
   pop ebp
   ret
gotoxy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un caràcter, guardat a la variable carac
; en la pantalla en la posició on està  el cursor,  
; cridant a la funció printChar_C.
; 
; Variables utilitzades: 
; carac : variable on està emmagatzemat el caracter a treure per pantalla
; 
; Paràmetres d'entrada : 
; Cap
;    
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqué
   ;les funcions de C no mantenen l'estat dels registres.
   
   Push_all

   ; Quan cridem la funció  printch_C(char c) des d'assemblador, 
   ; el paràmetre (carac) s'ha de passar per la pila.
 
   xor eax,eax
   mov  al, [carac]
   push eax 
   call printChar_C
 
   pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
printch endp
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la funció getch_C
; i deixar-lo a la variable carac2.
;
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
;
; Paràmetres d'entrada : 
; Cap
;    
; Paràmetres de sortida: 
; El caracter llegit s'emmagatzema a la variable carac
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getch proc
   push ebp
   mov  ebp, esp
    
   Push_all

   call getch_C
   
   mov [carac2],al
   
   Pop_all

   mov esp, ebp
   pop ebp
   ret
getch endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins el tauler, en funció de
; les variables (row) fila (int) i (col) columna (char), a partir dels
; valors de les constants RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 3 
; i convertir el char de la columna (A..D) a un número entre 0 i 3.
; Per calcular la posició del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes fórmules:
; rowScreen=rowScreenIni+(row*2)
; colScreen=colScreenIni+(col*4)
; Per a posicionar el cursor cridar a la subrutina gotoxy.
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu gameCards/tauler
; col       : columna per a accedir a la matriu gameCards/tauler
; rowScreen : fila on volem posicionar el cursor a la pantalla.
; colScreen : columna on volem posicionar el cursor a la pantalla.
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
posCurScreenP1 proc
    push ebp
	mov  ebp, esp

	Push_all

	mov ebx, 0

    mov eax, [row]
    mov bl, [col]

    dec eax
	sub bl, 'A'

	shl eax, 1
	add eax, RowScreenIni
	mov [rowScreen], eax

	shl ebx, 2
	add ebx, ColScreenIni
	mov [colScreen], ebx

	call gotoxy

    Pop_all

	mov esp, ebp
	pop ebp
	ret
posCurScreenP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la subrutina getch
; Verificar que solament es pot introduir valors entre 'i' i 'l', 
; o les tecles espai ' ', o 's' i deixar-lo a la variable carac2.
; 
; Variables utilitzades: 
; carac2 : variable on s'emmagatzema el caràcter llegit
; 
; Paràmetres d'entrada : 
; Cap
;    
; Paràmetres de sortida: 
; El caràcter llegit s'emmagatzema a la variable carac2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getMoveP1 proc
   push ebp
   mov  ebp, esp

   Push_all

  a: call getch

   cmp [carac2], ' '
   je e
   cmp [carac2], 's'
   je e
   cmp [carac2], 'i'
   jl a
   cmp [carac2], 'l'
   jg a

  e: Pop_all

   mov esp, ebp
   pop ebp
   ret
getMoveP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actualitzar les variables (row) i (col) en funció de 
; la tecla premuda que tenim a la variable (carac2)
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del tauler, (row) i (col) només poden 
; prendre els valors [1..4] i [A..D]. Si al fer el moviment es surt 
; del tauler, no fer el moviment.
; No posicionar el cursor a la pantalla, es fa a posCurScreenP1.
; 
; Variables utilitzades: 
; carac2 : caràcter llegit de teclat
;          'i': amunt, 'j':esquerra, 'k':avall, 'l':dreta
; row : fila del cursor a la matriu gameCards.
; col : columna del cursor a la matriu gameCards.
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursorP1 proc
   push ebp
   mov  ebp, esp 

   Push_all

   mov eax, [row]
   dec eax
   mov ebx,0
   mov bl, [col]
   sub ebx, 'A'

   cmp [carac2],' '
   je m
   cmp [carac2], 's'
   je m

   cmp [carac2], 'i'
   je i
   cmp [carac2], 'j'
   je j
   cmp [carac2], 'k'
   je k
   cmp [carac2], 'l'
   je l

i: cmp eax, 0
   je m
   dec eax
   jmp m
j: cmp ebx, 0
   je m
   dec ebx
   jmp m
k: cmp eax, 3
   je m
   inc eax
   jmp m
l: cmp ebx, 3
   je m
   inc ebx
   jmp m



m: inc eax
   add ebx, 'A'
   mov [col], bl
   mov [row], eax

   Pop_all

   mov esp, ebp
   pop ebp
   ret
moveCursorP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continuo. 
;
; Variables utilitzades:
;		carac2   : variable on s’emmagatzema el caràcter llegit
;		row      : fila per a accedir a la matriu gameCards
;		col      : columna per a accedir a la matriu gameCards
; 
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movContinuoP1 proc
	push ebp
	mov  ebp, esp

	Push_all

z:  call posCurScreenP1
	call getMoveP1
	cmp [carac2], 's'
	je u
	cmp [carac2], ' '
	je u
	call moveCursorP1
	jmp z

u:
	Pop_all


	mov esp, ebp
	pop ebp
	ret
movContinuoP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calcular l'índex per a accedir a les matrius en assemblador.
; gameCards[row][col] en C, és [gameCards+indexMat] en assemblador.
; on indexMat = row*8 + col (col convertir a número).
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu gameCards
; col       : columna per a accedir a la matriu gameCards
; indexMat  : índex per a accedir a la matriu gameCards
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calcIndexP1 proc
	push ebp
	mov  ebp, esp
	Push_all
	
	push eax
	push ebx
	mov eax, 0
	mov eax, [row]
	dec eax
	shl eax, 2
	mov ebx, 0
	mov bl, [col]
	sub ebx, 'A'
	add ebx, eax
	mov indexMat, ebx
	pop eax
	pop ebx

	Pop_all
	mov esp, ebp
	pop ebp
	ret
calcIndexP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; En primer lloc calcular la posició de la matriu corresponent a la
; posició que ocupa el cursor a la pantalla, cridant a la subrutina 
; calcIndexP1. Mostrar el contingut de la casella a la posició de 
; pantalla corresponent.
;
; Canvis per a OpenContinuous:
; En cas de que la carta no estigui girada mostrar el valor
; En cas de que sigui la primera carta girada:
;	- Guardar el valor i la posició de la carta en el registres 
;	  firstVal i firstPos
;	- Actualitzar la matriu tauler y printar el valor per pantalla 
;	  a la seva posició
; En cas de que sigui la segona carta girada:
;	- Comprovar si el valor es el mateix que la primera carta
;		- Si el valor es el mateix actualitzar la matriu tauler, la 
;		  variable totalPairs, i el valor de parelles restants 
;		  mostrat per pantalla (updateScore)
;		- Si el valor no es el mateix, esperar a que el usuari premi 
;		  qualsevol tecla (getMoveP1), esborrar els valors de pantalla 
;		  i la matriu tauler, i actualitzar els intents restants.
; Mostrarem el contingut de la carta criant a la subrutina printch. L'índex per
; a accedir a la matriu gameCards, el calcularem cridant a la subrutina calcIndexP1.
; No es pot obrir una casella que ja tenim oberta o marcada.
;
; Canvis per al nivell avançat:
; Cada vegada que fem una parella o fallem, actualitzar el total de parelles 
; i intents restants.
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu gameCards
; col       : columna per a accedir a la matriu gameCards
; indexMat  : Índex per a accedir a la matriu gameCards
; gameCards : matriu 8x8 on tenim les posicions de les mines. 
; carac	    : caràcter per a escriure a pantalla.
; tauler   : matriu en la que guardem els valors de les tirades 
; firstVal  : valor de la primera carta destapada
; firstPos  : posició de la primera carta destapada
; cardTurn  : flag per controlar si el jugador esta obrint la 
;             primera o la segona carta
; totalPairs: nombre de parelles restants
; totalTries: nombre de intents restants
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; endGame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openP1 proc
	push ebp
	mov  ebp, esp

	Push_all


	call posCurScreenP1
w:  call calcIndexP1
	mov eax, [indexMat]
	cmp tauler[eax], ' '
	jne y
	mov tauler [eax], 'a'
	mov bl, gameCards[eax]
	mov [carac], bl
	inc [cardTurn]
	cmp [cardTurn], 1
	jg g
	
	mov bl,[carac]
	call printch
	mov ecx, [row]
	mov dl, [col]
	mov ebx, [indexMat]
	mov al, gameCards[ebx]
	mov [firstVal], eax
	mov [firstRow], ecx
	mov [firstCol], dl
	jmp y
g:  mov eax, [row]
	mov bl, [col]
	cmp bl,[firstCol]
	jne jijiji
	cmp eax, [firstRow]
	je y
jijiji:mov ecx, [firstVal]
	call posCurScreenP1
	call calcIndexP1
	mov eax, [indexMat]
	call printch
	call calcIndexP1
	push eax
	mov eax,[indexMat]
	pop eax
	mov bl, [carac]
	cmp cl, bl
	jne v
	dec [totalPairs]
	call updateScore
	jmp hola
v:  call getMoveP1
	call posCurScreenP1
	mov tauler [eax], ' '
	mov [carac], ' '
	call printch
	mov eax, [firstRow]
	mov bl, [firstCol]
	mov [row], eax
	mov [col], bl
	call posCurScreenP1
	call calcIndexP1
	mov [carac], ' '
	push eax
	mov eax, [indexMat]
	mov tauler [eax], ' '
	pop eax
	call printch
	call posCurScreenP1
	dec [totalTries]
	call updateScore
	

hola:

	mov [firstVal], 0
	mov [firstRow], 0
	mov [firstCol], 0
	mov [cardTurn], 0

y:	
	

	Pop_all

	mov esp, ebp
	pop ebp
	ret
openP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa l’obertura continua de cartes. S’ha 
; d’utilitzar la tecla espai per girar/obrir una carta i la 's' per 
; sortir. 
;
; Canvis per al nivell avançat: 
; Per a cada moviment introduït comprovar si hem guanyat o perdut el 
; joc compovant les variables totalPairs i totalTries.
;
; Variables utilitzades: 
; carac2     : caràcter introduït per l’usuari
; row        : fila per a accedir a la matriu gameCards
; col        : columna per a accedir a la matriu gameCards
; totalPairs : nombre de variables restants que ens queden en joc
; totalTries : nombre de intents restants que ens queden en joc
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openContinuousP1 proc
	push ebp
	mov  ebp, esp

	Push_all

	mov [cardTurn], 0
jiji:	call movContinuoP1
	cmp [carac2], 's'
	je jaja
	call openP1
	jmp jiji

jaja:	Pop_all

	mov esp, ebp
	pop ebp
	ret
openContinuousP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que mostra el número de parelles restants. Moure el 
; cursor a la posició (row=-1, col=5) i (row=-1, col=3), per printar 
; el número de parelles i intents restants, al finalitzar, retornar
; el cursor a la posició original.
;
; Variables utilitzades: 
; totalPairs : nombre de parelles restants
; totalTries : nombre d'intentns restants
; row        : fila per a accedir a la matriu gameCards
; col        : columna per a accedir a la matriu gameCards
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
updateScore proc
	push ebp
	mov  ebp, esp

	Push_all

	mov [row], -1
	mov [col], 'B'
	call posCurScreenP1
	mov ecx, [totalPairs]
	add ecx, '0'
	mov [carac], cl
	call printch 

	mov [row], -1
	mov [col],'E'
	call posCurScreenP1
	mov ecx, [totalTries]
	add ecx, '0'
	mov [carac], cl
	call printch

	mov ecx, [firstRow]
	mov [row], ecx
	mov cl, [firstCol]
	mov [col], cl
	call posCurScreenP1

	Pop_all

	mov esp, ebp
	pop ebp
	ret
updateScore endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que inicialitza el tauler aleatòriament.
;
; Pistes:
; - La crida a la funció rand guarda el valor aleatori al
;   registre eax
; - La crida a la funció div guarda el modul de la divisió al
;   registre edx
;
; Variables utilitzades: 
; row      : fila per a accedir a la matriu gameCards
; col      : columna per a accedir a la matriu gameCards
; cards	   : llistat ordenat de cartes en joc
; gameCards: matriu de cartes ordenades aleatòriament.
;
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setupBoard proc
	push ebp
	mov  ebp, esp



	mov esp, ebp
	pop ebp
	ret
setupBoard endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que mostra nombres de 2 xifres per pantalla
;
; rowscreen	: fila del cursor a la pantalla
; colscreen	: columna del cursor a la pantalla
; carac		: caràcter a visulatizar per la pantalla
;
; Paràmetres d'entrada : 
; AL: nombre a mostrar
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
showNumbers proc
	push ebp
	mov  ebp, esp



	mov esp, ebp
	pop ebp
	ret
showNumbers endp

;****************************************************************************************


END
