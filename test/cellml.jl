using BioXMLSciMLTest, CellMLModelRepository

# sbml_test_suite()
fns = get_sbml_suite_fns()
fns = readdir(joinpath(@__DIR__, "../data/cellml_models/"))
# @show fns
@test !isempty(fns)

files_to_sciml(fns; pmap=true)
df = results_df()
