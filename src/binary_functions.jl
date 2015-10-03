# Binary functions for Nullables ...

# imports
import Base: convert
import Base: +, -, *, /, \, ^, %, &, |, $, >>>, >>, <<, ==, !=, <, <=, >, >=, //,  div, fld, rem, divrem, mod, copysign, flipsign, hypot, ldexp, log, beta, lbeta, airy, airyx, besselj, besseljx, bessely, besselyx, hankelh1, hankelh1x, hankelh2, hankelh2x, besseli, besselix, besselk, besselkx

# Convert to Nullable
function as_nullable{T}(x::T)
  T <: Nullable ? x : Nullable{T}(x)
end

# Convert Any to Nullable
function convert{T}(x::Type{Nullable{T}}, y)
  Nullable{T}(convert(T, y))
end

function convert(x::Type{Nullable}, y)
  X = typeof(y)
  Nullable{X}(y)
end

# Convert Nullable to Nullable
function convert{T <: Nullable, U <: Nullable}(x::Type{T}, y::U)
  X = eltype(T)
  Nullable{X}(convert(X, eltype(y)))
end


# Convert Nullable to Any
function convert{T <: Nullable}(U::Type, y::T)
  convert(U, get(y))
end

# Define binary operators
arith = [:+, :-, :*, :/, :\, :^, :%, ://]
bit = [:&, :|, :$, :>>>, :>>, :<<]
update = [:+=, :-=, :/=, :\=, :%=, :^=, :|=, :>>>=, :>>=, :<<=]
comp = [:(==), :!=, :<, :<=, :>, :>=]
funs = [:div, :fld, :rem, :divrem, :mod, :copysign, :flipsign, :hypot, :ldexp, :log, :beta, :lbeta, :airy, :airyx, :besselj, :besseljx, :bessely, :besselyx, :hankelh1, :hankelh1x, :hankelh2, :hankelh2x, :besseli, :besselix, :besselk, :besselkx]

# Combine to one vector
syms = [arith; bit; update; comp; funs]

# Symbol expression union type
sym_expr = Union{Symbol, Expr}

# Nullable{T} & Nullable{T} family
function exnn{Q<:Union{Symbol, Expr}}(sym::Q)
  quote
    function $sym{T<:Nullable, U<:Nullable}(x::T, y::U)
      try
        ret = $sym(get(x), get(y))
        X = typeof(ret)
        Nullable{X}(ret)
      catch
        Nullable()
      end
    end
  end
end

# For the Nullable{T} & U family
function exnu{Q<:Union{Symbol, Expr}}(sym::Q)
  quote
    function $sym{T<:Nullable, U}(x::T, y::U)
       try
         ret = $sym(get(x), y)
         X = typeof(ret)
         Nullable{X}(ret)
       catch
          Nullable()
       end
    end
  end
end

# For the U & Nullable{T} family
function exun{Q<:Union{Symbol, Expr}}(sym::Q)
  quote
    function $sym{U, T<:Nullable}(x::U, y::T)
      try
        ret = $sym(x, get(y))
        X = typeof(ret)
        Nullable{X}(ret)
      catch
        Nullable()
      end
    end
  end
end

# Source the functions
for i in [exnn, exnu, exun]
  for j in syms
    eval(i(j))
  end
end

