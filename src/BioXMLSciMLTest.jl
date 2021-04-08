module BioXMLSciMLTest

using ModelingToolkit, OrdinaryDiffEq, CSV, DataFrames, Distributed

const cols = [:filename, :to_system, :to_problem, :to_solve, :states, :parameters, :error]
const N = length(cols)

"info on how far the lowering got"
function sciml(fn, f=ODESystem; dir="out")
    row = Vector(undef, N)
    sciml!(row, fn, f) #; dir=dir, write=true)
    row
end

"""this writes a file per row so that I can pmap. 
want to generalize this to use both sbml and cellml

takes a row length(cols) a filename to write the csv to 
and a function `f: filename -> ODESystem`. 

For CellML this would be `x -> ODESystem(CellModel(x), (0, 1.))`

At some point replace to use FileTrees and a pmapreduce or something.

Currently its really dumb. im not trying to make this perfect

tries to lower it to sys, then prob, then sol.
saves the # of states and parameters
stores the error in the last row.
"""
function sciml!(row, fn, f=ODESystem; dir="out", write=true)
    d, file  = splitdir(fn)
    name, ext = splitext(file)
    row[1] = fn
    try
        sys = f(fn)
        row[2] = true
        row[5] = length(states(sys))
        row[6] = length(parameters(sys))
        prob = ODEProblem(sys, Pair[], (0., 1.))
        row[3] = true
        sol = solve(prob, Tsit5())
        row[4] = true
    catch e 
        row[end] = e
    end
    replace!(row, nothing => missing)
    write && CSV.write(joinpath(dir, name * ".csv"), DataFrame(cols .=> row))
    row
end

function scimls!(mat, fns, f=ODESystem; dir="out")
    for i in eachindex(fns)
        # @show i fns[i]
        mat[i, :] = sciml!(mat[i, :], fns[i];dir=dir)
    end
    mat
end

function scimls_pmap!(mat, fns, f=ODESystem; dir="out")
    # mat[:, :] = permutedims(reduce(hcat, @showprogress(pmap(test_cellml!, eachrow(mat), fns))))
    mat[:, :] = permutedims(reduce(hcat, pmap(sciml!, eachrow(mat), fns)))
    nothing
end

function scimls!(mat, fns, f=ODESystem; dir="out")
    # mat[:, :] = permutedims(reduce(hcat, @showprogress(pmap(test_cellml!, eachrow(mat), fns))))
    mat[:, :] = permutedims(reduce(hcat, sciml!, eachrow(mat), fns))
    nothing
end

"creates a df from the created row files,"
function results_df(dir="out/suite/")
    vcat(CSV.read.(readdir(dir;join=true), DataFrame)...) 
end

"
THIS IS THE IMPORTANT FXN IN THE PACKAGE

f: filename -> ODESystem.

idrk how performant it is allocing the mat up front"
function files_to_sciml(fns, f=ODESystem; dir="out", pmap=false)
    mkpath(dir)
    n = length(cols)
    mat = Array{Any,2}(nothing, length(fns), n)
    pmap ? scimls_pmap!(mat, fns, f; dir=dir) : test_scimls!(mat, fns, f; dir=dir)
    nothing
end

export files_to_sciml, results_df, sciml, sciml!

end
