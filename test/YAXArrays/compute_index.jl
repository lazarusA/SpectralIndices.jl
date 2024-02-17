using Test
using SpectralIndices
using YAXArrays
using DimensionalData
using Random
using Combinatorics
using StatsBase
include("../test_utils.jl")
Random.seed!(17)

xdim = Dim{:x}(range(1, 10, length=10))
ydim = Dim{:x}(range(1, 10, length=15))

@testset "YAXArrays compute_index single index tests: $idx_name" for (idx_name, idx) in indices

    @testset "as Params" begin
        if idx_name == "AVI" || idx_name == "TVI"
            nyx = YAXArray((xdim, ydim), fill(0.2, 10, 15))
            ryx = YAXArray((xdim, ydim), fill(0.1, 10, 15))
            bandsnames = Dim{:Variables}(["N", "R"])
            params = concatenatecubes([nyx, ryx], bandsnames)
        else
            bands_dim = Dim{:Variables}(idx.bands)
            data = cat([fill(rand(), 10, 15, 1) for _ in idx.bands]...; dims=3)
            params = YAXArray((xdim, ydim, bands_dim), data)
        end
        result = compute_index(idx_name, params)
        @test result isa YAXArray
        @test size(result) == (length(xdim), length(ydim))
    end

    @testset "as Kwargs" begin
        if idx_name == "AVI" || idx_name == "TVI"
            nyx = YAXArray((xdim, ydim), fill(0.2, 10, 15))
            ryx = YAXArray((xdim, ydim), fill(0.1, 10, 15))
            bandsnames = Dim{:Variables}(["N", "R"])
            params = concatenatecubes([nyx, ryx], bandsnames)
        else
            bands_dim = Dim{:Variables}(idx.bands)
            data = cat([fill(rand(), 10, 15, 1) for _ in idx.bands]...; dims=3)
            params = YAXArray((xdim, ydim, bands_dim), data)
        end
        result = compute_index(idx_name; convert_to_kwargs(params)...)
        @test result isa YAXArray
        @test size(result) == (length(xdim), length(ydim))
    end
end

msi = custom_key_combinations(indices, 2, 200)

@testset "YAXArrays compute_index multiple indices tests: $idxs" for idxs in msi

    if idxs[1] in ["AVI", "TVI"] && length(idxs) > 1
        for i in 2:length(idxs)
            if !(idxs[i] in ["AVI", "TVI"])
                idxs[1], idxs[i] = idxs[i], idxs[1]
                break
            end
        end
    end

    @testset "as Params" begin
        yaxa_tmp = []
        yaxa_names = String[]

        for idx_name in idxs
            idx = indices[idx_name]
            if idx_name == "AVI" || idx_name == "TVI"
                for band in ["N", "R"]
                    value = band == "N" ? 0.2 : 0.1
                    push!(yaxa_names, string(band))
                    data = fill(value, 10, 15)
                    push!(yaxa_tmp, YAXArray((xdim, ydim), data))
                end
            else
                for band in idx.bands
                    append!(yaxa_names, [string(band)])
                    data = fill(rand(), 10, 15)
                    push!(yaxa_tmp, YAXArray((xdim, ydim), data))
                end
            end
        end
        unique_band_names = unique(yaxa_names)
        unique_yaxas = yaxa_tmp[1:length(unique_band_names)] #sheesh, more elegant pls
        params = concatenatecubes(unique_yaxas, Dim{:Variables}(unique_band_names))
        result = compute_index(idxs, params)
        @test result isa YAXArray
        @test size(result) == (length(xdim), length(ydim), 2)
    end

    @testset "as Kwargs" begin
        yaxa_tmp = []
        yaxa_names = String[]

        for idx_name in idxs
            idx = indices[idx_name]
            if idx_name == "AVI" || idx_name == "TVI"
                for band in ["N", "R"]
                    value = band == "N" ? 0.2 : 0.1
                    push!(yaxa_names, string(band))
                    data = fill(value, 10, 15)
                    push!(yaxa_tmp, YAXArray((xdim, ydim), data))
                end
            else
                for band in idx.bands
                    append!(yaxa_names, [string(band)])
                    data = fill(rand(), 10, 15)
                    push!(yaxa_tmp, YAXArray((xdim, ydim), data))
                end
            end
        end
        unique_band_names = unique(yaxa_names)
        unique_yaxas = yaxa_tmp[1:length(unique_band_names)] #sheesh, more elegant pls
        params = concatenatecubes(unique_yaxas, Dim{:Variables}(unique_band_names))
        result = compute_index(idxs; convert_to_kwargs(params)...)
        @test result isa YAXArray
        @test size(result) == (length(xdim), length(ydim), 2)
    end
end