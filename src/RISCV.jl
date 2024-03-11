module RISCV

using ..Assembly

machine(;ncells::Int=1<<24) =
	Machine(pc=0, mem=zeros(UInt32, ncells),
		reg=Dict(:x0 => 0, :x1 => 0, :x2 => 0, :x3 => 0))

# R-type
add(M::Machine, rd, rs, rt) = (M.reg[rd] = M.reg[rs] + M.reg[rt])
xor(M::Machine, rd, rs, rt) = (M.reg[rd] = M.reg[rs] ⊻ M.reg[rt])

# I-type
addi(M::Machine, rd, rs, imm) = (M.reg[rd] = M.reg[rs] + imm)
lw(M::Machine, rd, rs, imm) = (M.reg[rd] = M.mem[M.reg[rs] + imm])

# S-type
sw(M::Machine, rd, rs, imm) = (M.mem[M.reg[rs] + imm] = M.reg[rd])

# B-type
beq(M::Machine, rs, rt, imm) = (M.pc += (M.reg[rs] == M.reg[rt]) ? imm : 0x0)
bne(M::Machine, rs, rt, imm) = (M.pc += (M.reg[rs] != M.reg[rt]) ? imm : 0x0)

# J-type
jal(M::Machine, rd, imm) = (M.reg[rd] = M.pc; M.pc += imm)

end
