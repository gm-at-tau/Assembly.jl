module RISCV

using ..Assembly

const registers = Tuple[
	(:x0, :zero), (:x1, :ra), (:x2, :sp),
	(:x3, :gp), (:x4, :tp),
	(:x5, :t0), (:x6, :t1), (:x7, :t2),
	(:x8, :fp, :s0), (:x9, :s1),
	(:x10, :a0), (:x11, :a1), (:x12, :a2), (:x13, :a3),
	(:x14, :a4), (:x15, :a5), (:x16, :a6), (:x17, :a7),
	(:x18, :s2), (:x19, :s3), (:x20, :s4), (:x21, :s5),
	(:x22, :s6), (:x23, :s7), (:x24, :s8), (:x25, :s9),
	(:x26, :s10), (:x27, :s11),
	(:x28, :t3), (:x29, :t4), (:x30, :t5), (:x31, :t6),
]

machine(;ncells::Int=1<<24) =
	Machine(pc=0, mem=zeros(Assembly.Cell, ncells),
	reg=Register([Tuple(r) => Assembly.Cell(0) for r = registers]))

# R-type
add(M::Machine, rd, rs, rt) = (M.reg[rd] = M.reg[rs] + M.reg[rt])
sub(M::Machine, rd, rs, rt) = (M.reg[rd] = M.reg[rs] - M.reg[rt])
slt(M::Machine, rd, rs, rt) = (M.reg[rd] = M.reg[rs] < M.reg[rt])
xor(M::Machine, rd, rs, rt) = (M.reg[rd] = M.reg[rs] ⊻ M.reg[rt])
or(M::Machine, rd, rs, rt)  = (M.reg[rd] = M.reg[rs] | M.reg[rt])
and(M::Machine, rd, rs, rt) = (M.reg[rd] = M.reg[rs] & M.reg[rt])
sll(M::Machine, rd, rs, rt) = (M.reg[rd] = M.reg[rs] << M.reg[rt])
srl(M::Machine, rd, rs, rt) = (M.reg[rd] = UInt(M.reg[rs]) >> M.reg[rt])
sra(M::Machine, rd, rs, rt) = (M.reg[rd] = M.reg[rs] >> M.reg[rt])

# I-type
addi(M::Machine, rd, rs, imm) = (M.reg[rd] = M.reg[rs] + imm)
slti(M::Machine, rd, rs, imm) = (M.reg[rd] = M.reg[rs] < imm)
xori(M::Machine, rd, rs, imm) = (M.reg[rd] = M.reg[rs] ⊻ imm)
ori(M::Machine, rd, rs, imm)  = (M.reg[rd] = M.reg[rs] | imm)
andi(M::Machine, rd, rs, imm) = (M.reg[rd] = M.reg[rs] & imm)
slli(M::Machine, rd, rs, imm) = (M.reg[rd] = M.reg[rs] << imm)
srli(M::Machine, rd, rs, imm) = (M.reg[rd] = UInt(M.reg[rs]) >> imm)
srai(M::Machine, rd, rs, imm) = (M.reg[rd] = M.reg[rs] >> imm)
lw(M::Machine, rd, rs, imm) = (M.reg[rd] = M.mem[M.reg[rs] + imm])
jalr(M::Machine, rd, rs, imm) = (M.reg[rd] = M.pc; M.pc = M.reg[rs] + imm)

# S-type
sw(M::Machine, rd, rs, imm) = (M.mem[M.reg[rs] + imm] = M.reg[rd])

# B-type
beq(M::Machine, rs, rt, imm) = (M.pc += (M.reg[rs] == M.reg[rt]) ? imm : 0)
bne(M::Machine, rs, rt, imm) = (M.pc += (M.reg[rs] != M.reg[rt]) ? imm : 0)
blt(M::Machine, rs, rt, imm) = (M.pc += (M.reg[rs] < M.reg[rt]) ? imm : 0)
bge(M::Machine, rs, rt, imm) = (M.pc += (M.reg[rs] >= M.reg[rt]) ? imm : 0)

# J-type
jal(M::Machine, rd, imm) = (M.reg[rd] = M.pc; M.pc += imm)

end
