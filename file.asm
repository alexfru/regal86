; Compile this file with nasm:
;   nasm file.asm -o file.com
; Run file.com in DOS, 32-bit Windows or DOSBox.

bits 16
cpu 8086
org 0x100

; Shrink/extend the PSP block to 64KB.
    mov  ah, 0x4a
    mov  bx, 4096
    int  0x21
    jc   no_memory
    mov  sp, 0 ; stack at end of 64KB block

; 5    (vr0)
; ----
; Regs needed (approximately): 1
; --------
    ;                           ; vr0
    mov  ax, 5                  ; vr0
    ;                           ; vr0
    cmp  ax, 5                  ; vr0
    jne  failure                ; vr0

; neg     (vr1)
;     7    (vr0)
; ----
; Regs needed (approximately): 1
; --------
    ;                           ; vr0
    mov  ax, 7                  ; vr0
    neg  ax                     ; vr1
    ;                           ; vr1
    cmp  ax, 65529              ; vr1
    jne  failure                ; vr1

; not     (vr1)
;     7    (vr0)
; ----
; Regs needed (approximately): 1
; --------
    ;                           ; vr0
    mov  ax, 7                  ; vr0
    not  ax                     ; vr1
    ;                           ; vr1
    cmp  ax, 65528              ; vr1
    jne  failure                ; vr1

;     4    (vr1)
; add     (vr2)
;     3    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    ;                           ; vr0
    mov  ax, 3                  ; vr0
    mov  cx, 4                  ; vr1
    add  ax, cx                 ; vr2
    ;                           ; vr2
    cmp  ax, 7                  ; vr2
    jne  failure                ; vr2

;         4    (vr4)
;     or      (vr5)
;         2    (vr3)
; xor     (vr6)
;         3    (vr1)
;     and     (vr2)
;         1    (vr0)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 1                  ; vr0
    mov  cx, 3                  ; vr1
    and  ax, cx                 ; vr2
    mov  cx, 2                  ; vr3
    mov  dx, 4                  ; vr4
    or   cx, dx                 ; vr5
    xor  ax, cx                 ; vr6
    ;                           ; vr6
    cmp  ax, 7                  ; vr6
    jne  failure                ; vr6

;         5    (vr1)
;     mul     (vr2)
;         3    (vr0)
; add     (vr4)
;     2    (vr3)
; ----
; Regs needed (approximately): 2
; --------
    ;                           ; vr0
    mov  ax, 3                  ; vr0
    mov  cx, 5                  ; vr1
    mul  cx                     ; vr2
    mov  cx, 2                  ; vr3
    add  cx, ax                 ; vr4
    ;                           ; vr4
    cmp  cx, 17                 ; vr4
    jne  failure                ; vr4

;         7    (vr4)
;     mul     (vr5)
;         5    (vr3)
; add     (vr6)
;         3    (vr1)
;     mul     (vr2)
;         2    (vr0)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 2                  ; vr0
    mov  cx, 3                  ; vr1
    mul  cx                     ; vr2
    mov  cx, 5                  ; vr3
    mov  dx, 7                  ; vr4
    xchg ax, cx                 ; vr5
    mul  dx                     ; vr5
    add  cx, ax                 ; vr6
    ;                           ; vr6
    cmp  cx, 41                 ; vr6
    jne  failure                ; vr6

;                 16    (vr26)
;             add     (vr27)
;                 15    (vr25)
;         add     (vr28)
;                 14    (vr23)
;             add     (vr24)
;                 13    (vr22)
;     add     (vr29)
;                 12    (vr19)
;             add     (vr20)
;                 11    (vr18)
;         add     (vr21)
;                 10    (vr16)
;             add     (vr17)
;                 9    (vr15)
; add     (vr30)
;                 8    (vr11)
;             add     (vr12)
;                 7    (vr10)
;         add     (vr13)
;                 6    (vr8)
;             add     (vr9)
;                 5    (vr7)
;     add     (vr14)
;                 4    (vr4)
;             add     (vr5)
;                 3    (vr3)
;         add     (vr6)
;                 2    (vr1)
;             add     (vr2)
;                 1    (vr0)
; ----
; Regs needed (approximately): 5
; --------
    ;                           ; vr0
    mov  ax, 1                  ; vr0
    mov  cx, 2                  ; vr1
    add  ax, cx                 ; vr2
    mov  cx, 3                  ; vr3
    mov  dx, 4                  ; vr4
    add  cx, dx                 ; vr5
    add  ax, cx                 ; vr6
    mov  cx, 5                  ; vr7
    mov  dx, 6                  ; vr8
    add  cx, dx                 ; vr9
    mov  dx, 7                  ; vr10
    mov  bx, 8                  ; vr11
    add  dx, bx                 ; vr12
    add  cx, dx                 ; vr13
    add  ax, cx                 ; vr14
    mov  cx, 9                  ; vr15
    mov  dx, 10                 ; vr16
    add  cx, dx                 ; vr17
    mov  dx, 11                 ; vr18
    mov  bx, 12                 ; vr19
    add  dx, bx                 ; vr20
    add  cx, dx                 ; vr21
    mov  dx, 13                 ; vr22
    mov  bx, 14                 ; vr23
    add  dx, bx                 ; vr24
    mov  bx, 15                 ; vr25
    mov  si, 16                 ; vr26
    add  bx, si                 ; vr27
    add  dx, bx                 ; vr28
    add  cx, dx                 ; vr29
    add  ax, cx                 ; vr30
    ;                           ; vr30
    cmp  ax, 136                ; vr30
    jne  failure                ; vr30

;                 16    (vr26)
;             sub     (vr27)
;                 15    (vr25)
;         sub     (vr28)
;                 14    (vr23)
;             sub     (vr24)
;                 13    (vr22)
;     sub     (vr29)
;                 12    (vr19)
;             sub     (vr20)
;                 11    (vr18)
;         sub     (vr21)
;                 10    (vr16)
;             sub     (vr17)
;                 9    (vr15)
; sub     (vr30)
;                 8    (vr11)
;             sub     (vr12)
;                 7    (vr10)
;         sub     (vr13)
;                 6    (vr8)
;             sub     (vr9)
;                 5    (vr7)
;     sub     (vr14)
;                 4    (vr4)
;             sub     (vr5)
;                 3    (vr3)
;         sub     (vr6)
;                 2    (vr1)
;             sub     (vr2)
;                 1    (vr0)
; ----
; Regs needed (approximately): 5
; --------
    ;                           ; vr0
    mov  ax, 1                  ; vr0
    mov  cx, 2                  ; vr1
    sub  ax, cx                 ; vr2
    mov  cx, 3                  ; vr3
    mov  dx, 4                  ; vr4
    sub  cx, dx                 ; vr5
    sub  ax, cx                 ; vr6
    mov  cx, 5                  ; vr7
    mov  dx, 6                  ; vr8
    sub  cx, dx                 ; vr9
    mov  dx, 7                  ; vr10
    mov  bx, 8                  ; vr11
    sub  dx, bx                 ; vr12
    sub  cx, dx                 ; vr13
    sub  ax, cx                 ; vr14
    mov  cx, 9                  ; vr15
    mov  dx, 10                 ; vr16
    sub  cx, dx                 ; vr17
    mov  dx, 11                 ; vr18
    mov  bx, 12                 ; vr19
    sub  dx, bx                 ; vr20
    sub  cx, dx                 ; vr21
    mov  dx, 13                 ; vr22
    mov  bx, 14                 ; vr23
    sub  dx, bx                 ; vr24
    mov  bx, 15                 ; vr25
    mov  si, 16                 ; vr26
    sub  bx, si                 ; vr27
    sub  dx, bx                 ; vr28
    sub  cx, dx                 ; vr29
    sub  ax, cx                 ; vr30
    ;                           ; vr30
    cmp  ax, 0                  ; vr30
    jne  failure                ; vr30

;             5    (vr1)
;         mul     (vr2)
;             4    (vr0)
;     mul     (vr4)
;         3    (vr3)
; mul     (vr6)
;     2    (vr5)
; ----
; Regs needed (approximately): 2
; --------
    ;                           ; vr0
    mov  ax, 4                  ; vr0
    mov  cx, 5                  ; vr1
    mul  cx                     ; vr2
    mov  cx, 3                  ; vr3
    mul  cx                     ; vr4
    mov  cx, 2                  ; vr5
    mul  cx                     ; vr6
    ;                           ; vr6
    cmp  ax, 120                ; vr6
    jne  failure                ; vr6

;             8    (vr11)
;         mul     (vr12)
;             7    (vr10)
;     add     (vr13)
;             6    (vr8)
;         mul     (vr9)
;             5    (vr7)
; mul     (vr14)
;             4    (vr4)
;         mul     (vr5)
;             3    (vr3)
;     add     (vr6)
;             2    (vr1)
;         mul     (vr2)
;             1    (vr0)
; ----
; Regs needed (approximately): 4
; --------
    ;                           ; vr0
    mov  ax, 1                  ; vr0
    mov  cx, 2                  ; vr1
    mul  cx                     ; vr2
    mov  cx, 3                  ; vr3
    mov  dx, 4                  ; vr4
    xchg ax, cx                 ; vr5
    mul  dx                     ; vr5
    add  ax, cx                 ; vr6
    mov  cx, 5                  ; vr7
    mov  dx, 6                  ; vr8
    xchg ax, cx                 ; vr9
    mul  dx                     ; vr9
    mov  dx, 7                  ; vr10
    mov  bx, 8                  ; vr11
    xchg ax, bx                 ; vr12
    mul  dx                     ; vr12
    add  ax, bx                 ; vr13
    mul  cx                     ; vr14
    ;                           ; vr14
    cmp  ax, 1204               ; vr14
    jne  failure                ; vr14

