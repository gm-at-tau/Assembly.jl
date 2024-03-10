module RISCV

using ..Assembly

# R-type
add(M::Machine, rd, rs, rt) = (M.reg[rd] = M.reg[rs] + M.reg[rt])
xor(M::Machine, rd, rs, rt) = (M.reg[rd] = M.reg[rs] ⊻ M.reg[rt])

# I-type
addi(M::Machine, rd, rs, imm) = (M.reg[rd] = M.reg[rs] + imm)
lw(M::Machine, rd, rs, imm) = (M.reg[rd] = M.mem[M.reg[rs] + imm])

# S-type
sw(M::Machine, rd, rs, imm) = (M.mem[M.reg[rs] + imm] = M.reg[rd])

end
