TITLE:  Wordle.asm
;//Author:  Lavan Vivekanandasarma
;//Description: Program w/ Menu that displays two options for single player and two player Wordle.
;//Single player wordle chooses from a select word bank. Two player wordle asks one user for a word 
;//and the other player guesses. Both players alternate in a best of three game. 
;//
;//Date: 18th April 2022
;//=============================================================================================

INCLUDE Irvine32.inc

newline EQU <0Ah, 0Dh>

.data
userOption byte 0h 
errorMsg byte "You have selected an invalid option.", newline, "Please try again.", newline, 0h
testMessage byte "This works sugoi!!! >~<",0h


.code
main PROC
call Randomize

begin:

call clrscr
;// Display menu and get option
mov ebx, offset userOption

call MenuScreen

;// is option legal
cmp UserOption, 1d ;Checks for legality 
jb invalid
cmp userOption, 3d ;Jumps to the driver
jb driver
cmp userOption, 3d ;Exits the program
jmp done

invalid:
push edx 
mov edx, offset errormsg
call writeString
call waitMsg
pop edx  ;// restore edx
jmp begin

driver:
;// set up for the call
call choice
jmp begin

done:
exit
main ENDP


choice proc

;// is it 1
cmp al, 2     
jb option1

;// is it 2
cmp al, 3     
jb option2

option1:
call opt1
jmp quit

option2:
call opt2
jmp quit


quit:
ret
choice ENDP
;//--------------------------------------------------------------------
MenuScreen PROC
;// Description:  Clears all registers
;// Receives: Nothing
;// Returns: UserOption updated with userChoice
;// Requires: Offset of UserOption in EBX

.data
;String for the main Menu
MainMenu byte "Main Menu", newline,
"1.  One-Person Game", newline,
"2.  Two-Person Game", newline,
"3.  Quit", newline,
"        Please make a selection:  ", 0h

.code
push edx
mov edx, offset mainmenu
call writeString
call readDec
mov byte ptr[ebx], al
pop edx

ret
MenuScreen ENDP

;//---------------------------------------------------------------------
;//Description: Option 1 -> Initiates a single game of wordle 
;//Receives: Nothing 
;//Returns: A game of wordle 
;//---------------------------------------------------------------------
opt1 PROC
call WordleSingle
ret
opt1 ENDP
;//--------------------------------------------------------------------------



;//---------------------------------------------------------------------
;//Description: Option 2 -> Initiates a game of wordle with two players.
;//Receives: Nothing
;//Returns: A game of wordle 
;//---------------------------------------------------------------------
opt2 PROC
Call WordleDoubles
ret
opt2 ENDP
;//--------------------------------------------------------------------------

;//---------------------------------------------------------------------
;//Description: Option 3 -> ;Saving for if I need extra credit 
;//Receives: Nothing
;//Returns: Nothing atm 
;//---------------------------------------------------------------------
opt3 PROC


ret
opt3 ENDP
;//--------------------------------------------------------------------------

;//Helper Functions
;//--------------------------------------------------------------------------




;//---------------------------------------------------------------------
;//Description: InputN -> Checks if user input is within range
;//Receives: User Input via stack  
;//Returns: EAX -> 1 if notValid, 0 if valid
;//---------------------------------------------------------------------
InputN PROC
	push ebp ;prologue 
	mov ebp, esp ;prologue 
	mov eax, 0; clears eax
	mov eax, [ebp + 8]; moving first parameter into place
	cmp eax, 5d; compares input to 2
	jne invalidInput;goes to invalidInput, if input is below 2
	jmp validInput
	
	invalidInput:
		pop ebp;epilogue
		mov eax, 1
		ret 4
	validInput:
		pop ebp;epilogue
		mov eax, 0
	ret 4
InputN ENDP

