module Assembly

export @assembly, exec!, Machine

function _asmodule(mod::Symbol, fn::Symbol)
	eval(quote $mod.$fn end)
end

Base.@kwdef struct Machine
	reg::Dict{Symbol, UInt}
	mem::Vector{UInt}
end

const Insn = Pair{Symbol, Tuple}

struct Routine
	insn::Vector{Insn}
end

function Base.print(io::IO, r::Routine)
	for (mnemonic, ops) = r.insn
		print(io, '\t')
		print(io, rpad(mnemonic, 4))
		for o = ops
			print(io, ' ')
			print(io, o)
		end
		print(io, '\n')
	end
end

function _insn(e::Expr)
	@assert e.head == :call
	e.args[1] => Tuple(@view e.args[2:end])
end

macro assembly(_Arch, block::Expr)
	@assert block.head == :block
	Routine([_insn(a) for a = block.args if a isa Expr])
end

function exec!(M::Machine, r::Routine)
	for insn = r.insn
		exec!(M, insn)
	end
end

function exec!(M::Machine, insn::Insn)
	_asmodule(:RISCV, insn[1])(M, insn[2]...)
end

export RISCV

include("RISCV.jl")

end
