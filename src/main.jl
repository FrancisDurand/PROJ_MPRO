include("io.jl")
include("dualisation.jl")
include("plans_coupants.jl")

# Récupérer les données de l'instance
instance = "20_USA-road-d.BAY.gr"
file_name = "../data/" * instance
n, s, t, S, d1, d2, p, ph, d, D = read_instance(file_name)

# Resolution par dualisation
isOptimal, x, resolutionTime = dualisation(n, s, t, S, d1, d2, p, ph, d, D)
save_solution(isOptimal, x, resolutionTime, "dualisation", instance, s)

# Resolution par plan_coupants