;//---------------------------------------------------------------------
;//Description: Capitilization -> Makes The Passed In Array Capitalized :D
;//Receives: Offset of Array thru User Input via stack  
;//Returns: EAX -> 1 if notValid, 0 if valid
;//---------------------------------------------------------------------
Capitilization Proc 
	push ebp ;prologue 
	mov ebp, esp ;prologue 
	pushad
	
	mov edx, [ebp+8] ;moves offset into edx 
	mov ecx, 0
	mov ecx, 5
	mov ebx, 0
	mov esi, 0
	opt2loop:
	mov bl, [edx + esi];// grab an element of the string
	;// check if bl is in the range of lowercase letters
	cmp bl, 61h;// if below skip
	jb cont
	cmp bl, 7Ah;// if above skip
	ja cont
	sub byte ptr[edx + esi], 20h;// convert to uppercase
	cont:
	inc esi
	loop opt2loop
		
	popad
	pop ebp;epilogue
	ret 4;epilogue

Capitilization ENDP

;//---------------------------------------------------------------------
;//Description: Wordle -> Plays 1 Full Game of Wordle 
;//Receives: The User who is playing and the User who is Guessing  
;//Returns: A Board of Wordle 
;//---------------------------------------------------------------------
WordleDoubles PROC
.data
;askForWord byte "Please enter in a 5 character word ", 0h
winMessage byte "OMG!!! You guessed the word: ", 0h
absoluteWinMessage byte "You have secured victory. ", 0h
loseMessage byte "You were unable to guess the word: ", 0h
luckyWin byte "It may have been sheer luck but... ", 0h

wordleWord byte 6 dup(0h)
guessWord byte 6 dup(0h)
tempWord byte 6 dup(0h)
p1w byte 0d ;number of wins for player1
p2w byte 0d; number of wins for player2
player byte 2d;the current player
feeder byte 1d;the current feeder, ie the person who gives the player the word
roundsPlayed byte 0d; how many rounds have been played
tieBreaker byte 0d; boolean to check if the game enter's tie breaker 


.code
pushad
;----Player-Selection-Start---
mov eax, 0
mov eax, 2
call RandomRange 
cmp eax, 1
jne InputCheckStart
mov player, 1d
mov feeder, 2d
mov tieBreaker, 00
mov roundsPlayed, 00
mov p1w, 00
mov p2w, 00 

;-----Input-Check-Start----

InputCheckStart:

;Swap Sides
mov al, player
mov dl, feeder
mov feeder, al 
mov player, dl

inc roundsPlayed
mov eax, 0
mov ecx, 0
;NOTE TO ME! -> USE THE FOLLOWING 4-5 LINES OF CODE IN YOUR LOOP TO CHECK FOR THE GUESS/WORD
checkWord:
push offset wordleWord;moves the offset of a Guess into place
mov al, feeder ;moves feeder number into place
push eax ;pushes the feeder value
call PrintUser ;prints User 2 or User 1
mov eax, 0
call AskForGuess;asks for a guess, after this eax contains a 0 or a 1
cmp eax, 1d
je checkWord;will constantly send back to guess if word is not 5 letters 

ValidInput:
	;Initiate 2 player game 
push offset wordleWord
call Capitilization
call clrscr
;-----Input-Check-End----

;-----Game-Start----
gameStart:
push ecx
mov ecx, 0
mov ecx, 7
outerCompareWordle:
;NOTE TO ME! -> USE THE FOLLOWING 4-5 LINES OF CODE IN YOUR LOOP TO CHECK FOR THE GUESS 
checkGuess:
mov al, player ;moves player into place
push eax ;pushes the player number 
call PrintUser ;prints User 2 or User 1
mov eax, 0
push offset guessWord;moves the offset of a Guess into place
call AskForGuess;asks for a guess, after this eax contains a 0 or a 1
cmp eax, 1d
je checkGuess;will constantly send back to guess if word is not 5 letters 
push offset guessWord
call Capitilization;capitalizes the guessword!!!

;sets up the colors and bars for the wordle words 
push offset guessWord
push offset wordleWord
push offset tempWord
call ColorSetUp	

push offset tempWord
call PrintsColor
call crlf

;Checks if the guess is the same as the word ie conditions for winning 
push offset guessWord
push offset wordleWord
call WordleWordSame
cmp eax, 1
je roundWon

