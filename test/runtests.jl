using Assembly
using Test

const routine = @assembly RISCV begin
	addi(t0, zero, 0xf)
	sw(t0, t0, 1)
	lw(t1, t0, 1)
	xor(t2, t1, t0)
end

@testset "reader[1]" begin
	@test string(routine) == """
	addi t0 zero 15
	sw   t0 t0 1
	lw   t1 t0 1
	xor  t2 t1 t0
"""
end

@testset "executor[1]" begin
	M = RISCV.machine(ncells=256)
	exec!(M, routine)
	@test M.pc == 4
	@test M.reg[:zero] == 0
	@test M.reg[:t0] == 15
	@test M.mem == (A = zeros(Int32, 256); A[16] = 15; A)
	@test M.reg[:t0] == M.reg[:t1]
	@test M.reg[:t2] == 0
end


const gaussian = @assembly RISCV begin
	addi(t0, zero, 3)
	add(t1, t1, t0)
	addi(t0, t0, -1)
	bne(t0, zero, -3)
end

@testset "executor[2]" begin
	M = RISCV.machine(ncells=256)
	exec!(M, gaussian)
	@test M.pc == 4
	@test M.reg[:zero] == 0
	@test M.reg[:t0] == 0
	@test M.reg[:t1] == 6
	@test M.mem == zeros(Int32, 256)
end

const labelled = @assembly RISCV begin
	addi(t0, zero, 3)
:loop
	add(t1, t1, t0)
	addi(t0, t0, -1)
	bne(t0, zero, :loop)
end

@testset "reader[3]" begin
	@test string(labelled) == """
	addi t0 zero 3
loop:
	add  t1 t1 t0
	addi t0 t0 -1
	bne  t0 zero :loop
"""
end

@testset "executor[3]" begin
	M = RISCV.machine(ncells=256)
	exec!(M, labelled)
	@test M.pc == 5
	@test M.reg[:zero] == 0
	@test M.reg[:t0] == 0
	@test M.reg[:t1] == 6
	@test M.mem == zeros(Int32, 256)
end
