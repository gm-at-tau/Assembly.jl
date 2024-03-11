using Assembly
using Test

const routine = @assembly RISCV begin
	addi(x1, x0, 0xf)
	sw(x1, x1, 0x1)
	lw(x2, x1, 0x1)
	xor(x3, x2, x1)
end

@testset "reader 1" begin
	@test string(routine) == """
	addi x1 x0 15
	sw   x1 x1 1
	lw   x2 x1 1
	xor  x3 x2 x1
"""
end

@testset "executor 1" begin
	M = RISCV.machine(ncells=256)
	exec!(M, routine)
	@test M.pc == 4
	@test M.reg[:x0] == 0
	@test M.reg[:x1] == 15
	@test M.mem == (A = zeros(UInt32, 256); A[16] = 15; A)
	@test M.reg[:x1] == M.reg[:x2]
	@test M.reg[:x3] == 0
end


const counter = @assembly RISCV begin
	addi(x1, x0, 3)
	add(x2, x2, x1)
	addi(x1, x1, -1)
	bne(x1, x0, -3)
end

@testset "executor 2" begin
	M = RISCV.machine(ncells=256)
	exec!(M, counter)
	@test M.pc == 4
	@test M.reg[:x0] == 0
	@test M.reg[:x1] == 0
	@test M.reg[:x2] == 6
	@test M.mem == zeros(UInt32, 256)
end
