include("io.jl")
include("pb_statique.jl")
include("dualisation.jl")
include("plans_coupants.jl")
include("branch_and_cut.jl")
include("heuristique.jl")

# Récupérer les données de l'instance
<<<<<<< HEAD
instance = "100_USA-road-d.COL.gr"
=======
instance = "40_USA-road-d.BAY.gr"
>>>>>>> 7d9c777eff2d8ade31718399857d4fb812ff4869
file_name = "data/" * instance
n, s, t, S, d1, d2, p, ph, d, D = read_instance(file_name)

# Problème statique
isOptimal, x, resolutionTime = pb_statique(n, s, t, S, p, d)
save_solution(isOptimal, x, resolutionTime, "statique", instance, s)

# Resolution par dualisation
isOptimal, x, resolutionTime = dualisation(n, s, t, S, d1, d2, p, ph, d, D)
save_solution(isOptimal, x, resolutionTime, "dualisation", instance, s)

# Resolution par plan_coupants
isOptimal, x, resolutionTime = plan_coupants(n, s, t, S, d1, d2, p, ph, d, D)
save_solution(isOptimal, x, resolutionTime, "plans_coupants", instance, s)

# Résolution par branch-and-cut
isOptimal, x, resolutionTime = branch_and_cut(n, s, t, S, d1, d2, p, ph, d, D)
save_solution(isOptimal, x, resolutionTime, "branch_and_cut", instance, s)

# Résolution par heuristique
# isOptimal, path, resolutionTime = heuristique(n, s, t, S, p, d)
# save_solution_heuristique(isOptimal, path, resolutionTime, instance)

# Diagramme de performances
performanceDiagram()