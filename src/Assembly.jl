module Assembly

export @assembly, exec!, Register, Machine

const Cell = Int32

include("register.jl")

Base.@kwdef mutable struct Machine
	pc::Cell
        reg::Register
        mem::Vector{Cell}
end

struct Insn
        mnemonic::Symbol
        argument::Tuple

	function Insn(e::Expr)
		@assert e.head == :call "Not a function call: `$e`."
		argument = @view e.args[2:end]
		typed = isa.(argument, Union{Symbol, Integer, QuoteNode})
		@assert all(typed) _error_message(Type, argument[.!typed])
		new(e.args[1], Tuple(argument))
	end
end

struct Routine
	insn::Vector{Union{Symbol, Insn}}
	labels::Dict{Symbol, Int}
end

include("strings.jl")

macro assembly(_Arch, block::Expr)
	@assert block.head == :block
	local insn = []
	local labels = Dict{Symbol, Int}()
	sizehint!(insn, length(block.args))
	for line = block.args
		if line isa QuoteNode
			push!(insn, line.value)
			labels[line.value] = length(insn)
		elseif line isa Expr
			push!(insn, Insn(line))
		end
	end
	Routine(insn, labels)
end

function exec!(M::Machine, r::Routine; labels=nothing)
	while M.pc < length(r.insn)
		local insn = r.insn[M.pc += 1]
		exec!(M, insn; labels=r.labels)
        end
end

exec!(::Machine, ::Symbol; labels=nothing) = nothing

function exec!(M::Machine, insn::Insn; labels=nothing)
	local fn = getproperty(RISCV, insn.mnemonic)
	fn(M, ((a isa QuoteNode) ? labels[a.value] - M.pc : a
		for a = insn.argument)...)
end

export RISCV

include("RISCV.jl")

end
