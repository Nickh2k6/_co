// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/4/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)
// The algorithm is based on repetitive addition.

// 檔案名稱: Mult.asm
// 計算 RAM[2] = RAM[0] * RAM[1]
// R0, R1 >= 0，且結果小於 32768。

    @R2
    M=0         // 初始化結果 R2 = 0
    @i
    M=0         // 初始化計數器 i = 0

(LOOP)
    @i
    D=M         // D = i
    @R0
    D=D-M       // D = i - R0
    @END
    D;JGE       // 如果 (i - R0) >= 0，代表加完 R0 次，跳轉到結束

    @R1
    D=M         // D = R1
    @R2
    M=D+M       // R2 = R2 + R1

    @i
    M=M+1       // i = i + 1
    @LOOP
    0;JMP       // 繼續循環

(END)
    @END
    0;JMP       // 無限循環結束程式
