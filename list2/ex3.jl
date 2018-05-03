#=
    Ex3:

    We have k cpus, each cpu have to do some job (each the same job).
    The job is like SC, so only 1 cpu can do the job in 1 time.
    Also Next cpu have to get result from prev, so ith cpu can start job agter i-1 finished

    WE have to minimize time needed to end jobs on every (last has bigger time) cpus

    Author: Michal Kukowski
    email: michalkukowski10@gmail.com

    LICENCE: GPL3.0
=#

using JuMP
using GLPKMathProgInterface

function job_perm_to_array(P :: Matrix{Float64})
    local cpus :: Int
    local jobs :: Int
    local index :: Int
    local A :: Vector{Int}

    (cpus, jobs) = size(P)

    A = Vector{Int}(jobs)
    index = 1

    for i in 1:cpus
        for j in 1:jobs
            if P[i, j] == 1
               A[index] =  j
               index = index + 1
            end
        end
    end
    A
end

function print_job_perm(P :: Matrix{Float64})
    println("JOB Permutation: ", job_perm_to_array(P))
end

function print_jobs(P :: Matrix{Float64}, F :: Matrix{Float64}, T :: Matrix{Int})

    local cpus :: Int
    local jobs :: Int
    local Perm :: Vector{Int}
    local ep :: Int # end point
    local sp :: Int # start point

    (cpus, jobs) = size(F)
    Perm = job_perm_to_array(P)

    for i in 2:cpus
        ep = 0
        for j in 2:jobs
            sp = Int(F[i, j]) - T[i - 1, Perm[j - 1]]
            for k in ep:sp - 1
                print(" ")
            end

            for k in sp:Int(F[i, j]) - 1
                print(Perm[j - 1])
            end

            ep = Int(F[i, j])
        end
    println()
    end
end


function solve_problem(T :: Matrix{Int})

    local cpus :: Int
    local jobs :: Int
    local model :: Model

    (cpus, jobs) = size(T)

    model = Model(solver = GLPKSolverMIP())

    @variable(model, perm[1:jobs, 1:jobs] >= 0, Int) # Permutation for 1st CPU
    @variable(model, finish_time[1:cpus + 1, 1:jobs + 1] >= 0, Int) # finish time for each cpu for each job

    @variable(model, cost >= 0 ,Int)

    # Let perm be the permuation with format i.e 1 0 0
    #                                            0 1 0
    #                                            0 0 1
    # This means first get job 1, then 2 and 3
    for i in 1:jobs
        @constraint(model, sum(perm[i, j] for j = 1:jobs) == 1)
        @constraint(model, sum(perm[j, i] for j = 1:jobs) == 1)
    end

    # First cpu has not prev cpu
    for i in 1:jobs + 1
        @constraint(model, finish_time[1, i] == 0)
    end

    # First job has not prev job
    for i in 1:cpus + 1
        @constraint(model, finish_time[i, 1] == 0)
    end

    for cpu in 2:cpus + 1
        for i in 2:jobs + 1
            # start when prev cpu finish job
            @constraint(model, finish_time[cpu - 1, i] + sum(perm[i - 1, j] * T[cpu - 1, j] for j = 1:jobs) <= finish_time[cpu, i]);

            # Cpu is single thread so start if finish prev job
            @constraint(model, finish_time[cpu, i - 1] + sum(perm[i - 1, j] * T[cpu - 1, j] for j = 1:jobs) <= finish_time[cpu, i]);
        end
    end

     # Minimalize end point of all cpu, so lets end point be the end of last job
    for cpu in 1:cpus + 1
        @constraint(model, finish_time[cpu, jobs + 1] <=cost);
    end

    @objective(model, Min, cost);

    status = solve(model, suppress_warnings=true)

    if status == :Optimal
        return status, getobjectivevalue(model), getvalue(perm), getvalue(finish_time)
    else
        return status, nothing, nothing, nothing
    end
end

# Main
local T :: Matrix{Int}

T = [2 3 10 7;
     4 4 3 8;
	 3 9 2 7;]

(status, t, perm, finish) = solve_problem(T)
if status == :Optimal
    println("Time: ", t)
    print_job_perm(perm)
    print_jobs(perm, finish, T)
else
   println("Status: ", status)
end