;     3    (vr0)
; shl     (vr2)
;     4    (vr1)
; ----
; Regs needed (approximately): 2
; --------
    ;                           ; vr0
    mov  cx, 3                  ; vr0
    mov  ax, 4                  ; vr1
    shl  ax, cl                 ; vr2
    ;                           ; vr2
    cmp  ax, 32                 ; vr2
    jne  failure                ; vr2

;     3    (vr0)
; shr     (vr2)
;     63    (vr1)
; ----
; Regs needed (approximately): 2
; --------
    ;                           ; vr0
    mov  cx, 3                  ; vr0
    mov  ax, 63                 ; vr1
    shr  ax, cl                 ; vr2
    ;                           ; vr2
    cmp  ax, 7                  ; vr2
    jne  failure                ; vr2

;     3    (vr0)
; sar     (vr2)
;     65479    (vr1)
; ----
; Regs needed (approximately): 2
; --------
    ;                           ; vr0
    mov  cx, 3                  ; vr0
    mov  ax, 65479              ; vr1
    sar  ax, cl                 ; vr2
    ;                           ; vr2
    cmp  ax, 65528              ; vr2
    jne  failure                ; vr2

;     5    (vr3)
; shl     (vr4)
;         3    (vr0)
;     shl     (vr2)
;         4    (vr1)
; ----
; Regs needed (approximately): 2
; --------
    ;                           ; vr0
    mov  cx, 3                  ; vr0
    mov  ax, 4                  ; vr1
    shl  ax, cl                 ; vr2
    mov  cx, 5                  ; vr3
    shl  ax, cl                 ; vr4
    ;                           ; vr4
    cmp  ax, 1024               ; vr4
    jne  failure                ; vr4

;         3    (vr0)
;     shl     (vr2)
;         4    (vr1)
; shl     (vr4)
;     5    (vr3)
; ----
; Regs needed (approximately): 2
; --------
    ;                           ; vr0
    mov  cx, 3                  ; vr0
    mov  ax, 4                  ; vr1
    shl  ax, cl                 ; vr2
    mov  dx, 5                  ; vr3
    mov  cx, ax                 ; vr4
    shl  dx, cl                 ; vr4
    ;                           ; vr4
    cmp  dx, 5                  ; vr4
    jne  failure                ; vr4

;         2    (vr0)
;     shl     (vr2)
;         1    (vr1)
; mul     (vr4)
;     3    (vr3)
; ----
; Regs needed (approximately): 2
; --------
    ;                           ; vr0
    mov  cx, 2                  ; vr0
    mov  ax, 1                  ; vr1
    shl  ax, cl                 ; vr2
    mov  cx, 3                  ; vr3
    mul  cx                     ; vr4
    ;                           ; vr4
    cmp  ax, 12                 ; vr4
    jne  failure                ; vr4

;     3    (vr3)
; shl     (vr4)
;         2    (vr1)
;     mul     (vr2)
;         1    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    ;                           ; vr0
    mov  ax, 1                  ; vr0
    mov  cx, 2                  ; vr1
    mul  cx                     ; vr2
    mov  cx, 3                  ; vr3
    shl  ax, cl                 ; vr4
    ;                           ; vr4
    cmp  ax, 16                 ; vr4
    jne  failure                ; vr4

;         2    (vr1)
;     mul     (vr2)
;         1    (vr0)
; shl     (vr4)
;     3    (vr3)
; ----
; Regs needed (approximately): 2
; --------
    ;                           ; vr0
    mov  ax, 1                  ; vr0
    mov  cx, 2                  ; vr1
    mul  cx                     ; vr2
    mov  dx, 3                  ; vr3
    mov  cx, ax                 ; vr4
    shl  dx, cl                 ; vr4
    ;                           ; vr4
    cmp  dx, 12                 ; vr4
    jne  failure                ; vr4

;         4    (vr1)
;     mul     (vr2)
;         3    (vr0)
; shl     (vr6)
;         2    (vr4)
;     mul     (vr5)
;         1    (vr3)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 3                  ; vr0
    mov  cx, 4                  ; vr1
    mul  cx                     ; vr2
    mov  cx, 1                  ; vr3
    mov  dx, 2                  ; vr4
    xchg ax, cx                 ; vr5
    mul  dx                     ; vr5
    shl  ax, cl                 ; vr6
    ;                           ; vr6
    cmp  ax, 8192               ; vr6
    jne  failure                ; vr6

;         4    (vr3)
;     shl     (vr5)
;         3    (vr4)
; mul     (vr6)
;         2    (vr0)
;     shl     (vr2)
;         1    (vr1)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  cx, 2                  ; vr0
    mov  ax, 1                  ; vr1
    shl  ax, cl                 ; vr2
    mov  cx, 4                  ; vr3
    mov  dx, 3                  ; vr4
    shl  dx, cl                 ; vr5
    mul  dx                     ; vr6
    ;                           ; vr6
    cmp  ax, 192                ; vr6
    jne  failure                ; vr6

;         4    (vr1)
;     add     (vr2)
;         3    (vr0)
; shl     (vr6)
;         2    (vr4)
;     add     (vr5)
;         1    (vr3)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  cx, 3                  ; vr0
    mov  ax, 4                  ; vr1
    add  cx, ax                 ; vr2
    mov  ax, 1                  ; vr3
    mov  dx, 2                  ; vr4
    add  ax, dx                 ; vr5
    shl  ax, cl                 ; vr6
    ;                           ; vr6
    cmp  ax, 384                ; vr6
    jne  failure                ; vr6

;                 16    (vr26)
;             mul     (vr27)
;                 15    (vr25)
;         add     (vr28)
;                 14    (vr23)
;             mul     (vr24)
;                 13    (vr22)
;     mul     (vr29)
;                 12    (vr19)
;             mul     (vr20)
;                 11    (vr18)
;         add     (vr21)
;                 10    (vr16)
;             mul     (vr17)
;                 9    (vr15)
; mul     (vr30)
;                 8    (vr11)
;             mul     (vr12)
;                 7    (vr10)
;         add     (vr13)
;                 6    (vr8)
;             mul     (vr9)
;                 5    (vr7)
;     mul     (vr14)
;                 4    (vr4)
;             mul     (vr5)
;                 3    (vr3)
;         add     (vr6)
;                 2    (vr1)
;             mul     (vr2)
;                 1    (vr0)
; ----
; Regs needed (approximately): 5
; --------
    ;                           ; vr0
    mov  ax, 1                  ; vr0
    mov  cx, 2                  ; vr1
    mul  cx                     ; vr2
    mov  cx, 3                  ; vr3
    mov  dx, 4                  ; vr4
    xchg ax, cx                 ; vr5
    mul  dx                     ; vr5
    add  ax, cx                 ; vr6
    mov  cx, 5                  ; vr7
    mov  dx, 6                  ; vr8
    xchg ax, cx                 ; vr9
    mul  dx                     ; vr9
    mov  dx, 7                  ; vr10
    mov  bx, 8                  ; vr11
    xchg ax, bx                 ; vr12
    mul  dx                     ; vr12
    add  ax, bx                 ; vr13
    mul  cx                     ; vr14
    mov  cx, 9                  ; vr15
    mov  dx, 10                 ; vr16
    xchg ax, cx                 ; vr17
    mul  dx                     ; vr17
    mov  dx, 11                 ; vr18
    mov  bx, 12                 ; vr19
    xchg ax, bx                 ; vr20
    mul  dx                     ; vr20
    add  ax, bx                 ; vr21
    mov  dx, 13                 ; vr22
    mov  bx, 14                 ; vr23
    xchg ax, bx                 ; vr24
    mul  dx                     ; vr24
    mov  dx, 15                 ; vr25
    mov  si, 16                 ; vr26
    xchg ax, si                 ; vr27
    mul  dx                     ; vr27
    add  ax, si                 ; vr28
    mul  bx                     ; vr29
    mul  cx                     ; vr30
    ;                           ; vr30
    cmp  ax, 8080               ; vr30
    jne  failure                ; vr30

