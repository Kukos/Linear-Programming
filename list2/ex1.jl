#=
    Ex1:

    We have list of servers (1 .. n) and list of info (1 .. m)
    has[i, j] --> server 'j' has info 'i'
    time[j] --> time to read all info from server 'j'

    We need minimaize time for read all info (1 .. m)

    Author: Michal Kukowski
    email: michalkukowski10@gmail.com

    LICENCE: GPL3.0
=#

using JuMP
using GLPKMathProgInterface

function solve_problem(has :: Matrix{Int}, time :: Vector{Int})

    local servers :: Int
    local infos :: Int
    local model :: Model

    (infos,servers) = size(has)
    model = Model(solver = GLPKSolverMIP())

    @variable(model, read[1:servers], Bin)
    @objective(model, Min, sum(read[j] * time[j] for j = 1:servers))

    for i in 1:infos
        @constraint(model, sum(has[i,j] * read[j] for j = 1:servers) >= 1)
    end

	status = solve(model, suppress_warnings = true)

	if status == :Optimal
		 return status, getobjectivevalue(model), getvalue(read)
	else
		return status, nothing, nothing
	end
end

# main
local time :: Vector{Int}
local q :: Matrix{Int}

time = [4, 3, 2, 1, 5, 6, 3]
q = [1 0 0 0 1 1 0;
     0 1 0 0 1 0 1;
     0 0 1 0 0 1 0;
     0 0 0 1 0 0 1]

(status, val, choose) = solve_problem(q, time);
if status == :Optimal
    println("Time: ", val);
    println("Choose: ", choose);
else
    println("Status: ", status);
end
