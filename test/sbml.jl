using BioXMLSciMLTest, SBMLBioModelsRepository

# sbml_test_suite()
fns = get_sbml_suite_fns()
# @show fns
@test !isempty(fns)

files_to_sciml(fns; pmap=true)
df = results_df()
