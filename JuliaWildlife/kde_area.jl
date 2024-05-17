#=
A function that calculates the area of a kernel density estimate home range
of a specified percent. The inputs are a dataframe with at least an x
(easting coordinates) and y (northing coordinates) columns, the percent level
of the home range, and an optional n value. The x and y coordinates must be in
a coordinate reference system in meters (e.g., UTM's) for the output to be in 
square meters.

Written by: Seth Rankins
Email for questions: srankins@uwyo.edu
Date: 5/15/2024
Depends on: Dataframes, Statistics, Distributions, Interpolations
Suggests: QueryVerse
=#
#############################################################################
# Load packages (install if needed, example below)
# import Pkg; Pkg.add("DataFrames")
using Statistics, Distributions, Interpolations, DataFrames, QueryVerse

# Load data in (this is one way to do so, but requires QueryVerse)
# Change filepath and file name to the desired location
df = DataFrame(load("mydata.csv"))

# Create function
function kde_area(df, percent, n = 25)
    
    function bandwidth_nrd(x)
        r = quantile(x, [0.25, 0.75])
        h = (r[2] - r[1])/1.34
        4*1.06*min(sqrt(var(x)), h) * length(x)^(-1/5)
    end

    nx = length(df.x)
    x_range = extrema(df.x)
    y_range = extrema(df.y)
    gx = [x_range[1]:((x_range[2] - x_range[1])/(n - 1)):x_range[2];]
    gy = [y_range[1]:((y_range[2] - y_range[1])/(n - 1)):y_range[2];]

    h = [bandwidth_nrd(df.x), bandwidth_nrd(df.y)]

    h = h/4
    ax = (gx .- df.x')/h[1]
    ay = (gy .- df.y')/h[2]
    z = pdf(Normal(0, 1), ax)*transpose(pdf(Normal(0, 1), ay))/(nx*h[1]*h[2])

    dx = diff(gx[1:2])
    dy = diff(gy[1:2])
    sz = sort(vec(z))
    c1 = cumsum(sz) .* dx .* dy

    interp_linear = linear_interpolation(c1, sz)
    level = interp_linear((1-prob))

    xm = (x_range[2] - x_range[1])/n
    ym = (y_range[2] - y_range[1])/n
    cf = xm*ym
    length(filter(>=(level), z))*cf
    
end

# run function to get area
kde_area(df, 0.95, 100)