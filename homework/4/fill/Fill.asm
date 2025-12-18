// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/4/Fill.asm

// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, 
// the screen should be cleared.

// 檔案名稱: Fill.asm
// 當按鍵被按下時，螢幕變黑 (全 1)。
// 當按鍵放開時，螢幕變白 (全 0)。

(LISTEN)
    @KBD
    D=M         // 讀取鍵盤位址
    @BLACKEN
    D;JNE       // 如果鍵盤值 != 0 (有按鍵)，跳到變黑邏輯
    @WHITEN
    D;JEQ       // 如果鍵盤值 == 0 (無按鍵)，跳到變白邏輯

(BLACKEN)
    @color
    M=-1        // 設置填滿顏色為 -1 (1111111111111111)
    @DRAW
    0;JMP

(WHITEN)
    @color
    M=0         // 設置填滿顏色為 0 (0000000000000000)
    @DRAW
    0;JMP

(DRAW)
    @SCREEN
    D=A
    @pixels
    M=D         // 設定 pixels 起始位址為 SCREEN 位址

(DRAW_LOOP)
    @color
    D=M         // 載入當前顏色
    @pixels
    A=M
    M=D         // 將顏色寫入當前像素記憶體位址

    @pixels
    M=M+1       // 移動到下一個位址
    D=M
    @24576      // 螢幕記憶體映射結束於 24575 (16384+8192)
    D=D-A
    @LISTEN
    D;JEQ       // 如果所有位址都填滿了，回到監聽狀態
    
    @DRAW_LOOP
    0;JMP       // 繼續填色循環
