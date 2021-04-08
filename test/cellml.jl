using BioXMLSciMLTest, CellMLModelRepository

# sbml_test_suite()
curl_cellml_models()
p = joinpath(@__DIR__, "../data/cellml_models/")
fns = readdir()
# @show fns
@test !isempty(fns)

files_to_sciml(fns; pmap=true)
df = results_df()
