#=
A function that calculates the area of a minimum convex polygon home range of 
a specified percent. The inputs are a dataframe with at least an x (easting 
coordinates) and y (northing coordinates) columns, and the percent level of 
the home range. The x and y coordinates must be in a coordinate reference 
system in meters (e.g., UTM's) for the output to be in square meters.

Written by: Seth Rankins
Email for questions: srankins@uwyo.edu
Date: 5/15/2024
Depends on: Dataframes, Statistics, LazySets
Suggests: QueryVerse
=#
#############################################################################
# Load packages (install if needed, example below)
# import Pkg; Pkg.add("DataFrames")
using DataFrames, Statistics, LazySets, QueryVerse

# Load data in (this is one way to do so, but requires QueryVerse)
# Change filepath and file name to the desired location
df = DataFrame(load("mydata.csv"))

# Create function
function mcp_area(df, percent)
    cent = [sum(df.x)/length(df.x), sum(df.y)/length(df.y)]
    df[!, :dist] = sqrt.(((df.x .- cent[1]).^2) .+ ((df.y .- cent[2]).^2))
    quant = quantile(df.dist, percent)
    df = filter(:dist => n -> n <= quant, df)
    df[!, :coords] = collect.(zip(df.x, df.y))
    area(VPolygon(df.coords))
end

# run function to get area
mcp_area(df, 0.95)