;                 16    (vr26)
;             mul     (vr27)
;                 15    (vr25)
;         sub     (vr28)
;                 14    (vr23)
;             mul     (vr24)
;                 13    (vr22)
;     mul     (vr29)
;                 12    (vr19)
;             mul     (vr20)
;                 11    (vr18)
;         sub     (vr21)
;                 10    (vr16)
;             mul     (vr17)
;                 9    (vr15)
; mul     (vr30)
;                 8    (vr11)
;             mul     (vr12)
;                 7    (vr10)
;         sub     (vr13)
;                 6    (vr8)
;             mul     (vr9)
;                 5    (vr7)
;     mul     (vr14)
;                 4    (vr4)
;             mul     (vr5)
;                 3    (vr3)
;         sub     (vr6)
;                 2    (vr1)
;             mul     (vr2)
;                 1    (vr0)
; ----
; Regs needed (approximately): 5
; --------
    ;                           ; vr0
    mov  ax, 1                  ; vr0
    mov  cx, 2                  ; vr1
    mul  cx                     ; vr2
    mov  cx, 3                  ; vr3
    mov  dx, 4                  ; vr4
    xchg ax, cx                 ; vr5
    mul  dx                     ; vr5
    sub  cx, ax                 ; vr6
    mov  ax, 5                  ; vr7
    mov  dx, 6                  ; vr8
    mul  dx                     ; vr9
    mov  dx, 7                  ; vr10
    mov  bx, 8                  ; vr11
    xchg ax, bx                 ; vr12
    mul  dx                     ; vr12
    sub  bx, ax                 ; vr13
    mov  ax, cx                 ; vr14
    mul  bx                     ; vr14
    mov  cx, 9                  ; vr15
    mov  dx, 10                 ; vr16
    xchg ax, cx                 ; vr17
    mul  dx                     ; vr17
    mov  dx, 11                 ; vr18
    mov  bx, 12                 ; vr19
    xchg ax, bx                 ; vr20
    mul  dx                     ; vr20
    sub  bx, ax                 ; vr21
    mov  ax, 13                 ; vr22
    mov  dx, 14                 ; vr23
    mul  dx                     ; vr24
    mov  dx, 15                 ; vr25
    mov  si, 16                 ; vr26
    xchg ax, si                 ; vr27
    mul  dx                     ; vr27
    sub  si, ax                 ; vr28
    mov  ax, bx                 ; vr29
    mul  si                     ; vr29
    mul  cx                     ; vr30
    ;                           ; vr30
    cmp  ax, 43536              ; vr30
    jne  failure                ; vr30

;     3    (vr1)
; idiv    (vr2)
;     65528    (vr0)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 65528              ; vr0
    mov  cx, 3                  ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    ;                           ; vr2
    cmp  ax, 65534              ; vr2
    jne  failure                ; vr2

;     65533    (vr1)
; idiv    (vr2)
;     8    (vr0)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 8                  ; vr0
    mov  cx, 65533              ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    ;                           ; vr2
    cmp  ax, 65534              ; vr2
    jne  failure                ; vr2

;     3    (vr1)
; div     (vr2)
;     8    (vr0)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 8                  ; vr0
    mov  cx, 3                  ; vr1
    xor  dx, dx                 ; vr2
    div  cx                     ; vr2
    ;                           ; vr2
    cmp  ax, 2                  ; vr2
    jne  failure                ; vr2

;     4    (vr3)
; idiv    (vr4)
;         65531    (vr1)
;     idiv    (vr2)
;         60    (vr0)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 60                 ; vr0
    mov  cx, 65531              ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    mov  cx, 4                  ; vr3
    cwd                         ; vr4
    idiv cx                     ; vr4
    ;                           ; vr4
    cmp  ax, 65533              ; vr4
    jne  failure                ; vr4

;         65532    (vr1)
;     idiv    (vr2)
;         60    (vr0)
; idiv    (vr4)
;     65476    (vr3)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 60                 ; vr0
    mov  cx, 65532              ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    mov  cx, 65476              ; vr3
    xchg ax, cx                 ; vr4
    cwd                         ; vr4
    idiv cx                     ; vr4
    ;                           ; vr4
    cmp  ax, 4                  ; vr4
    jne  failure                ; vr4

;             2    (vr1)
;         idiv    (vr2)
;             10    (vr0)
;     idiv    (vr4)
;         30    (vr3)
; idiv    (vr6)
;     210    (vr5)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 10                 ; vr0
    mov  cx, 2                  ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    mov  cx, 30                 ; vr3
    xchg ax, cx                 ; vr4
    cwd                         ; vr4
    idiv cx                     ; vr4
    mov  cx, 210                ; vr5
    xchg ax, cx                 ; vr6
    cwd                         ; vr6
    idiv cx                     ; vr6
    ;                           ; vr6
    cmp  ax, 35                 ; vr6
    jne  failure                ; vr6

;     3    (vr5)
; idiv    (vr6)
;         5    (vr3)
;     idiv    (vr4)
;             7    (vr1)
;         idiv    (vr2)
;             65326    (vr0)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 65326              ; vr0
    mov  cx, 7                  ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    mov  cx, 5                  ; vr3
    cwd                         ; vr4
    idiv cx                     ; vr4
    mov  cx, 3                  ; vr5
    cwd                         ; vr6
    idiv cx                     ; vr6
    ;                           ; vr6
    cmp  ax, 65534              ; vr6
    jne  failure                ; vr6

;             11    (vr11)
;         idiv    (vr12)
;             22    (vr10)
;     add     (vr13)
;             3    (vr8)
;         idiv    (vr9)
;             6    (vr7)
; idiv    (vr14)
;             3    (vr4)
;         idiv    (vr5)
;             15    (vr3)
;     add     (vr6)
;             2    (vr1)
;         idiv    (vr2)
;             14    (vr0)
; ----
; Regs needed (approximately): 5
; --------
    ;                           ; vr0
    mov  ax, 14                 ; vr0
    mov  cx, 2                  ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    mov  cx, 15                 ; vr3
    mov  bx, 3                  ; vr4
    xchg ax, cx                 ; vr5
    cwd                         ; vr5
    idiv bx                     ; vr5
    add  ax, cx                 ; vr6
    mov  cx, 6                  ; vr7
    mov  bx, 3                  ; vr8
    xchg ax, cx                 ; vr9
    cwd                         ; vr9
    idiv bx                     ; vr9
    mov  dx, 22                 ; vr10
    mov  bx, 11                 ; vr11
    xchg ax, dx                 ; vr12
    mov  si, dx                 ; vr12
    cwd                         ; vr12
    idiv bx                     ; vr12
    add  si, ax                 ; vr13
    mov  ax, cx                 ; vr14
    cwd                         ; vr14
    idiv si                     ; vr14
    ;                           ; vr14
    cmp  ax, 3                  ; vr14
    jne  failure                ; vr14

;         2    (vr0)
;     shl     (vr2)
;         65535    (vr1)
; idiv    (vr4)
;     12    (vr3)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  cx, 2                  ; vr0
    mov  bx, 65535              ; vr1
    shl  bx, cl                 ; vr2
    mov  ax, 12                 ; vr3
    cwd                         ; vr4
    idiv bx                     ; vr4
    ;                           ; vr4
    cmp  ax, 65533              ; vr4
    jne  failure                ; vr4

;     10    (vr3)
; shl     (vr4)
;         3    (vr1)
;     idiv    (vr2)
;         6    (vr0)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 6                  ; vr0
    mov  cx, 3                  ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    mov  cx, 10                 ; vr3
    shl  ax, cl                 ; vr4
    ;                           ; vr4
    cmp  ax, 2048               ; vr4
    jne  failure                ; vr4

;         65529    (vr1)
;     idiv    (vr2)
;         65501    (vr0)
; shl     (vr4)
;     2    (vr3)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 65501              ; vr0
    mov  cx, 65529              ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    mov  dx, 2                  ; vr3
    mov  cx, ax                 ; vr4
    shl  dx, cl                 ; vr4
    ;                           ; vr4
    cmp  dx, 64                 ; vr4
    jne  failure                ; vr4

;         4    (vr1)
;     idiv    (vr2)
;         8    (vr0)
; shl     (vr6)
;         3    (vr4)
;     idiv    (vr5)
;         9    (vr3)
; ----
; Regs needed (approximately): 4
; --------
    ;                           ; vr0
    mov  ax, 8                  ; vr0
    mov  cx, 4                  ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    mov  cx, 9                  ; vr3
    mov  bx, 3                  ; vr4
    xchg ax, cx                 ; vr5
    cwd                         ; vr5
    idiv bx                     ; vr5
    shl  ax, cl                 ; vr6
    ;                           ; vr6
    cmp  ax, 12                 ; vr6
    jne  failure                ; vr6

;         3    (vr3)
;     shl     (vr5)
;         30    (vr4)
; idiv    (vr6)
;         5    (vr0)
;     shl     (vr2)
;         65506    (vr1)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  cx, 5                  ; vr0
    mov  ax, 65506              ; vr1
    shl  ax, cl                 ; vr2
    mov  cx, 3                  ; vr3
    mov  bx, 30                 ; vr4
    shl  bx, cl                 ; vr5
    cwd                         ; vr6
    idiv bx                     ; vr6
    ;                           ; vr6
    cmp  ax, 65532              ; vr6
    jne  failure                ; vr6

;     3    (vr1)
; irem    (vr2)
;     5    (vr0)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 5                  ; vr0
    mov  cx, 3                  ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    ;                           ; vr2
    cmp  dx, 2                  ; vr2
    jne  failure                ; vr2

;     3    (vr1)
; irem    (vr2)
;     65531    (vr0)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 65531              ; vr0
    mov  cx, 3                  ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    ;                           ; vr2
    cmp  dx, 65534              ; vr2
    jne  failure                ; vr2

;     65533    (vr1)
; irem    (vr2)
;     5    (vr0)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 5                  ; vr0
    mov  cx, 65533              ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    ;                           ; vr2
    cmp  dx, 2                  ; vr2
    jne  failure                ; vr2

;     65533    (vr1)
; irem    (vr2)
;     65531    (vr0)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 65531              ; vr0
    mov  cx, 65533              ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    ;                           ; vr2
    cmp  dx, 65534              ; vr2
    jne  failure                ; vr2

