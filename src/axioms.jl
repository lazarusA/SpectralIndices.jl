#=
struct SpectralIndices{T <: Dict{String, AbstractSpectralIndex}, O}
    indices::T
    origin::O
end
=#

function spectral_indices(indices_dict::Dict{String, Any}; origin="SpectralIndices")
    indices = Dict{String, AbstractSpectralIndex}()
    for (key, value) in indices_dict
        indices[key] = SpectralIndex(value)
    end
    return indices
end

## SpectralIndex
struct SpectralIndex{S<:String,B,D<:Date,P} <: AbstractSpectralIndex
    short_name::S
    long_name::S
    bands::B
    application_domain::S
    reference::S
    formula::S
    date_of_addition::D
    contributor::S
    platforms::P
end

"""
    SpectralIndex(index::Dict{String, Any})

This object allows interaction with specific Spectral Indices in the
Awesome Spectral Indices list. Attributes of the Spectral Index can be accessed
and the index itself can be computed.

# Arguments
- `index::Dict{String, Any}`: A dictionary with the following keys:
    - `"short_name"`: Short name of the spectral index.
    - `"long_name"`: Long name or description of the spectral index.
    - `"bands"`: List of bands or wavelengths used in the index calculation.
    - `"application_domain"`: Application domain or use case of the spectral index.
    - `"reference"`: Reference or source of the spectral index formula.
    - `"formula"`: Mathematical formula of the spectral index.
    - `"date_of_addition"`: Date when the spectral index was added (in "yyyy-mm-dd" format).
    - `"contributor"`: Contributor or source of the spectral index information.
    - `"platforms"`: Platforms or sensors for which the index is applicable.

# Returns
A `SpectralIndex` object containing the specified index information.

# Examples
```julia
index_dict = Dict(
    "short_name" => "NDVI",
    "long_name" => "Normalized Difference Vegetation Index",
    "bands" => ["Red", "NIR"],
    "application_domain" => "Vegetation monitoring",
    "reference" => "Rouse et al. (1973)",
    "formula" => "(NIR - Red) / (NIR + Red)",
    "date_of_addition" => "2022-01-15",
    "contributor" => "John Doe",
    "platforms" => ["Landsat 8", "Sentinel-2A"]
)

index = SpectralIndex(index_dict)
'''
Or, accessing directly the provided Dict of spectral indices:
'''julia
julia> indices["NIRv"]
```
```
NIRv: Near-Infrared Reflectance of Vegetation
Application domain: vegetation
Bands/Parameters: Any["N", "R"]
Formula: ((N-R)/(N+R))*N
Reference: https://doi.org/10.1126/sciadv.1602244
```
'''julia
julia> indices["NIRv"].contributor
```
```
"https://github.com/davemlz"
```
"""
function SpectralIndex(index::Dict)
    short_name = index["short_name"]
    long_name = index["long_name"]
    bands = index["bands"]
    application_domain = index["application_domain"]
    reference = index["reference"]
    formula = filter(x -> !isspace(x), index["formula"])
    date_of_addition = Date(index["date_of_addition"], dateformat"y-m-d")
    contributor = index["contributor"]
    platforms = index["platforms"]

    SpectralIndex(short_name, long_name, bands, application_domain, reference,
                  formula, date_of_addition, contributor, platforms)
end

function Base.show(io::IO, index::SpectralIndex)
    println(io, index.short_name, ": ", index.long_name)
    println(io, "Application domain: ", index.application_domain)
    println(io, "Bands/Parameters: ", index.bands)
    println(io, "Formula: ", index.formula)
    println(io, "Reference: ", index.reference)
end

#function compute(si::AbstractSpectralIndex, params=nothing; kwargs...)
#    params == nothing ? parameters = kwargs : parameters = params
#    return compute_index(si.short_name; parameters...)
#end

function compute(self::SpectralIndex, params::Dict{String, Any}=Dict(); kwargs...)
    if isempty(params)
        parameters = kwargs
    else
        parameters = params
    end

    return computeIndex(self.short_name; parameters...)
end

function _create_indices(
    online::Bool = false
)
    indices = _get_indices(online)
    return spectral_indices(indices)
end

struct PlatformBand{S<:String,W<:Number,B<:Number} <: AbstractPlatformBand
    platform::S
    band::S
    name::S
    wavelength::W
    bandwidth::B
end

"""
    PlatformBand(platform_band::Dict{String, Any})

This struct provides information about a specific band for a specific sensor or
platform.

# Arguments
- `platform_band::Dict{String, Any}`: A dictionary with the following keys:
    - `"platform"`: Name of the platform or sensor.
    - `"band"`: Band number or name for the specific platform.
    - `"name"`: Description or name of the band for the specific platform.
    - `"wavelength"`: Center wavelength of the band (in nm) for the specific platform.
    - `"bandwidth"`: Bandwidth of the band (in nm) for the specific platform.

# Returns
A `PlatformBand` object containing the specified band information.

# Examples
```julia
platform_band_dict = Dict(
    "platform" => "Sentinel-2A",
    "band" => "B2",
    "name" => "Blue",
    "wavelength" => 492.4,
    "bandwidth" => 66.0
)

platform_band = PlatformBand(platform_band_dict)
```
Or, accessing directly the provided Dict of platforms:
'''julia
julia> bands["B"].platforms["sentinel2a"]
```
```
PlatformBand(Platform: Sentinel-2A, Band: Blue)
* Band: B2
* Center Wavelength (nm): 492.4
* Bandwidth (nm): 66.0
```
```julia
julia> bands["B"].platforms["sentinel2a"].wavelength
```
```
492.4
```
"""
function PlatformBand(platform_band::Dict)
    platform = platform_band["platform"]
    band = platform_band["band"]
    name = platform_band["name"]
    wavelength = platform_band["wavelength"]
    bandwidth = platform_band["bandwidth"]
    return PlatformBand(platform, band, name, wavelength, bandwidth)
