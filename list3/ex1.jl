#=
    Aproximation algorithm for general assignment problem using LP relaxation
    Author: Michal Kukowski
    email: michalkukowski10@gmail.com

    LICENCE: GPL 3.0
=#

using JuMP
using GLPKMathProgInterface

function solve_gap(job_time :: Matrix{Int}, # time for jth job on ith machine
                   job_cost :: Matrix{Int}, # cost / profit for jth job on ith machine
                   jobs :: Vector{Int}, # jobs not assignment yet to final solution
                   machines :: Vector{Int}, # machines not assignment yet to final solution
                   machine_max_work_time :: Vector{Int}, # Max work time for jobs for each machine
                   graph :: Matrix{Int}) # graph in incident matrix

    local model :: Model
    local m :: Int # machines
    local n :: Int # jobs
    local epsilon :: Float64

    (m, n) = size(job_time)

    model = Model(solver = GLPKSolverLP())

    # x [i,j] - machine ith doing job jth (only x[i,j] part of job)
    @variable(model, x[1:m, 1:n] >= 0)

    # In this case we have profit, so maximize it
    @objective(model, Max, sum(x[i, j] * job_cost[i, j] * graph[i, j] for i = 1:m, j = 1:n))

    # We can do exacly 100% of each job
    epsilon = eps(Float64)
    for j in 1:n
        if jobs[j] == 1
            @constraint(model, sum(x[i, j] * graph[i, j] for i = 1:m) <= 1 + epsilon)
            @constraint(model, sum(x[i, j] * graph[i, j] for i = 1:m) >= 1 - epsilon)
        end
    end

    # Machine can works only for maxTime
    for i in 1:m
        if machines[i] == 1
            @constraint(model, sum(x[i, j] * job_time[i, j] * graph[i, j] for j = 1:n) <= machine_max_work_time[i])
        end
    end

    status = solve(model, suppress_warnings = true)
    if status == :Optimal
        return status, getobjectivevalue(model), getvalue(x)
    else
        return status, nothing, nothing
    end
end

function aprox(job_time :: Matrix{Int}, # time for jth job on ith machine
               job_cost :: Matrix{Int}, # cost / profit for jth job on ith machine
               jobs :: Vector{Int}, # jobs not assignment yet to final solution
               machines :: Vector{Int}, # machines not assignment yet to final solution
               machine_max_work_time :: Vector{Int}, # Max work time for jobs for each machine
               graph :: Matrix{Int}) # graph in incident matrix


    local m :: Int # machines
    local n :: Int # jobs
    local epsilon :: Float64
    local machine_max_time_in_work_copy :: Vector{Int}
    local final_graph :: Matrix{Int}
    local deleted :: Bool

    # stats
    local final_cost :: Int
    local final_time :: Int
    local opt_time :: Int
    local time_ratio :: Float64

    (m, n) = size(job_time)

    # We need to change values, so lets copy vector
    machine_max_time_in_work_copy = copy(machine_max_work_time)

    epsilon = 0.0001;

    # Start with empty graph
    final_graph = Matrix{Int}(m, n)
    final_graph[1:m, 1:n] = 0

    while sum(jobs[j] for j = 1:n) > 0
        (status, fval, x) = solve_gap(job_time, job_cost, jobs, machines, machine_max_work_time, graph)
        deleted = false
        for i in 1:m
            for j in 1:n
                # remove all edge, such that x[i,j] == 0
                if graph[i, j] == 1 && x[i, j] <= epsilon # == 0
                    graph[i, j] = 0
                    deleted = true
                end
            end
        end

        # if job is completed, remove job and edge from work graph, but ofc add to final graph
        for i in 1:m
            for j in 1:n
                if deleted == false && graph[i, j] == 1 && (x[i, j] <= 1 + epsilon) && (x[i, j] >= 1 - epsilon) # == 1
                    final_graph[i, j] = 1
                    jobs[j] = 0
                    machine_max_work_time[i] = machine_max_work_time[i] - job_time[i, j]
                    deleted = true
                    graph[i, j] = 0
                end
            end
        end

        if deleted == false
            for i in 1:m
                # remove machine such that degree == 1
                if deleted == false && sum(graph[i, j] * machines[i] for j = 1:n) == 1
                    machines[i] = 0
                    deleted = true
                end

                # remove machine that job is finished and has degree == 2
                if deleted == false && sum(graph[i, j] * machines[i] for j = 1:n) == 2 && sum(x[i, j] * jobs[j] for j = 1:n) >= 1 - epsilon # >= 1
                    machines[i] = 0
                    deleted = true
                end
            end
        end
    end

    final_cost = sum(final_graph[i, j] * job_cost[i, j] for i = 1:m, j = 1:n)
    final_time =  sum(final_graph[i, j] * job_time[i, j] for i = 1:m, j = 1:n)
    opt_time = sum(machine_max_time_in_work_copy[i] for i = 1:m)
    time_ratio = sum(machine_max_time_in_work_copy[i] - machine_max_work_time[i] for i = 1:m) / sum(machine_max_time_in_work_copy[i] for i = 1:m)
    #println(opt_time, "\t", final_time)
    println(final_cost)
    #println(time_ratio)
    time_ratio
end

function Experiment()
    local files :: Int
    local prefix :: String
    local name :: String
    local tests :: Int

    local job_cost :: Matrix{Int}
    local job_time :: Matrix{Int}
    local machine_max_work_time :: Vector{Int}
    local jobs :: Vector{Int}
    local machines :: Vector{Int}
    local graph :: Matrix{Int}

    files = 12
    prefix = "./data/gap"
    overAllTimeRatio = 0;

    # for each file DO
    for file = 1:files
        name = prefix * string(file) * ".txt" # string concat
        #print(file, " ")
        f = open(name, "r")
        line = readline(f)
        tests = parse(Int, line)

        # Get size of problem
        for i in 1:tests
            print((file - 1) * tests + i, "\t")
            line = readline(f)
            m, n = split(line, " ")
            m = parse(Int, m)
            n = parse(Int, n)

            job_cost = Matrix{Int}(m, n)
            job_time = Matrix{Int}(m, n)
            machine_max_work_time = Vector{Int}(m)

            # Get job cost
            for j in 1:m
                line = readline(f);
                splitted = split(line, " ")
                for k in 1:n
                    job_cost[j, k] = parse(Int, splitted[k])
                end
            end

            # Get job time
            for j in 1:m
                line = readline(f);
                splitted = split(line, " ")
                for k in 1:n
                    job_time[j, k] = parse(splitted[k])
                end
            end

            # Get machine max work time
            line = readline(f);
            splitted = split(line, " ")
            for k in 1:m
                machine_max_work_time[k] = parse(splitted[k])
            end

            # All jobs need to be done
            jobs = Vector{Int}(n)
            jobs[1:n] = 1

            # enable all machines
            machines = Vector{Int}(m)
            machines[1:m] = 1

            # Construct all possible combination machine --> job
            graph = Matrix{Int}(m, n)
            graph[1:m, 1:n] = 1

            for i in 1:m
                for j in 1:n
                    if job_time[i, j] > machine_max_work_time[i]
                        graph[i][j] = 0
                    end
                end
            end

        # Finally aprox problem
        timeRatio = aprox(job_time, job_cost, jobs, machines, machine_max_work_time, graph)
        overAllTimeRatio += timeRatio
        end
    close(f)
    end

#println("overAllTimeRatio: ", overAllTimeRatio / 60)
end

# MAIN

# file name hardcoded in experiment
Experiment()