;     3    (vr1)
; rem     (vr2)
;     5    (vr0)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 5                  ; vr0
    mov  cx, 3                  ; vr1
    xor  dx, dx                 ; vr2
    div  cx                     ; vr2
    ;                           ; vr2
    cmp  dx, 2                  ; vr2
    jne  failure                ; vr2

;         2    (vr0)
;     shl     (vr2)
;         1    (vr1)
; irem    (vr4)
;     7    (vr3)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  cx, 2                  ; vr0
    mov  bx, 1                  ; vr1
    shl  bx, cl                 ; vr2
    mov  ax, 7                  ; vr3
    cwd                         ; vr4
    idiv bx                     ; vr4
    ;                           ; vr4
    cmp  dx, 3                  ; vr4
    jne  failure                ; vr4

;     3    (vr3)
; shl     (vr4)
;         2    (vr1)
;     irem    (vr2)
;         1    (vr0)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 1                  ; vr0
    mov  cx, 2                  ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    mov  cx, 3                  ; vr3
    shl  dx, cl                 ; vr4
    ;                           ; vr4
    cmp  dx, 8                  ; vr4
    jne  failure                ; vr4

;         2    (vr1)
;     irem    (vr2)
;         1    (vr0)
; shl     (vr4)
;     65533    (vr3)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  ax, 1                  ; vr0
    mov  cx, 2                  ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    mov  ax, 65533              ; vr3
    mov  cx, dx                 ; vr4
    shl  ax, cl                 ; vr4
    ;                           ; vr4
    cmp  ax, 65530              ; vr4
    jne  failure                ; vr4

;         4    (vr1)
;     irem    (vr2)
;         3    (vr0)
; shl     (vr6)
;         2    (vr4)
;     irem    (vr5)
;         1    (vr3)
; ----
; Regs needed (approximately): 4
; --------
    ;                           ; vr0
    mov  ax, 3                  ; vr0
    mov  cx, 4                  ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    mov  ax, 1                  ; vr3
    mov  cx, 2                  ; vr4
    mov  bx, dx                 ; vr5
    cwd                         ; vr5
    idiv cx                     ; vr5
    mov  cx, bx                 ; vr6
    shl  dx, cl                 ; vr6
    ;                           ; vr6
    cmp  dx, 8                  ; vr6
    jne  failure                ; vr6

;         4    (vr3)
;     shl     (vr5)
;         3    (vr4)
; irem    (vr6)
;         2    (vr0)
;     shl     (vr2)
;         1    (vr1)
; ----
; Regs needed (approximately): 3
; --------
    ;                           ; vr0
    mov  cx, 2                  ; vr0
    mov  ax, 1                  ; vr1
    shl  ax, cl                 ; vr2
    mov  cx, 4                  ; vr3
    mov  bx, 3                  ; vr4
    shl  bx, cl                 ; vr5
    cwd                         ; vr6
    idiv bx                     ; vr6
    ;                           ; vr6
    cmp  dx, 4                  ; vr6
    jne  failure                ; vr6

;     lw      (vr2)
;         32768    (vr1)
; add     (vr3)
;     1000    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    mov  word [32768], 65535    ; vr0
    ;                           ; vr0
    mov  ax, 1000               ; vr0
    mov  bx, 32768              ; vr1
    mov  bx, [bx]               ; vr2
    add  ax, bx                 ; vr3
    ;                           ; vr3
    cmp  ax, 999                ; vr3
    jne  failure                ; vr3

;     lw      (vr2)
;         lw      (vr1)
;             32768    (vr0)
; shl     (vr4)
;     123    (vr3)
; ----
; Regs needed (approximately): 2
; --------
    mov  word [32768], 32768    ; vr0
    mov  word [32768], 32768    ; vr0
    ;                           ; vr0
    mov  bx, 32768              ; vr0
    mov  bx, [bx]               ; vr1
    mov  cx, [bx]               ; vr2
    mov  ax, 123                ; vr3
    shl  ax, cl                 ; vr4
    ;                           ; vr4
    cmp  ax, 123                ; vr4
    jne  failure                ; vr4

;     40000    (vr1)
; sw      (vr2)
;     12345    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    ;                           ; vr0
    mov  ax, 12345              ; vr0
    mov  bx, 40000              ; vr1
    mov  [bx], ax               ; vr2
    ;                           ; vr2
    cmp  ax, 12345              ; vr2
    jne  failure                ; vr2
    cmp  word [40000], 12345    ; vr2
    jne  failure                ; vr2

;     40000    (vr2)
; sw      (vr3)
;     lw      (vr1)
;         32768    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    mov  word [32768], 54321    ; vr0
    ;                           ; vr0
    mov  bx, 32768              ; vr0
    mov  bx, [bx]               ; vr1
    mov  si, 40000              ; vr2
    mov  [si], bx               ; vr3
    ;                           ; vr3
    cmp  bx, 54321              ; vr3
    jne  failure                ; vr3
    cmp  word [40000], 54321    ; vr3
    jne  failure                ; vr3

;     40000    (vr4)
; sw      (vr5)
;         32768    (vr2)
;     sw      (vr3)
;         lw      (vr1)
;             50000    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    mov  word [50000], 21930    ; vr0
    ;                           ; vr0
    mov  bx, 50000              ; vr0
    mov  bx, [bx]               ; vr1
    mov  si, 32768              ; vr2
    mov  [si], bx               ; vr3
    mov  si, 40000              ; vr4
    mov  [si], bx               ; vr5
    ;                           ; vr5
    cmp  bx, 21930              ; vr5
    jne  failure                ; vr5
    cmp  word [32768], 21930    ; vr5
    jne  failure                ; vr5
    cmp  word [40000], 21930    ; vr5
    jne  failure                ; vr5

;     lw      (vr3)
;         50000    (vr2)
; mul     (vr4)
;     lw      (vr1)
;         40000    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    mov  word [40000], 65521    ; vr0
    mov  word [50000], 65508    ; vr0
    ;                           ; vr0
    mov  bx, 40000              ; vr0
    mov  ax, [bx]               ; vr1
    mov  bx, 50000              ; vr2
    mov  bx, [bx]               ; vr3
    mul  bx                     ; vr4
    ;                           ; vr4
    cmp  ax, 420                ; vr4
    jne  failure                ; vr4

;     50000    (vr7)
; sw      (vr8)
;         40000    (vr5)
;     sw      (vr6)
;             lw      (vr3)
;                 49152    (vr2)
;         mul     (vr4)
;             lw      (vr1)
;                 32768    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    mov  word [32768], 1000     ; vr0
    mov  word [49152], 65535    ; vr0
    ;                           ; vr0
    mov  bx, 32768              ; vr0
    mov  ax, [bx]               ; vr1
    mov  bx, 49152              ; vr2
    mov  bx, [bx]               ; vr3
    mul  bx                     ; vr4
    mov  bx, 40000              ; vr5
    mov  [bx], ax               ; vr6
    mov  bx, 50000              ; vr7
    mov  [bx], ax               ; vr8
    ;                           ; vr8
    cmp  ax, 64536              ; vr8
    jne  failure                ; vr8
    cmp  word [40000], 64536    ; vr8
    jne  failure                ; vr8
    cmp  word [50000], 64536    ; vr8
    jne  failure                ; vr8

;     40000    (vr5)
; sw      (vr6)
;         lbs     (vr3)
;             49152    (vr2)
;     add     (vr4)
;         lbz     (vr1)
;             32768    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    mov  byte [32768], 255      ; vr0
    mov  byte [49152], 255      ; vr0
    ;                           ; vr0
    mov  bx, 32768              ; vr0
    mov  bl, [bx]               ; vr1
    xor  bh, bh                 ; vr1
    mov  si, 49152              ; vr2
    mov  al, [si]               ; vr3
    cbw                         ; vr3
    add  bx, ax                 ; vr4
    mov  si, 40000              ; vr5
    mov  [si], bx               ; vr6
    ;                           ; vr6
    cmp  bx, 254                ; vr6
    jne  failure                ; vr6
    cmp  word [40000], 254      ; vr6
    jne  failure                ; vr6

;     32768    (vr5)
; sw      (vr6)
;         lbz     (vr3)
;             49152    (vr2)
;     add     (vr4)
;         lbs     (vr1)
;             50000    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    mov  byte [50000], 255      ; vr0
    mov  byte [49152], 255      ; vr0
    ;                           ; vr0
    mov  bx, 50000              ; vr0
    mov  al, [bx]               ; vr1
    cbw                         ; vr1
    mov  bx, 49152              ; vr2
    mov  bl, [bx]               ; vr3
    xor  bh, bh                 ; vr3
    add  ax, bx                 ; vr4
    mov  bx, 32768              ; vr5
    mov  [bx], ax               ; vr6
    ;                           ; vr6
    cmp  ax, 254                ; vr6
    jne  failure                ; vr6
    cmp  word [32768], 254      ; vr6
    jne  failure                ; vr6

;     50000    (vr2)
; sb      (vr3)
;     lbs     (vr1)
;         40000    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    mov  byte [40000], 90       ; vr0
    ;                           ; vr0
    mov  bx, 40000              ; vr0
    mov  al, [bx]               ; vr1
    cbw                         ; vr1
    mov  bx, 50000              ; vr2
    mov  [bx], al               ; vr3
    ;                           ; vr3
    cmp  ax, 90                 ; vr3
    jne  failure                ; vr3
    cmp  byte [50000], 90       ; vr3
    jne  failure                ; vr3

