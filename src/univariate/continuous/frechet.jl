doc"""
    Frechet(α,θ)

The *Fréchet distribution* with shape `α` and scale `θ` has probability density function

$f(x; \alpha, \theta) = \frac{\alpha}{\theta} \left( \frac{x}{\theta} \right)^{-\alpha-1} 
e^{-(x/\theta)^{-\alpha}}, \quad x > 0$
    
```julia
Frechet()        # Fréchet distribution with unit shape and unit scale, i.e. Frechet(1.0, 1.0)
Frechet(a)       # Fréchet distribution with shape a and unit scale, i.e. Frechet(a, 1.0)
Frechet(a, b)    # Fréchet distribution with shape a and scale b

params(d)        # Get the parameters, i.e. (a, b)
shape(d)         # Get the shape parameter, i.e. a
scale(d)         # Get the scale parameter, i.e. b
```

External links

* [Fréchet_distribution on Wikipedia](http://en.wikipedia.org/wiki/Fréchet_distribution)

"""
immutable Frechet <: ContinuousUnivariateDistribution
    α::Float64
    θ::Float64

    function Frechet(α::Real, θ::Real)
    	@check_args(Frechet, α > zero(α) && θ > zero(θ))
    	new(α, θ)
    end
    Frechet(α::Real) = Frechet(α, 1.0)
    Frechet() = new(1.0, 1.0)
end

@distr_support Frechet 0.0 Inf


#### Parameters

shape(d::Frechet) = d.α
scale(d::Frechet) = d.θ
params(d::Frechet) = (d.α, d.θ)


#### Statistics

mean(d::Frechet) = (α = d.α; α > 1.0 ? d.θ * gamma(1.0 - 1.0 / α) : Inf)

median(d::Frechet) = d.θ * logtwo^(-1.0 / d.α)

mode(d::Frechet) = (iα = -1.0/d.α; d.θ * (1.0 - iα) ^ iα)

function var(d::Frechet)
    if d.α > 2.0
        iα = 1.0 / d.α
        return d.θ^2 * (gamma(1.0 - 2.0 * iα) - gamma(1.0 - iα)^2)
    else
        return Inf
    end
end

function skewness(d::Frechet)
    if d.α > 3.0
        iα = 1.0 / d.α
        g1 = gamma(1.0 - iα)
        g2 = gamma(1.0 - 2.0 * iα)
        g3 = gamma(1.0 - 3.0 * iα)
        return (g3 - 3.0 * g2 * g1 + 2 * g1^3) / ((g2 - g1^2)^1.5)
    else
        return Inf
    end
end

function kurtosis(d::Frechet)
    if d.α > 3.0
        iα = 1.0 / d.α
        g1 = gamma(1.0 - iα)
        g2 = gamma(1.0 - 2.0 * iα)
        g3 = gamma(1.0 - 3.0 * iα)
        g4 = gamma(1.0 - 4.0 * iα)
        return (g4 - 4.0 * g3 * g1 + 3 * g2^2) / ((g2 - g1^2)^2) - 6.0
    else
        return Inf
    end
end

function entropy(d::Frechet)
    γ = 0.57721566490153286060  # γ is the Euler-Mascheroni constant
    1.0 + γ / d.α + γ + log(d.θ / d.α)
end


#### Evaluation

function logpdf(d::Frechet, x::Float64)
    (α, θ) = params(d)
    if x > 0.0
        z = θ / x
        return log(α / θ) + (1.0 + α) * log(z) - z^α
    else
        return -Inf
    end
end

pdf(d::Frechet, x::Float64) = exp(logpdf(d, x))

cdf(d::Frechet, x::Float64) = x > 0.0 ? exp(-((d.θ / x) ^ d.α)) : 0.0
ccdf(d::Frechet, x::Float64) = x > 0.0 ? -expm1(-((d.θ / x) ^ d.α)) : 1.0
logcdf(d::Frechet, x::Float64) = x > 0.0 ? -(d.θ / x) ^ d.α : -Inf
logccdf(d::Frechet, x::Float64) = x > 0.0 ? log1mexp(-((d.θ / x) ^ d.α)) : 0.0

quantile(d::Frechet, p::Float64) = d.θ * (-log(p)) ^ (-1.0 / d.α)
cquantile(d::Frechet, p::Float64) = d.θ * (-log1p(-p)) ^ (-1.0 / d.α)
invlogcdf(d::Frechet, lp::Float64) = d.θ * (-lp)^(-1.0 / d.α)
invlogccdf(d::Frechet, lp::Float64) = d.θ * (-log1mexp(lp))^(-1.0 / d.α)

function gradlogpdf(d::Frechet, x::Float64)
    (α, θ) = params(d)
    insupport(Frechet, x) ? -(α + 1.0) / x + α * (θ^α) * x^(-α-1.0)  : 0.0
end

## Sampling

rand(d::Frechet) = d.θ * randexp() ^ (-1.0 / d.α)
