using BioXMLSciMLTest
using Test

@testset "BioXMLSciMLTest.jl" begin
    # @requires Distributed = "8ba89e20-285c-5b6f-9357-94700520ee1b" 
    @testset "cellml" begin include("cellml.jl") end 
end