loop outerCompareWordle

roundOver:
	;Put check for number of rounds played & who the winner is here
	mov eax, 0
	push offset guessWord
	push offset wordleWord
	call WordleWordSame;checks if the last guess is the same as the word 
	cmp eax, 1 
	je roundWon;if there is no 1 in eax, then that means the player lost, else it will jump to roundWon
	push edx
	mov eax, 0
	mov al, player
	push eax
	call printUser
	mov edx, offset loseMessage;prints the lossMessage
	call writeString
	mov edx, offset wordleWord;prints the word
	call writeString
	call crlf
	call waitMsg
	pop edx
	pop ecx
	jmp GameOverOrNah
	
	;check if the game is over
	mov eax, 0
	mov al, roundsPlayed
	cmp eax, 2d 
	jne theShowMustGoOn
	mov eax, 0
	mov al, p1w
	cmp al, p2w 
	jg User1Wins
	push 2
	call printUser
	mov edx, offset absoluteWinMessage
	call writeString
	jmp GameEnd

	
	;if its not over then we play again 
	call clrscr
	jmp InputCheckStart 
	
	roundWon: ;increment the number of wins
	mov eax, 0 
	mov al, player
	cmp eax, 1d
	jne p2won 
	inc p1w
	jmp continue
	p2won:
	inc p2w
	
	continue:
	;print out the you win message
	push edx
	mov al, player ;moves player into place
	push eax ;pushes the player number 
	call PrintUser ;prints User 2 or User 1
	mov eax, 0
	mov edx, offset winMessage;prints the win message 
	call writeString
	mov edx, offset wordleWord;prints the word
	call writeString
	pop edx
	pop ecx
	call crlf
	call waitMsg
	
	
	;check if the game is over
	GameOverOrNah:
	mov eax, 0
	mov al, roundsPlayed
	cmp eax, 2d 
	jnae theShowMustGoOn
	mov eax, 0
	mov al, p1w
	cmp al, p2w 
	je tieBreaking;checks if there is a tie 
	jg User1Wins;if the comparison is greater that means player 1 wins 
	call clrscr
	push 2;if its not greater then user2wins 
	call printUser
	mov edx, offset absoluteWinMessage
	call writeString
	jmp GameEnd
	User1Wins:
	call clrscr
	User1WinsByLuck:
	push 1
	call printUser
	mov edx, offset absoluteWinMessage
	call writeString
	jmp GameEnd
	
	tieBreaking:
	mov eax, 0
	mov al, tieBreaker
	cmp al, 0
	jg randomChanceWin
	
	mov roundsPlayed, 0d
	inc tieBreaker
	jmp theShowMustGoOn
	
	randomChanceWin:
	call clrscr
	mov edx, offset luckyWin
	call writeString
	call crlf
	mov eax, 0
	mov eax, 100d 
	call RandomRange
	cmp eax, 49d
	jg User1WinsByLuck
	push 2
	call printUser
	mov edx, offset absoluteWinMessage
	call writeString
	jmp GameEnd
	
	
	theShowMustGoOn:
	call clrscr
	jmp InputCheckStart
		
;NOTE TO ME: DONT FORGET TO PUT THESE LAST FOUR LINES AT THE END OF ROUNDWON AND ROUNDLOST WHEN FULLY IMPLEMENTING THE TWO PLAYER SOLUTION
GameEnd:
call crlf
mov eax, 0
mov al, p1w
mov ebx, 0
mov bl, p2w
push eax
push ebx
call printScore
call crlf
call waitMsg
popad
mov tieBreaker, 00
mov roundsPlayed, 00
mov p1w, 00
mov p2w, 00 
ret

WordleDoubles ENDP

;//---------------------------------------------------------------------
;//Description: AskForGuess -> Asks for a guess for Wordle 
;//Receives: The Offset of the guess string 
;//Returns: 0 or 1 in eax; 0 -> Guess is not Ok, 1 -> Guess is O
;//---------------------------------------------------------------------
AskForGuess Proc
.data 
numCharsGuess dword 0d
askForWordTwo byte "Please enter a 5 character word ", 0h
.code 
push ebp ;prologue 
mov ebp, esp ;prologue 