;     49152    (vr2)
; sb      (vr3)
;     lbs     (vr1)
;         32768    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    mov  byte [32768], 165      ; vr0
    ;                           ; vr0
    mov  bx, 32768              ; vr0
    mov  al, [bx]               ; vr1
    cbw                         ; vr1
    mov  bx, 49152              ; vr2
    mov  [bx], al               ; vr3
    ;                           ; vr3
    cmp  ax, 65445              ; vr3
    jne  failure                ; vr3
    cmp  byte [49152], 165      ; vr3
    jne  failure                ; vr3

;     50000    (vr2)
; sb      (vr3)
;     lbz     (vr1)
;         40000    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    mov  byte [40000], 165      ; vr0
    ;                           ; vr0
    mov  bx, 40000              ; vr0
    mov  bl, [bx]               ; vr1
    xor  bh, bh                 ; vr1
    mov  si, 50000              ; vr2
    mov  [si], bl               ; vr3
    ;                           ; vr3
    cmp  bx, 165                ; vr3
    jne  failure                ; vr3
    cmp  byte [50000], 165      ; vr3
    jne  failure                ; vr3

; zext     (vr4)
;         50000    (vr2)
;     sb      (vr3)
;         lb      (vr1)
;             40000    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    mov  byte [40000], 90       ; vr0
    ;                           ; vr0
    mov  bx, 40000              ; vr0
    mov  bl, [bx]               ; vr1
    mov  si, 50000              ; vr2
    mov  [si], bl               ; vr3
    xor  bh, bh                 ; vr4
    ;                           ; vr4
    cmp  bx, 90                 ; vr4
    jne  failure                ; vr4
    cmp  byte [50000], 90       ; vr4
    jne  failure                ; vr4

; sext     (vr4)
;         50000    (vr2)
;     sb      (vr3)
;         lb      (vr1)
;             40000    (vr0)
; ----
; Regs needed (approximately): 2
; --------
    mov  byte [40000], 255      ; vr0
    ;                           ; vr0
    mov  bx, 40000              ; vr0
    mov  al, [bx]               ; vr1
    mov  bx, 50000              ; vr2
    mov  [bx], al               ; vr3
    cbw                         ; vr4
    ;                           ; vr4
    cmp  ax, 65535              ; vr4
    jne  failure                ; vr4
    cmp  byte [50000], 255      ; vr4
    jne  failure                ; vr4

; lw      (vr7)
;             1    (vr0)
;         shl     (vr3)
;             lw      (vr2)
;                 50000    (vr1)
;     add     (vr6)
;         lw      (vr5)
;             32768    (vr4)
; ----
; Regs needed (approximately): 2
; --------
    mov  word [50000], 10       ; vr0
    mov  word [32768], 40000    ; vr0
    mov  word [40020], 55555    ; vr0
    ;                           ; vr0
    mov  cx, 1                  ; vr0
    mov  bx, 50000              ; vr1
    mov  bx, [bx]               ; vr2
    shl  bx, cl                 ; vr3
    mov  si, 32768              ; vr4
    mov  si, [si]               ; vr5
    add  si, bx                 ; vr6
    mov  si, [si]               ; vr7
    ;                           ; vr7
    cmp  si, 55555              ; vr7
    jne  failure                ; vr7

;         1    (vr1)
;     idiv    (vr2)
;         2    (vr0)
; add     (vr9)
;         4    (vr7)
;     shl     (vr8)
;         lbz     (vr6)
;                 0    (vr4)
;             add     (vr5)
;                 32768    (vr3)
; ----
; Regs needed (approximately): 3
; --------
    mov  byte [32768], 10       ; vr0
    ;                           ; vr0
    mov  ax, 2                  ; vr0
    mov  cx, 1                  ; vr1
    cwd                         ; vr2
    idiv cx                     ; vr2
    mov  bx, 32768              ; vr3
    mov  si, 0                  ; vr4
    add  bx, si                 ; vr5
    mov  dl, [bx]               ; vr6
    xor  dh, dh                 ; vr6
    mov  cx, 4                  ; vr7
    shl  dx, cl                 ; vr8
    add  dx, ax                 ; vr9
    ;                           ; vr9
    cmp  dx, 162                ; vr9
    jne  failure                ; vr9

;                 16    (vr26)
;             add     (vr27)
;                 15    (vr25)
;         add     (vr28)
;                 14    (vr23)
;             add     (vr24)
;                 13    (vr22)
;     add     (vr29)
;                 12    (vr19)
;             add     (vr20)
;                 11    (vr18)
;         add     (vr21)
;                 10    (vr16)
;             add     (vr17)
;                 9    (vr15)
; add     (vr30)
;                 8    (vr11)
;             add     (vr12)
;                 7    (vr10)
;         add     (vr13)
;                 6    (vr8)
;             add     (vr9)
;                 5    (vr7)
;     add     (vr14)
;                 4    (vr4)
;             add     (vr5)
;                 3    (vr3)
;         add     (vr6)
;                 2    (vr1)
;             add     (vr2)
;                 1    (vr0)
; ----
; Regs needed (approximately): 5
; --------
    ;                           ; vr0
    mov  ax, 1                  ; vr0
    mov  cx, 2                  ; vr1
    add  ax, cx                 ; vr2
    mov  cx, 3                  ; vr3
    mov  dx, 4                  ; vr4
    add  cx, dx                 ; vr5
    add  ax, cx                 ; vr6
    mov  cx, 5                  ; vr7
    mov  dx, 6                  ; vr8
    add  cx, dx                 ; vr9
    mov  dx, 7                  ; vr10
    mov  bx, 8                  ; vr11
    add  dx, bx                 ; vr12
    add  cx, dx                 ; vr13
    add  ax, cx                 ; vr14
    mov  cx, 9                  ; vr15
    mov  dx, 10                 ; vr16
    add  cx, dx                 ; vr17
    mov  dx, 11                 ; vr18
    mov  bx, 12                 ; vr19
    add  dx, bx                 ; vr20
    add  cx, dx                 ; vr21
    mov  dx, 13                 ; vr22
    mov  bx, 14                 ; vr23
    add  dx, bx                 ; vr24
    mov  bx, 15                 ; vr25
    mov  si, 16                 ; vr26
    add  bx, si                 ; vr27
    add  dx, bx                 ; vr28
    add  cx, dx                 ; vr29
    add  ax, cx                 ; vr30
    ;                           ; vr30
    cmp  ax, 136                ; vr30
    jne  failure                ; vr30

;                     16    (vr57)
;                 add     (vr58)
;                     15    (vr56)
;             add     (vr59)
;                     14    (vr54)
;                 add     (vr55)
;                     13    (vr53)
;         add     (vr60)
;                     12    (vr50)
;                 add     (vr51)
;                     11    (vr49)
;             add     (vr52)
;                     10    (vr47)
;                 add     (vr48)
;                     9    (vr46)
;     add     (vr61)
;                     8    (vr42)
;                 add     (vr43)
;                     7    (vr41)
;             add     (vr44)
;                     6    (vr39)
;                 add     (vr40)
;                     5    (vr38)
;         add     (vr45)
;                     4    (vr35)
;                 add     (vr36)
;                     3    (vr34)
;             add     (vr37)
;                     2    (vr32)
;                 add     (vr33)
;                     1    (vr31)
; add     (vr62)
;                     16    (vr26)
;                 add     (vr27)
;                     15    (vr25)
;             add     (vr28)
;                     14    (vr23)
;                 add     (vr24)
;                     13    (vr22)
;         add     (vr29)
;                     12    (vr19)
;                 add     (vr20)
;                     11    (vr18)
;             add     (vr21)
;                     10    (vr16)
;                 add     (vr17)
;                     9    (vr15)
;     add     (vr30)
;                     8    (vr11)
;                 add     (vr12)
;                     7    (vr10)
;             add     (vr13)
;                     6    (vr8)
;                 add     (vr9)
;                     5    (vr7)
;         add     (vr14)
;                     4    (vr4)
;                 add     (vr5)
;                     3    (vr3)
;             add     (vr6)
;                     2    (vr1)
;                 add     (vr2)
;                     1    (vr0)
; ----
; Regs needed (approximately): 6
; --------
    ;                           ; vr0
    mov  ax, 1                  ; vr0
    mov  cx, 2                  ; vr1
    add  ax, cx                 ; vr2
    mov  cx, 3                  ; vr3
    mov  dx, 4                  ; vr4
    add  cx, dx                 ; vr5
    add  ax, cx                 ; vr6
    mov  cx, 5                  ; vr7
    mov  dx, 6                  ; vr8
    add  cx, dx                 ; vr9
    mov  dx, 7                  ; vr10
    mov  bx, 8                  ; vr11
    add  dx, bx                 ; vr12
    add  cx, dx                 ; vr13
    add  ax, cx                 ; vr14
    mov  cx, 9                  ; vr15
    mov  dx, 10                 ; vr16
    add  cx, dx                 ; vr17
    mov  dx, 11                 ; vr18
    mov  bx, 12                 ; vr19
    add  dx, bx                 ; vr20
    add  cx, dx                 ; vr21
    mov  dx, 13                 ; vr22
    mov  bx, 14                 ; vr23
    add  dx, bx                 ; vr24
    mov  bx, 15                 ; vr25
    mov  si, 16                 ; vr26
    add  bx, si                 ; vr27
    add  dx, bx                 ; vr28
    add  cx, dx                 ; vr29
    add  ax, cx                 ; vr30
    mov  cx, 1                  ; vr31
    mov  dx, 2                  ; vr32
    add  cx, dx                 ; vr33
    mov  dx, 3                  ; vr34
    mov  bx, 4                  ; vr35
    add  dx, bx                 ; vr36
    add  cx, dx                 ; vr37
    mov  dx, 5                  ; vr38
    mov  bx, 6                  ; vr39
    add  dx, bx                 ; vr40
    mov  bx, 7                  ; vr41
    mov  si, 8                  ; vr42
    add  bx, si                 ; vr43
    add  dx, bx                 ; vr44
    add  cx, dx                 ; vr45
    mov  dx, 9                  ; vr46
    mov  bx, 10                 ; vr47
    add  dx, bx                 ; vr48
    mov  bx, 11                 ; vr49
    mov  si, 12                 ; vr50
    add  bx, si                 ; vr51
    add  dx, bx                 ; vr52
    mov  bx, 13                 ; vr53
    mov  si, 14                 ; vr54
    add  bx, si                 ; vr55
    mov  si, 15                 ; vr56
    mov  di, 16                 ; vr57
    add  si, di                 ; vr58
    add  bx, si                 ; vr59
    add  dx, bx                 ; vr60
    add  cx, dx                 ; vr61
    add  ax, cx                 ; vr62
    ;                           ; vr62
    cmp  ax, 272                ; vr62
    jne  failure                ; vr62

