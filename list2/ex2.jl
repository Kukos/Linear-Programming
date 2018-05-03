#=
    Ex2:

    We have lists of functions I i=1:m and subprograms P[i,j] --> subprogram j for function i, j= 1:n
    Each subprogram requires mem[i,j] memory and time[i,j] time

    We need compute program P (with functions I) using subprograms on copmuter with memory M with minimum time

    Author: Michal Kukowski
    email: michalkukowski10@gmail.com

    LICENCE: GPL3.0
=#

using JuMP
using GLPKMathProgInterface

function solve_problem(functions :: Vector{Int}, time :: Matrix{Int}, mem :: Matrix{Int}, M :: Int)

    local functions_num :: Int
    local subprograms_for_function_num :: Int
    local model :: Model

    (functions_num, subprograms_for_function_num) = size(time)
    model = Model(solver = GLPKSolverMIP())

    @variable(model, choose[1:functions_num, 1:subprograms_for_function_num], Bin)
    @objective(model, Min, sum(choose[i, j] * time[i, j] for i = 1:functions_num, j = 1:subprograms_for_function_num))

    # Calculate every functions from vector
    for i in 1:functions_num
        @constraint(model, sum(choose[i, j] for j = 1:subprograms_for_function_num) == functions[i])
    end

    # Memory Constraint
    @constraint(model, sum(choose[i,j] * mem[i,j] for i = 1:functions_num, j = 1:subprograms_for_function_num) <= M)

	status = solve(model, suppress_warnings = true)

	if status == :Optimal
		 return status, getobjectivevalue(model), getvalue(choose)
	else
		return status, nothing, nothing
	end
end


# Main

local functions :: Vector{Int}
local time :: Matrix{Int}
local mem :: Matrix{Int}
local M :: Int

M = 16
functions = [1, 1, 0, 1]
time = [1 2 16;
        1 5 6;
        1 2 10;
        2 4 11]
mem = [8 4 1;
       9 6 4
       10 9 6
       6 4 2]

(status, val, choose) = solve_problem(functions, time, mem, M);
if status == :Optimal
    println("Time: ", val);
    println("Choose: ", choose);
else
    println("Status: ", status);
end



