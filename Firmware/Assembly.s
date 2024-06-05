main:
        li          sp,     0x3C00
        addi        gp,     sp,     392
loop:
        flw         f1,     0(sp)
        flw         f2,     4(sp)
       
        fmul.s      f10,    f1,     f1
        fmul.s      f20,    f2,     f2
        fadd.s      f30,    f10,    f20
        fsqrt.s     x3,     f30
        fadd.s      f0,     f0,     f3

        addi        sp,     sp,     8
        blt         sp,     gp,     loop
        ebreak
