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