mov eax, 0
push ecx
push edx 
mov ecx, 0
mov edx, offset askForWordTwo;moves prompt to ask for word in place 
call writeString ;prints out the prompt
call crlf
mov edx, [ebp+8] ;setup for readString
mov ecx, 6 ;setup for readString
call readString 
mov numCharsGuess, eax ;number of characters is now in numChars
push numCharsGuess ;pushes the number of characters in the word, onto the stack 
call InputN ;InputN checks if this is a valid input s

pop edx 
pop ecx
pop ebp; 
ret 4
AskForGuess EndP


;//---------------------------------------------------------------------
;//Description: WordleWordSame -> Checks if the wordle word is the same as the guess 
;//Receives: The Offset of the guess string, offset of the wordle word  
;//Returns: 0 or 1 in ebx; 0 -> Guess is not the same Ok, 1 -> Guess is the same
;//---------------------------------------------------------------------
WordleWordSame Proc
push ebp ;prologue 
mov ebp, esp ;prologue 
push ebx 
push edx
push esi
push ecx
push edi

mov ecx, 0
mov esi, 0
mov edi, 0
mov ebx, [ebp+8]; eax now has the wordle word
mov edx, [ebp+12]; edx now has the guess


mov ecx, 5
checkString:
	push eax
	mov al, [ebx+esi]
	mov ah, [edx+esi]
	cmp al, ah
	jne notTheSameLetter
	inc edi
	notTheSameLetter:
		inc esi
	pop eax
	loop checkString
mov eax, 1;assume they are the same
cmp edi, 5; if they are the same, then it will go to the end
je exitWordleSame 
mov eax, 0;if they arent the same, edi wont be 5, and well eax will be 0

exitWordleSame:
pop edi 
pop ecx 
pop esi 
pop edx
pop ebx
pop ebp; epilogue 
ret 8;epilogue
WordleWordSame Endp  


;//---------------------------------------------------------------------
;//Description: ColorSetUp -> Checks for similarities & Colors the array accordingly  
;//Receives: The Offset of the guess string, offset of the wordle word, offset of a tempVariable  
;//Returns: 0 or 1 in ebx; 0 -> Guess is not the same Ok, 1 -> Guess is the same
;//---------------------------------------------------------------------
ColorSetUp Proc
push ebp ;prologue 
mov ebp, esp ;prologue 
pushad


mov eax, [ebp+16];this contains guess
mov ebx, [ebp+12];this contains actual word
mov edx, [ebp+8]; this contains a temp var

push edx
call cleanArray
mov ecx, 5
mov esi, 0;outerloop
mov edi, 0;innerloop
forLoopThroughGuessVar:
	push ecx
	mov ecx, 5
	mov edi, 0
	forLoopThroughWordleWord:
	
	push edx;saves edx  
	mov edx, 0
	mov edx, [eax+esi];moves nth char of guessWord 
	cmp dl, [ebx+edi];compares ith char of actualWord
	pop edx;restores edx
	jne goNextIteration;if not equal, then skip this and move on
	
	mov eax, [edx + esi]
	cmp al, 16
	je goNextIteration
	
	setYellow:
	mov eax, 0
	mov eax, 224
	mov [edx+esi], al;setColorYellow  
	
	
	cmp edi, esi;checks if the index is the same
	jne goNextIteration
	
	push eax
	mov eax, 0
	mov eax, 16
	mov [edx+esi], al;setColorBlue
	pop eax
	
	goNextIteration:
	mov eax, [ebp+16]
	inc edi 
	loop forLoopThroughWordleWord
	pop ecx 
	inc esi 
loop forLoopThroughGuessVar
popad
pop ebp; epilogue 
ret 12;epilogue
ColorSetUp Endp 


;//---------------------------------------------------------------------
;//Description: PrintsColor -> Prints Out The Wordle Part (Colors and Stuff)  
;//Receives: Offset of a tempVariable  
;//Returns: 0 or 1 in ebx; 0 -> Guess is not the same Ok, 1 -> Guess is the same
;//---------------------------------------------------------------------
PrintsColor Proc
.data
bar byte "|", 0h
spacebar byte " ",0h 

