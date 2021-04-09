using Distributed 
addprocs(10)
@everywhere using BioXMLSciMLTest, CellMLModelRepository, CellMLToolkit

# curl_cellml_models()
p = joinpath(@__DIR__, "C:/Users/Anand/.julia/dev/CellMLModelRepository/data/cellml_models")
fns = readdir(p;join=true)
# # @show fns
# @test !isempty(fns)


Pkg.add(url="https://github.com/anandijain/BioXMLSciMLTest.jl")
using BioXMLSciMLTest

f(fn) = getsys(CellModel(fn))

sciml(fns[1], f)

files_to_sciml(fns, f; pmap=true)
df = results_df("out/")   
@test df isa DataFrame