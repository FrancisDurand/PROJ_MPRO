inf = 1000000


"""
Lire une instance

Argument
- file_name : chemin du fichier d'instance

Return
- n : nombre de sommets
- s : sommet d'origine
- t : sommet de destination
- S : limite pour le poids total des sommets le long du chemin
- d1 : limite de l'augmentation totale de la durée des arcs
- d2 : limite de l'augmentation totale des poids du graphe
- p : vecteur de poids associé aux sommets
- ph : vecteur de limite d'augmentation du poids associé aux sommets
- d : matrice de durée de trajet associée aux arcs
- D : matrice de pourcentage maximal par lequel le temps de trajet d'un arc peut être augmenté
"""
function read_instance(file_name)
    file_content = read(file_name, String)

    m = match(r"n = (\d+)", file_content)
    n = parse(Int, m.captures[1])

    m = match(r"s = (\d+)", file_content)
    s = parse(Int, m.captures[1])

    m = match(r"t = (\d+)", file_content)
    t = parse(Int, m.captures[1])

    m = match(r"S = (\d+)", file_content)
    S = parse(Int, m.captures[1])

    m = match(r"d1 = (\d+)", file_content)
    d1 = parse(Int, m.captures[1])

    m = match(r"d2 = (\d+)", file_content)
    d2 = parse(Int, m.captures[1])

    m = match(r"p = \[([^\]]+)\]", file_content)
    p = parse.(Int, split(m.captures[1], ","))

    m = match(r"ph = \[([^\]]+)\]", file_content)
    ph = parse.(Int, split(m.captures[1], ","))

    m = match(r"Mat = \[([^\]]+)\]", file_content)
    matrix_data = [parse.(Float64, split(match, " ")) for match in split(m.captures[1], ";")]

    d = fill(inf, n, n)
    D = fill(inf, n, n)

    for row in matrix_data
        i, j, value1, value2 = round.(Int, row)
        d[i, j] = value1
        D[i, j] = value2
    end

    return n, s, t, S, d1, d2, p, ph, d, D
end


"""
Écrire une solution dans un fichier de sortie

Argument
- isOptimal : true si le problème est résolu de manière optimale
- x : tableau de variables bidimensionnelles tel que x[i, j] = 1 si on passe de i à j
- resolutionTime : temps de résolution en secondes
- method : dualisation, plans_coupants, branch_and_cut ou heuristique
- instance : nom de l'instance
- s : sommet d'origine
"""
function save_solution(isOptimal, x, resolutionTime, method, instance, s)
    if isOptimal
        chemin = []
        for i in 1:n
            for j in 1:n
                if value(x[i, j]) == 1
                    push!(chemin, (i, j))
                end
            end
        end

        output_file = "../res/" * method * "/" * instance
        fout = open(output_file, "w")

        index = findfirst(arc -> arc[1] == s, chemin)
        for i in 1:length(chemin)
            print(fout, chemin[index]," ")
            index = findfirst(arc -> arc[1] == chemin[index][2], chemin)
        end
        println(fout, "")
    end
    println(fout, "solveTime = ", resolutionTime) 
    println(fout, "isOptimal = ", isOptimal)
    close(fout)
end