.code
push ebp ;prologue 
mov ebp, esp ;prologue 
pushad

mov edx, 0
mov ebx, 0
mov ebx, [ebp+8]

mov esi, 0
mov ecx, 0
mov ecx, 5
push edx
mov edx, offset bar
call writeString ;prints out the initial left bar 
pop edx
printOutColors:
mov al, [ebx+esi]
call SetTextColor;changes the color to whatever was in the tempvar
push edx
mov edx, offset spacebar 
call writeString
pop edx
mov eax, 0
mov eax, 7
call setTextColor;sets color back to gray
mov edx, offset bar
call writeString ;prints out the right bar 
inc esi 
loop printOutColors

mov eax, 0
mov eax, 7
call setTextColor
mov edx, offset bar

popad
pop ebp; epilogue 
ret 4;epilogue
PrintsColor Endp 




;//---------------------------------------------------------------------
;//Description: cleanArray -> puts 0 in every element of the word arrays 
;//Receives: Offset of an array   
;//Returns: 0's in the array
;//---------------------------------------------------------------------
cleanArray Proc
push ebp ;prologue 
mov ebp, esp ;prologue 
pushad
mov edx, 0
mov edx, [ebp+8]

mov esi,0
mov ecx,0
mov ecx,5
delete:
	mov eax, 0
	mov [edx+esi], al
	inc esi
	loop delete

popad
pop ebp; epilogue 
ret 4;epilogue
cleanArray endp


;//---------------------------------------------------------------------
;//Description: Wordle -> Plays a Game of Wordle Meant for one person  
;//Receives: NA
;//Returns: A game of wordle tempWord
;//---------------------------------------------------------------------
WordleSingle Proc
.data
;askForWord byte "Please enter in a 5 character word ", 0h
winMessageSingle byte "OMG!!!! You guessed the word: ", 0h
loseMessageSingle byte "You were unable to guess the word: ", 0h

wordleWordSingle byte 6 dup(0h)
guessWordSingle byte 6 dup(0h)
tempWordSingle byte 6 dup(0h)


.code
pushad
;-----Input-Check-Start----
mov eax, 0
mov ecx, 0
;NOTE TO ME! -> USE THE FOLLOWING 4-5 LINES OF CODE IN YOUR LOOP TO CHECK FOR THE GUESS/WORD
push offset wordleWordSingle
call WordleWordGen
push offset wordleWordSingle
call Capitilization
;-----Input-Check-End----

;-----Game-Start----
push ecx
mov ecx, 0
mov ecx, 7
outerCompareWordleSingle:
;NOTE TO ME! -> USE THE FOLLOWING 4-5 LINES OF CODE IN YOUR LOOP TO CHECK FOR THE GUESS  
checkGuessSingle:
push offset guessWordSingle;moves the offset of a Guess into place
call AskForGuess;asks for a guess, after this eax contains a 0 or a 1
cmp eax, 1d
je checkGuessSingle;will constantly send back to guess if word is not 5 letters 
push offset guessWordSingle
call Capitilization;capitalizes the guessword!!!

;sets up the colors and bars for the wordle words 
push offset guessWordSingle
push offset wordleWordSingle
push offset tempWordSingle
call ColorSetUp	

push offset tempWordSingle
call PrintsColor
call crlf
;Checks if the guess is the same as the word ie conditions for winning 
push offset guessWordSingle
push offset wordleWordSingle
call WordleWordSame
cmp eax, 1
je roundWonSingle
loop outerCompareWordleSingle