;                         16    (vr120)
;                     add     (vr121)
;                         15    (vr119)
;                 add     (vr122)
;                         14    (vr117)
;                     add     (vr118)
;                         13    (vr116)
;             add     (vr123)
;                         12    (vr113)
;                     add     (vr114)
;                         11    (vr112)
;                 add     (vr115)
;                         10    (vr110)
;                     add     (vr111)
;                         9    (vr109)
;         add     (vr124)
;                         8    (vr105)
;                     add     (vr106)
;                         7    (vr104)
;                 add     (vr107)
;                         6    (vr102)
;                     add     (vr103)
;                         5    (vr101)
;             add     (vr108)
;                         4    (vr98)
;                     add     (vr99)
;                         3    (vr97)
;                 add     (vr100)
;                         2    (vr95)
;                     add     (vr96)
;                         1    (vr94)
;     add     (vr125)
;                         16    (vr89)
;                     add     (vr90)
;                         15    (vr88)
;                 add     (vr91)
;                         14    (vr86)
;                     add     (vr87)
;                         13    (vr85)
;             add     (vr92)
;                         12    (vr82)
;                     add     (vr83)
;                         11    (vr81)
;                 add     (vr84)
;                         10    (vr79)
;                     add     (vr80)
;                         9    (vr78)
;         add     (vr93)
;                         8    (vr74)
;                     add     (vr75)
;                         7    (vr73)
;                 add     (vr76)
;                         6    (vr71)
;                     add     (vr72)
;                         5    (vr70)
;             add     (vr77)
;                         4    (vr67)
;                     add     (vr68)
;                         3    (vr66)
;                 add     (vr69)
;                         2    (vr64)
;                     add     (vr65)
;                         1    (vr63)
; add     (vr126)
;                         16    (vr57)
;                     add     (vr58)
;                         15    (vr56)
;                 add     (vr59)
;                         14    (vr54)
;                     add     (vr55)
;                         13    (vr53)
;             add     (vr60)
;                         12    (vr50)
;                     add     (vr51)
;                         11    (vr49)
;                 add     (vr52)
;                         10    (vr47)
;                     add     (vr48)
;                         9    (vr46)
;         add     (vr61)
;                         8    (vr42)
;                     add     (vr43)
;                         7    (vr41)
;                 add     (vr44)
;                         6    (vr39)
;                     add     (vr40)
;                         5    (vr38)
;             add     (vr45)
;                         4    (vr35)
;                     add     (vr36)
;                         3    (vr34)
;                 add     (vr37)
;                         2    (vr32)
;                     add     (vr33)
;                         1    (vr31)
;     add     (vr62)
;                         16    (vr26)
;                     add     (vr27)
;                         15    (vr25)
;                 add     (vr28)
;                         14    (vr23)
;                     add     (vr24)
;                         13    (vr22)
;             add     (vr29)
;                         12    (vr19)
;                     add     (vr20)
;                         11    (vr18)
;                 add     (vr21)
;                         10    (vr16)
;                     add     (vr17)
;                         9    (vr15)
;         add     (vr30)
;                         8    (vr11)
;                     add     (vr12)
;                         7    (vr10)
;                 add     (vr13)
;                         6    (vr8)
;                     add     (vr9)
;                         5    (vr7)
;             add     (vr14)
;                         4    (vr4)
;                     add     (vr5)
;                         3    (vr3)
;                 add     (vr6)
;                         2    (vr1)
;                     add     (vr2)
;                         1    (vr0)
; ----
; Regs needed (approximately): 7
; --------
    ;                           ; vr0
    mov  ax, 1                  ; vr0
    mov  cx, 2                  ; vr1
    add  ax, cx                 ; vr2
    mov  cx, 3                  ; vr3
    mov  dx, 4                  ; vr4
    add  cx, dx                 ; vr5
    add  ax, cx                 ; vr6
    mov  cx, 5                  ; vr7
    mov  dx, 6                  ; vr8
    add  cx, dx                 ; vr9
    mov  dx, 7                  ; vr10
    mov  bx, 8                  ; vr11
    add  dx, bx                 ; vr12
    add  cx, dx                 ; vr13
    add  ax, cx                 ; vr14
    mov  cx, 9                  ; vr15
    mov  dx, 10                 ; vr16
    add  cx, dx                 ; vr17
    mov  dx, 11                 ; vr18
    mov  bx, 12                 ; vr19
    add  dx, bx                 ; vr20
    add  cx, dx                 ; vr21
    mov  dx, 13                 ; vr22
    mov  bx, 14                 ; vr23
    add  dx, bx                 ; vr24
    mov  bx, 15                 ; vr25
    mov  si, 16                 ; vr26
    add  bx, si                 ; vr27
    add  dx, bx                 ; vr28
    add  cx, dx                 ; vr29
    add  ax, cx                 ; vr30
    mov  cx, 1                  ; vr31
    mov  dx, 2                  ; vr32
    add  cx, dx                 ; vr33
    mov  dx, 3                  ; vr34
    mov  bx, 4                  ; vr35
    add  dx, bx                 ; vr36
    add  cx, dx                 ; vr37
    mov  dx, 5                  ; vr38
    mov  bx, 6                  ; vr39
    add  dx, bx                 ; vr40
    mov  bx, 7                  ; vr41
    mov  si, 8                  ; vr42
    add  bx, si                 ; vr43
    add  dx, bx                 ; vr44
    add  cx, dx                 ; vr45
    mov  dx, 9                  ; vr46
    mov  bx, 10                 ; vr47
    add  dx, bx                 ; vr48
    mov  bx, 11                 ; vr49
    mov  si, 12                 ; vr50
    add  bx, si                 ; vr51
    add  dx, bx                 ; vr52
    mov  bx, 13                 ; vr53
    mov  si, 14                 ; vr54
    add  bx, si                 ; vr55
    mov  si, 15                 ; vr56
    mov  di, 16                 ; vr57
    add  si, di                 ; vr58
    add  bx, si                 ; vr59
    add  dx, bx                 ; vr60
    add  cx, dx                 ; vr61
    add  ax, cx                 ; vr62
    mov  cx, 1                  ; vr63
    mov  dx, 2                  ; vr64
    add  cx, dx                 ; vr65
    mov  dx, 3                  ; vr66
    mov  bx, 4                  ; vr67
    add  dx, bx                 ; vr68
    add  cx, dx                 ; vr69
    mov  dx, 5                  ; vr70
    mov  bx, 6                  ; vr71
    add  dx, bx                 ; vr72
    mov  bx, 7                  ; vr73
    mov  si, 8                  ; vr74
    add  bx, si                 ; vr75
    add  dx, bx                 ; vr76
    add  cx, dx                 ; vr77
    mov  dx, 9                  ; vr78
    mov  bx, 10                 ; vr79
    add  dx, bx                 ; vr80
    mov  bx, 11                 ; vr81
    mov  si, 12                 ; vr82
    add  bx, si                 ; vr83
    add  dx, bx                 ; vr84
    mov  bx, 13                 ; vr85
    mov  si, 14                 ; vr86
    add  bx, si                 ; vr87
    mov  si, 15                 ; vr88
    mov  di, 16                 ; vr89
    add  si, di                 ; vr90
    add  bx, si                 ; vr91
    add  dx, bx                 ; vr92
    add  cx, dx                 ; vr93
    mov  dx, 1                  ; vr94
    mov  bx, 2                  ; vr95
    add  dx, bx                 ; vr96
    mov  bx, 3                  ; vr97
    mov  si, 4                  ; vr98
    add  bx, si                 ; vr99
    add  dx, bx                 ; vr100
    mov  bx, 5                  ; vr101
    mov  si, 6                  ; vr102
    add  bx, si                 ; vr103
    mov  si, 7                  ; vr104
    mov  di, 8                  ; vr105
    add  si, di                 ; vr106
    add  bx, si                 ; vr107
    add  dx, bx                 ; vr108
    mov  bx, 9                  ; vr109
    mov  si, 10                 ; vr110
    add  bx, si                 ; vr111
    mov  si, 11                 ; vr112
    mov  di, 12                 ; vr113
    add  si, di                 ; vr114
    add  bx, si                 ; vr115
    mov  si, 13                 ; vr116
    mov  di, 14                 ; vr117
    add  si, di                 ; vr118
    mov  di, 15                 ; vr119
    push ax                     ; vr120
    mov  ax, 16                 ; vr120
    add  di, ax                 ; vr121
    add  si, di                 ; vr122
    add  bx, si                 ; vr123
    add  dx, bx                 ; vr124
    add  cx, dx                 ; vr125
    pop  ax                     ; vr126
    add  ax, cx                 ; vr126
    ;                           ; vr126
    cmp  ax, 544                ; vr126
    jne  failure                ; vr126

