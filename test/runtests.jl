using Assembly
using Test

const routine = @assembly RISCV begin
	addi(x1, x0, 0xf)
	sw(x1, x1, 0x1)
	lw(x2, x1, 0x1)
	xor(x3, x2, x1)
end


@testset "reader" begin
	@test string(routine) == """
	addi x1 x0 15
	sw   x1 x1 1
	lw   x2 x1 1
	xor  x3 x2 x1
"""
end

@testset "executor" begin
	M = Machine(mem=zeros(256),
		reg=Dict(:x0 => 0, :x1 => 0, :x2 => 0, :x3 => 0))
	exec!(M, routine)
	@test M.reg[:x0] == 0
	@test M.reg[:x1] == 15
	@test M.mem == (A = zeros(256); A[16] = 15; A)
	@test M.reg[:x1] == M.reg[:x2]
	@test M.reg[:x3] == 0
end
