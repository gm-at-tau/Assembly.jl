module Assembly

export @assembly, exec!, Register, Machine

include("register.jl")

Base.@kwdef mutable struct Machine
	pc::UInt
        reg::Register
        mem::Vector{UInt32}
end

struct Insn
        mnemonic::Symbol
        argument::Tuple

	function Insn(e::Expr)
		@assert e.head == :call
		argument = @view e.args[2:end]
		typed = isa.(argument, Union{Symbol, Integer})
		@assert all(typed) _error_message(Type, argument[.!typed])
		new(e.args[1], Tuple(argument))
	end
end

struct Routine
        insn::Vector{Insn}
end

include("strings.jl")

macro assembly(_Arch, block::Expr)
        @assert block.head == :block
        Routine([Insn(a) for a = block.args if a isa Expr])
end

function exec!(M::Machine, r::Routine)
	while M.pc < length(r.insn)
		exec!(M, r.insn[1+M.pc])
        end
end

function exec!(M::Machine, insn::Insn)
        local fn = getproperty(RISCV, insn.mnemonic)
	M.pc += 0x1
        fn(M, insn.argument...)
end

export RISCV

include("RISCV.jl")

end