;                             16    (vr247)
;                         add     (vr248)
;                             15    (vr246)
;                     add     (vr249)
;                             14    (vr244)
;                         add     (vr245)
;                             13    (vr243)
;                 add     (vr250)
;                             12    (vr240)
;                         add     (vr241)
;                             11    (vr239)
;                     add     (vr242)
;                             10    (vr237)
;                         add     (vr238)
;                             9    (vr236)
;             add     (vr251)
;                             8    (vr232)
;                         add     (vr233)
;                             7    (vr231)
;                     add     (vr234)
;                             6    (vr229)
;                         add     (vr230)
;                             5    (vr228)
;                 add     (vr235)
;                             4    (vr225)
;                         add     (vr226)
;                             3    (vr224)
;                     add     (vr227)
;                             2    (vr222)
;                         add     (vr223)
;                             1    (vr221)
;         add     (vr252)
;                             16    (vr216)
;                         add     (vr217)
;                             15    (vr215)
;                     add     (vr218)
;                             14    (vr213)
;                         add     (vr214)
;                             13    (vr212)
;                 add     (vr219)
;                             12    (vr209)
;                         add     (vr210)
;                             11    (vr208)
;                     add     (vr211)
;                             10    (vr206)
;                         add     (vr207)
;                             9    (vr205)
;             add     (vr220)
;                             8    (vr201)
;                         add     (vr202)
;                             7    (vr200)
;                     add     (vr203)
;                             6    (vr198)
;                         add     (vr199)
;                             5    (vr197)
;                 add     (vr204)
;                             4    (vr194)
;                         add     (vr195)
;                             3    (vr193)
;                     add     (vr196)
;                             2    (vr191)
;                         add     (vr192)
;                             1    (vr190)
;     add     (vr253)
;                             16    (vr184)
;                         add     (vr185)
;                             15    (vr183)
;                     add     (vr186)
;                             14    (vr181)
;                         add     (vr182)
;                             13    (vr180)
;                 add     (vr187)
;                             12    (vr177)
;                         add     (vr178)
;                             11    (vr176)
;                     add     (vr179)
;                             10    (vr174)
;                         add     (vr175)
;                             9    (vr173)
;             add     (vr188)
;                             8    (vr169)
;                         add     (vr170)
;                             7    (vr168)
;                     add     (vr171)
;                             6    (vr166)
;                         add     (vr167)
;                             5    (vr165)
;                 add     (vr172)
;                             4    (vr162)
;                         add     (vr163)
;                             3    (vr161)
;                     add     (vr164)
;                             2    (vr159)
;                         add     (vr160)
;                             1    (vr158)
;         add     (vr189)
;                             16    (vr153)
;                         add     (vr154)
;                             15    (vr152)
;                     add     (vr155)
;                             14    (vr150)
;                         add     (vr151)
;                             13    (vr149)
;                 add     (vr156)
;                             12    (vr146)
;                         add     (vr147)
;                             11    (vr145)
;                     add     (vr148)
;                             10    (vr143)
;                         add     (vr144)
;                             9    (vr142)
;             add     (vr157)
;                             8    (vr138)
;                         add     (vr139)
;                             7    (vr137)
;                     add     (vr140)
;                             6    (vr135)
;                         add     (vr136)
;                             5    (vr134)
;                 add     (vr141)
;                             4    (vr131)
;                         add     (vr132)
;                             3    (vr130)
;                     add     (vr133)
;                             2    (vr128)
;                         add     (vr129)
;                             1    (vr127)
; add     (vr254)
;                             16    (vr120)
;                         add     (vr121)
;                             15    (vr119)
;                     add     (vr122)
;                             14    (vr117)
;                         add     (vr118)
;                             13    (vr116)
;                 add     (vr123)
;                             12    (vr113)
;                         add     (vr114)
;                             11    (vr112)
;                     add     (vr115)
;                             10    (vr110)
;                         add     (vr111)
;                             9    (vr109)
;             add     (vr124)
;                             8    (vr105)
;                         add     (vr106)
;                             7    (vr104)
;                     add     (vr107)
;                             6    (vr102)
;                         add     (vr103)
;                             5    (vr101)
;                 add     (vr108)
;                             4    (vr98)
;                         add     (vr99)
;                             3    (vr97)
;                     add     (vr100)
;                             2    (vr95)
;                         add     (vr96)
;                             1    (vr94)
;         add     (vr125)
;                             16    (vr89)
;                         add     (vr90)
;                             15    (vr88)
;                     add     (vr91)
;                             14    (vr86)
;                         add     (vr87)
;                             13    (vr85)
;                 add     (vr92)
;                             12    (vr82)
;                         add     (vr83)
;                             11    (vr81)
;                     add     (vr84)
;                             10    (vr79)
;                         add     (vr80)
;                             9    (vr78)
;             add     (vr93)
;                             8    (vr74)
;                         add     (vr75)
;                             7    (vr73)
;                     add     (vr76)
;                             6    (vr71)
;                         add     (vr72)
;                             5    (vr70)
;                 add     (vr77)
;                             4    (vr67)
;                         add     (vr68)
;                             3    (vr66)
;                     add     (vr69)
;                             2    (vr64)
;                         add     (vr65)
;                             1    (vr63)
;     add     (vr126)
;                             16    (vr57)
;                         add     (vr58)
;                             15    (vr56)
;                     add     (vr59)
;                             14    (vr54)
;                         add     (vr55)
;                             13    (vr53)
;                 add     (vr60)
;                             12    (vr50)
;                         add     (vr51)
;                             11    (vr49)
;                     add     (vr52)
;                             10    (vr47)
;                         add     (vr48)
;                             9    (vr46)
;             add     (vr61)
;                             8    (vr42)
;                         add     (vr43)
;                             7    (vr41)
;                     add     (vr44)
;                             6    (vr39)
;                         add     (vr40)
;                             5    (vr38)
;                 add     (vr45)
;                             4    (vr35)
;                         add     (vr36)
;                             3    (vr34)
;                     add     (vr37)
;                             2    (vr32)
;                         add     (vr33)
;                             1    (vr31)
;         add     (vr62)
;                             16    (vr26)
;                         add     (vr27)
;                             15    (vr25)
;                     add     (vr28)
;                             14    (vr23)
;                         add     (vr24)
;                             13    (vr22)
;                 add     (vr29)
;                             12    (vr19)
;                         add     (vr20)
;                             11    (vr18)
;                     add     (vr21)
;                             10    (vr16)
;                         add     (vr17)
;                             9    (vr15)
;             add     (vr30)
;                             8    (vr11)
;                         add     (vr12)
;                             7    (vr10)
;                     add     (vr13)
;                             6    (vr8)
;                         add     (vr9)
;                             5    (vr7)
;                 add     (vr14)
;                             4    (vr4)
;                         add     (vr5)
;                             3    (vr3)
;                     add     (vr6)
;                             2    (vr1)
;                         add     (vr2)
;                             1    (vr0)
; ----
; Regs needed (approximately): 8
; --------
    ;                           ; vr0
    mov  ax, 1                  ; vr0
    mov  cx, 2                  ; vr1
    add  ax, cx                 ; vr2
    mov  cx, 3                  ; vr3
    mov  dx, 4                  ; vr4
    add  cx, dx                 ; vr5
    add  ax, cx                 ; vr6
    mov  cx, 5                  ; vr7
    mov  dx, 6                  ; vr8
    add  cx, dx                 ; vr9
    mov  dx, 7                  ; vr10
    mov  bx, 8                  ; vr11
    add  dx, bx                 ; vr12
    add  cx, dx                 ; vr13
    add  ax, cx                 ; vr14
    mov  cx, 9                  ; vr15
    mov  dx, 10                 ; vr16
    add  cx, dx                 ; vr17
    mov  dx, 11                 ; vr18
    mov  bx, 12                 ; vr19
    add  dx, bx                 ; vr20
    add  cx, dx                 ; vr21
    mov  dx, 13                 ; vr22
    mov  bx, 14                 ; vr23
    add  dx, bx                 ; vr24
    mov  bx, 15                 ; vr25
    mov  si, 16                 ; vr26
    add  bx, si                 ; vr27
    add  dx, bx                 ; vr28
    add  cx, dx                 ; vr29
    add  ax, cx                 ; vr30
    mov  cx, 1                  ; vr31
    mov  dx, 2                  ; vr32
    add  cx, dx                 ; vr33
    mov  dx, 3                  ; vr34
    mov  bx, 4                  ; vr35
    add  dx, bx                 ; vr36
    add  cx, dx                 ; vr37
    mov  dx, 5                  ; vr38
    mov  bx, 6                  ; vr39
    add  dx, bx                 ; vr40
    mov  bx, 7                  ; vr41
    mov  si, 8                  ; vr42
    add  bx, si                 ; vr43
    add  dx, bx                 ; vr44
    add  cx, dx                 ; vr45
    mov  dx, 9                  ; vr46
    mov  bx, 10                 ; vr47
    add  dx, bx                 ; vr48
    mov  bx, 11                 ; vr49
    mov  si, 12                 ; vr50
    add  bx, si                 ; vr51
    add  dx, bx                 ; vr52
    mov  bx, 13                 ; vr53
    mov  si, 14                 ; vr54
    add  bx, si                 ; vr55
    mov  si, 15                 ; vr56
    mov  di, 16                 ; vr57
    add  si, di                 ; vr58
    add  bx, si                 ; vr59
    add  dx, bx                 ; vr60
    add  cx, dx                 ; vr61
    add  ax, cx                 ; vr62
    mov  cx, 1                  ; vr63
    mov  dx, 2                  ; vr64
    add  cx, dx                 ; vr65
    mov  dx, 3                  ; vr66
    mov  bx, 4                  ; vr67
    add  dx, bx                 ; vr68
    add  cx, dx                 ; vr69
    mov  dx, 5                  ; vr70
    mov  bx, 6                  ; vr71
    add  dx, bx                 ; vr72
    mov  bx, 7                  ; vr73
    mov  si, 8                  ; vr74
    add  bx, si                 ; vr75
    add  dx, bx                 ; vr76
    add  cx, dx                 ; vr77
    mov  dx, 9                  ; vr78
    mov  bx, 10                 ; vr79
    add  dx, bx                 ; vr80
    mov  bx, 11                 ; vr81
    mov  si, 12                 ; vr82
    add  bx, si                 ; vr83
    add  dx, bx                 ; vr84
    mov  bx, 13                 ; vr85
    mov  si, 14                 ; vr86
    add  bx, si                 ; vr87
    mov  si, 15                 ; vr88
    mov  di, 16                 ; vr89
    add  si, di                 ; vr90
    add  bx, si                 ; vr91
    add  dx, bx                 ; vr92
    add  cx, dx                 ; vr93
    mov  dx, 1                  ; vr94
    mov  bx, 2                  ; vr95
    add  dx, bx                 ; vr96
    mov  bx, 3                  ; vr97
    mov  si, 4                  ; vr98
    add  bx, si                 ; vr99
    add  dx, bx                 ; vr100
    mov  bx, 5                  ; vr101
    mov  si, 6                  ; vr102
    add  bx, si                 ; vr103
    mov  si, 7                  ; vr104
    mov  di, 8                  ; vr105
    add  si, di                 ; vr106
    add  bx, si                 ; vr107
    add  dx, bx                 ; vr108
    mov  bx, 9                  ; vr109
    mov  si, 10                 ; vr110
    add  bx, si                 ; vr111
    mov  si, 11                 ; vr112
    mov  di, 12                 ; vr113
    add  si, di                 ; vr114
    add  bx, si                 ; vr115
    mov  si, 13                 ; vr116
    mov  di, 14                 ; vr117
    add  si, di                 ; vr118
    mov  di, 15                 ; vr119
    push ax                     ; vr120
    mov  ax, 16                 ; vr120
    add  di, ax                 ; vr121
    add  si, di                 ; vr122
    add  bx, si                 ; vr123
    add  dx, bx                 ; vr124
    add  cx, dx                 ; vr125
    pop  ax                     ; vr126
    add  ax, cx                 ; vr126
    mov  cx, 1                  ; vr127
    mov  dx, 2                  ; vr128
    add  cx, dx                 ; vr129
    mov  dx, 3                  ; vr130
    mov  bx, 4                  ; vr131
    add  dx, bx                 ; vr132
    add  cx, dx                 ; vr133
    mov  dx, 5                  ; vr134
    mov  bx, 6                  ; vr135
    add  dx, bx                 ; vr136
    mov  bx, 7                  ; vr137
    mov  si, 8                  ; vr138
    add  bx, si                 ; vr139
    add  dx, bx                 ; vr140
    add  cx, dx                 ; vr141
    mov  dx, 9                  ; vr142
    mov  bx, 10                 ; vr143
    add  dx, bx                 ; vr144
    mov  bx, 11                 ; vr145
    mov  si, 12                 ; vr146
    add  bx, si                 ; vr147
    add  dx, bx                 ; vr148
    mov  bx, 13                 ; vr149
    mov  si, 14                 ; vr150
    add  bx, si                 ; vr151
    mov  si, 15                 ; vr152
    mov  di, 16                 ; vr153
    add  si, di                 ; vr154
    add  bx, si                 ; vr155
    add  dx, bx                 ; vr156
    add  cx, dx                 ; vr157
    mov  dx, 1                  ; vr158
    mov  bx, 2                  ; vr159
    add  dx, bx                 ; vr160
    mov  bx, 3                  ; vr161
    mov  si, 4                  ; vr162
    add  bx, si                 ; vr163
    add  dx, bx                 ; vr164
    mov  bx, 5                  ; vr165
    mov  si, 6                  ; vr166
    add  bx, si                 ; vr167
    mov  si, 7                  ; vr168
    mov  di, 8                  ; vr169
    add  si, di                 ; vr170
    add  bx, si                 ; vr171
    add  dx, bx                 ; vr172
    mov  bx, 9                  ; vr173
    mov  si, 10                 ; vr174
    add  bx, si                 ; vr175
    mov  si, 11                 ; vr176
    mov  di, 12                 ; vr177
    add  si, di                 ; vr178
    add  bx, si                 ; vr179
    mov  si, 13                 ; vr180
    mov  di, 14                 ; vr181
    add  si, di                 ; vr182
    mov  di, 15                 ; vr183
    push ax                     ; vr184
    mov  ax, 16                 ; vr184
    add  di, ax                 ; vr185
    add  si, di                 ; vr186
    add  bx, si                 ; vr187
    add  dx, bx                 ; vr188
    add  cx, dx                 ; vr189
    mov  ax, 1                  ; vr190
    mov  dx, 2                  ; vr191
    add  ax, dx                 ; vr192
    mov  dx, 3                  ; vr193
    mov  bx, 4                  ; vr194
    add  dx, bx                 ; vr195
    add  ax, dx                 ; vr196
    mov  dx, 5                  ; vr197
    mov  bx, 6                  ; vr198
    add  dx, bx                 ; vr199
    mov  bx, 7                  ; vr200
    mov  si, 8                  ; vr201
    add  bx, si                 ; vr202
    add  dx, bx                 ; vr203
    add  ax, dx                 ; vr204
    mov  dx, 9                  ; vr205
    mov  bx, 10                 ; vr206
    add  dx, bx                 ; vr207
    mov  bx, 11                 ; vr208
    mov  si, 12                 ; vr209
    add  bx, si                 ; vr210
    add  dx, bx                 ; vr211
    mov  bx, 13                 ; vr212
    mov  si, 14                 ; vr213
    add  bx, si                 ; vr214
    mov  si, 15                 ; vr215
    mov  di, 16                 ; vr216
    add  si, di                 ; vr217
    add  bx, si                 ; vr218
    add  dx, bx                 ; vr219
    add  ax, dx                 ; vr220
    mov  dx, 1                  ; vr221
    mov  bx, 2                  ; vr222
    add  dx, bx                 ; vr223
    mov  bx, 3                  ; vr224
    mov  si, 4                  ; vr225
    add  bx, si                 ; vr226
    add  dx, bx                 ; vr227
    mov  bx, 5                  ; vr228
    mov  si, 6                  ; vr229
    add  bx, si                 ; vr230
    mov  si, 7                  ; vr231
    mov  di, 8                  ; vr232
    add  si, di                 ; vr233
    add  bx, si                 ; vr234
    add  dx, bx                 ; vr235
    mov  bx, 9                  ; vr236
    mov  si, 10                 ; vr237
    add  bx, si                 ; vr238
    mov  si, 11                 ; vr239
    mov  di, 12                 ; vr240
    add  si, di                 ; vr241
    add  bx, si                 ; vr242
    mov  si, 13                 ; vr243
    mov  di, 14                 ; vr244
    add  si, di                 ; vr245
    mov  di, 15                 ; vr246
    push cx                     ; vr247
    mov  cx, 16                 ; vr247
    add  di, cx                 ; vr248
    add  si, di                 ; vr249
    add  bx, si                 ; vr250
    add  dx, bx                 ; vr251
    add  ax, dx                 ; vr252
    pop  cx                     ; vr253
    add  cx, ax                 ; vr253
    pop  ax                     ; vr254
    add  ax, cx                 ; vr254
    ;                           ; vr254
    cmp  ax, 1088               ; vr254
    jne  failure                ; vr254

    mov  dx, msg_success
    mov  ah, 9
    int  0x21
    mov  ax, 0x4C00
    int  0x21

no_memory:
    mov  dx, msg_memory
    mov  ah, 9
    int  0x21
    mov  ax, 0x4C01
    int  0x21

failure:
    mov  dx, msg_failure
    mov  ah, 9
    int  0x21
    mov  ax, 0x4C01
    int  0x21

msg_success:
    db   "SUCCESS!", 13, 10, "$"

msg_memory:
    db   "OUT OF MEMORY!", 13, 10, "$"

msg_failure:
    db   "FAILURE!", 13, 10, "$"
