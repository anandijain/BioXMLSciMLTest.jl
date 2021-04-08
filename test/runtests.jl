using BioXMLSciMLTest
using Test

@testset "BioXMLSciMLTest.jl" begin
    @testset "sbml" begin include("sbml.jl") end 
end
