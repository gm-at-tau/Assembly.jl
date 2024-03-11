module Assembly

export @assembly, exec!, Machine

Base.@kwdef struct Machine
        reg::Dict{Symbol,UInt32}
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
		new(e.args[1], Tuple((a isa Integer) ? UInt32(a) : a for a = argument))
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
        for insn = r.insn
                exec!(M, insn)
        end
end

function exec!(M::Machine, insn::Insn)
        local fn = getproperty(RISCV, insn.mnemonic)
        fn(M, insn.argument...)
end

export RISCV

include("RISCV.jl")

end