roundOverSingle:
	;Put check for number of rounds played & who the winner is here
	mov eax, 0
	push offset guessWordSingle
	push offset wordleWordSingle
	call WordleWordSame;checks if the last guess is the same as the word 
	cmp eax, 1 
	je roundWonSingle;if there is no 1 in eax, then that means the player lost, else it will jump to roundWon 
	push edx 
	mov edx, offset loseMessageSingle;prints the lossMessage
	call writeString
	mov edx, offset wordleWordSingle;prints the word
	call writeString
	pop edx
	pop ecx
	jmp GameEndSingle 
	
	roundWonSingle:
	push edx
	mov edx, offset winMessageSingle;prints the win message 
	call writeString
	mov edx, offset wordleWordSingle;prints the word
	call writeString
	pop edx
	pop ecx

;NOTE TO ME: DONT FORGET TO PUT THESE LAST FOUR LINES AT THE END OF ROUNDWON AND ROUNDLOST WHEN FULLY IMPLEMENTING THE TWO PLAYER SOLUTION
GameEndSingle:
call crlf
call waitMsg
popad
ret
WordleSingle endp





;//---------------------------------------------------------------------
;//Description: WordleWordGen -> Fills an input array with a random 5 letter word  
;//Receives: An empty 5 letter array
;//Returns: A random 5 letter word
;//---------------------------------------------------------------------
WordleWordGen Proc
.data
wordBank byte "Apple", "Eager", "Timer", "Eight", "Seven", "Whole"
		 byte "Jazzy","Fixer","About","Actor", "Doggy", "Acute"
		 byte "Panic", "Grade", "Adult", "Basis", "Beach", "Argue"		 
		 byte "Begin", "Event", "Error", "Brave", "There", "Court"
		 byte "Cream", "Steam", "Dance", "Doubt", "Final", "Floor"
		 byte "Hotel", "Image", "Music", "Panel", "Phase", "Phase"
		 byte "Rugby", "Shirt", "Shift", "Sight", "Night", "Might"
		 byte "Smile", "Smith", "Voice", 0h
wordBankSize byte 45d

.code
push ebp ;prologue 
mov ebp, esp ;prologue 
pushad
mov eax, 0
mov al, wordBankSize;setup parameter for wordbank to be generated!!!!!! (I am slowly going insane. Alas Assembly, why must you be so rigid!)
call RandomRange ;generates random num from [0, 45) and places it within eax!!!!!!!!!!! OMG!!!
mov edi, 0
mov edx, 0
mov ebx, offset wordBank;offset of the wordbank
mov ecx, 0
mov ecx, 5;for 5 letter words
mov esi, 0
mov edi, 5
mul edi
mov edi, 0
mov edi, [ebp+8];offset of guessword. 
wordBankCopy:
	add esi, eax
	mov dl, [ebx+esi]
	sub esi, eax
	mov [edi+esi], dl
	inc esi
	loop wordBankCopy
	
popad
pop ebp; epilogue 
ret 4;epilogue
WordleWordGen endp

;//---------------------------------------------------------------------
;//Description: printUser -> prints User 1 or 2 depending on input
;//Receives: a 1 or 2, the users number 
;//Returns: "printing User 1:" or "User 2:"
;//---------------------------------------------------------------------
PrintUser Proc
.data
user byte "User ",0d
colon byte ": ", 0d

.code
push ebp ;prologue 
mov ebp, esp ;prologue 
pushad

mov edx, offset user
call writeString
mov eax, 0
mov eax, [ebp+8]
call WriteDec
mov edx, offset colon
call writeString

popad
pop ebp; epilogue 
ret 4;epilogue
PrintUser endp

;//---------------------------------------------------------------------
;//Description: printScore -> prints the score/stats at the end of the game 
;//Receives: user 1 info, user 2 info  
;//Returns: "User 1's Score:" and "User 2's Score :"
;//---------------------------------------------------------------------
printScore Proc
.data
user1 byte "User 1's Round wins: ",0d
user2 byte "User 2's Round wins: ",0d

.code
push ebp ;prologue 
mov ebp, esp ;prologue 
pushad

mov edx, offset user1
call writeString
mov eax, 0
mov eax, [ebp+12]
call WriteDec
call crlf
mov edx, offset user2
call writeString
mov eax, 0
mov eax, [ebp+8]
call WriteDec


popad
pop ebp; epilogue 
ret 8;epilogue
printScore endp




END main

