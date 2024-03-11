struct Register
	names::Dict{Symbol, Int}
	values::Vector{Int32}

	function Register(aliases::Vector{Pair{T, Int32} where T})
		names = getproperty.(aliases, :first)
		@assert allunique(mapreduce(x -> [x...], append!, names))
		ref = mapreduce(i -> Dict(names[i] .=> i), merge!, eachindex(names))
		new(ref, getproperty.(aliases, :second))
	end
end

Base.getindex(r::Register, name::Symbol) = r.values[r.names[name]]
Base.setindex!(r::Register, i::Integer, name::Symbol) = (r.values[r.names[name]] = i)