end

Base.show(io::IO, pb::PlatformBand) = begin
    println(io, "PlatformBand(Platform: $(pb.platform), Band: $(pb.name))")
    println(io, "* Band: $(pb.band)")
    println(io, "* Center Wavelength (nm): $(pb.wavelength)")
    println(io, "* Bandwidth (nm): $(pb.bandwidth)")
end

Base.show(io::IO, mime::MIME{Symbol("text/plain")}, pb::PlatformBand) = Base.show(io, pb)

function Base.show(io::IO, mime::MIME{Symbol("text/html")}, pb::PlatformBand)
    println(io, "<div style=\"background-color:#F9F9F9; padding:10px;\">")
    println(io, "<strong>Platform:</strong> $(pb.platform), <strong>Band:</strong> $(pb.name)<br>")
    println(io, "<strong>Band:</strong> $(pb.band)<br>")
    println(io, "<strong>Center Wavelength (nm):</strong> $(pb.wavelength)<br>")
    println(io, "<strong>Bandwidth (nm):</strong> $(pb.bandwidth)<br>")
    println(io, "</div>")
end

struct Band{S<:String,F<:Number,P<:Dict{String, PlatformBand}}
    short_name::S
    long_name::S
    common_name::S
    min_wavelength::F
    max_wavelength::F
    platforms::P
end

"""
    Band(band::Dict{String, Any})

Constructs a `Band` object to interact with specific bands in the list of required bands for Spectral Indices in the Awesome Spectral Indices list.

# Arguments
- `band::Dict{String, Any}`: A dictionary containing band information with the following keys:
    - `"short_name"`: Short name of the band.
    - `"long_name"`: Description or name of the band.
    - `"common_name"`: Common name of the band according to the Electro-Optical Extension Specification for STAC.
    - `"min_wavelength"`: Minimum wavelength of the spectral range of the band (in nm).
    - `"max_wavelength"`: Maximum wavelength of the spectral range of the band (in nm).
    - `"platforms"`: A dictionary of platform information associated with this band.

# Returns
A `Band` object representing the specified band.

# Examples
```julia
band_dict = Dict{String, Any}(
    "short_name" => "B",
    "long_name" => "Blue",
    "common_name" => "Blue",
    "min_wavelength" => 450.0,
    "max_wavelength" => 495.0,
    "platforms" => Dict{String, Any}(
        "sentinel2a" => PlatformBand(...),  # PlatformBand constructor details here
        "sentinel2b" => PlatformBand(...),  # PlatformBand constructor details here
        # Add other platforms as needed
    )
)

band = Band(band_dict)
'''
Or, using the provided bands
```julia
```
julia> bands["B"]
```
Band(B: Blue)
```
```julia
```
julia> bands["B"].long_name
```
"Blue"
```
"""
function Band(band::Dict{String, Any})
    short_name = band["short_name"]
    long_name = band["long_name"]
    common_name = band["common_name"]
    min_wavelength = band["min_wavelength"]
    max_wavelength = band["max_wavelength"]
    
    platforms = Dict{String, PlatformBand}()
    
    for (platform, platform_info) in band["platforms"]
        platforms[platform] = PlatformBand(platform_info)
    end

    return Band(short_name, long_name, common_name, min_wavelength, max_wavelength, platforms)
end

Base.show(io::IO, b::Band) = begin
    println(io, "Band($(b.short_name): $(b.long_name))")
end

Base.show(io::IO, mime::MIME{Symbol("text/plain")}, b::Band) = Base.show(io, b)

Base.show(io::IO, mime::MIME{Symbol("text/html")}, b::Band) = begin
    println(io, "<div style=\"background-color:#F9F9F9; padding:10px;\">")
    println(io, "<strong>Band:</strong> $(b.short_name): $(b.long_name)<br>")
    println(io, "<strong>Common Name:</strong> $(b.common_name)<br>")
    println(io, "<strong>Min Wavelength (nm):</strong> $(b.min_wavelength)<br>")
    println(io, "<strong>Max Wavelength (nm):</strong> $(b.max_wavelength)<br>")
    println(io, "</div>")
end

function _create_bands()
    bands_dict = _load_json("bands.json")
    bands_class = Dict{String, Band}()

    for (key, value) in bands_dict
        bands_class[key] = Band(value)
    end

    return bands_class
end

bands = _create_bands()

struct Constant{S<:String,D,V}
    description::S
    long_name::S
    short_name::S
    standard::S
    default::D
    value::V
end

function Constant(constant::Dict{String, Any})
    description = constant["description"]
    short_name = constant["short_name"]
    default = constant["default"]

    return Constant(description, description, short_name, short_name, default, default)
end

Base.show(io::IO, c::Constant) = print(io, "Constant($(c.short_name): $(c.long_name))\n  * Default value: $(c.default)")

function _create_constants()
    constants = _load_json("constants.json")
    constants_class = Dict{String, Constant}()

    for (key, value) in constants
        constants_class[key] = Constant(value)
    end

    return constants_class
end

constants = _create_constants()