include("io.jl")
include("dualisation.jl")
include("plans_coupants.jl")
include("branch_and_cut.jl")

# Récupérer les données de l'instance
instance = "100_USA-road-d.COL.gr"
file_name = "data/" * instance
n, s, t, S, d1, d2, p, ph, d, D = read_instance(file_name)

# Resolution par dualisation
isOptimal, x, resolutionTime = dualisation(n, s, t, S, d1, d2, p, ph, d, D)
save_solution(isOptimal, x, resolutionTime, "dualisation", instance, s)

# Resolution par plan_coupants

isOptimal, x, resolutionTime = plan_coupants(n, s, t, S, d1, d2, p, ph, d, D)
save_solution(isOptimal, x, resolutionTime, "plans_coupants", instance, s)

# Résolution par branch-and-cut

isOptimal, x, resolutionTime = branch_and_cut(n, s, t, S, d1, d2, p, ph, d, D)
save_solution(isOptimal, x, resolutionTime, "branch_and_cut", instance, s)

