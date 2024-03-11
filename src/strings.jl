function Base.print(io::IO, r::Routine)
        for insn = r.insn
		print(io, insn)
                if insn isa Symbol
			print(io, ':')
                end
                print(io, '\n')
        end
end

function Base.print(io::IO, insn::Insn)
        print(io, '\t')
        print(io, rpad(insn.mnemonic, 4))
        for arg = insn.argument
                print(io, ' ')
                print(io, arg)
        end
end

_error_message(::Type, failing::Vector) =
        join(_error_message.(Type, failing), "\n")

_error_message(::Type, failing) =
        "Found `$failing` of type `$(typeof(failing))`."

