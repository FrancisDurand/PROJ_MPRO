include("io.jl")
include("pb_statique.jl")
include("dualisation.jl")
include("plans_coupants.jl")
include("branch_and_cut.jl")
include("heuristique.jl")

# Récupérer les données de l'instance
instance = "20_USA-road-d.COL.gr"
file_name = "data/" * instance
n, s, t, S, d1, d2, p, ph, d, D = read_instance(file_name)

#definition d'une durée maximum d'execution (en secondes)
temps_max = 100.0

# Problème statique
isOptimal, x, obj, resolutionTime = pb_statique(n, s, t, S, p, d, temps_max)
save_solution(isOptimal, x, obj, resolutionTime,  "statique", instance, s, n)

# Resolution par dualisation
isOptimal, x, obj, resolutionTime = dualisation(n, s, t, S, d1, d2, p, ph, d, D, temps_max)
save_solution(isOptimal, x, obj, resolutionTime, "dualisation", instance, s, n)

# Resolution par plan_coupants
solved, x, obj, resolutionTime = plan_coupants(n, s, t, S, d1, d2, p, ph, d, D, temps_max)
save_solution(solved, x, obj, resolutionTime, "plans_coupants", instance, s, n)

# Résolution par branch-and-cut
solved, x, obj, resolutionTime = branch_and_cut(n, s, t, S, d1, d2, p, ph, d, D, temps_max)
save_solution(solved, x, obj, resolutionTime, "branch_and_cut", instance, s, n)

# Résolution du problème statique par heuristique
solved, path, obj, resolutionTime = heuristique_statique(n, s, t, S, p, d)
save_solution_heuristique_statique(solved, path, obj, resolutionTime, instance)

# Résolution du problème robuste par heuristique
solved, path, obj, resolutionTime = heuristique(n, s, t, S, d1, d2, p, ph, d, D)
save_solution_heuristique(solved, path, obj, resolutionTime, instance)


# Diagramme de performances
performanceDiagram()

# Tableau de resultats
resultsArray()