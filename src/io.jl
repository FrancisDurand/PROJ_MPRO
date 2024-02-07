using Plots

inf = 99999999999

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
- method : dualisation, plans_coupants ou branch_and_cut
- instance : nom de l'instance
- s : sommet d'origine
"""

function save_solution(isOptimal, x, resolutionTime, method, instance, s)
    # if isOptimal
        chemin = []
        for i in 1:n
            for j in 1:n
                if value(x[i, j]) >= 0.999
                    push!(chemin, (i, j))
                end
            end
        end

        output_file = "res/" * method * "/" * instance
        fout = open(output_file, "w")
        
        print(fout, "[")
        index = findfirst(arc -> arc[1] == s, chemin)
        for i in 1:length(chemin)
            print(fout, chemin[index][1], ", ")
            if i == length(chemin)
                println(fout,chemin[index][2], "]")
            end
            index = findfirst(arc -> arc[1] == chemin[index][2], chemin)
        end
    # end    
    println(fout, "solveTime = ", resolutionTime) 
    println(fout, "isOptimal = ", isOptimal)
    close(fout)
end


"""
Écrire une solution donnée par l'heuristique dans un fichier de sortie

Argument
- isOptimal : true si le problème est résolu
- path : vector avec le chemin
- resolutionTime : temps de résolution en secondes
- instance : nom de l'instance
"""
function save_solution_heuristique(isOptimal, path, resolutionTime, instance)
    if isOptimal
        output_file = "res/" * "heuristique" * "/" * instance
        fout = open(output_file, "w")
        println(fout, path)
    end
    println(fout, "solveTime = ", resolutionTime) 
    println(fout, "isOptimal = ", isOptimal)
    close(fout)
end


"""
Créer un fichier contenant un diagramme de performances associé aux résultats du dossier /res
Affichez une courbe pour chaque sous-dossier du dossier /res.

Conditions préalables:
- Chaque sous-dossier doit contenir des fichiers .gr
- Chaque fichier .gr correspond à la résolution d'une instance
- Chaque fichier .gr contient une variable "solveTime" et une variable "isOptimal"
"""

function performanceDiagram()
    resultFolder = "res/"
    maxSize = 0 # nb max de fichiers dans un sous-dossier
    subfolderCount = 0 # nb de sous-dossiers

    folderName = Array{String, 1}()
    # Pour chaque fichier dans resultFolder
    for file in readdir(resultFolder)
        path = resultFolder * file
        # S'il s'agit d'un sous-dossier
        if isdir(path)
            folderName = vcat(folderName, file)
            subfolderCount += 1
            folderSize = size(readdir(path), 1)
            if maxSize < folderSize
                maxSize = folderSize
            end
        end
    end

    # Tableau qui contiendra les temps de résolution (une ligne pour chaque sous-dossier)
    results = fill(Inf, subfolderCount, maxSize)

    folderCount = 0
    maxSolveTime = 0

    # Pour chaque sous-dossier
    for folder in folderName
        path = joinpath(resultFolder, folder)
        folderCount += 1
        fileCount = 0
        
        # Pour chaque fichier dans le sous-dossier
        for resultFile in readdir(path)
            fileCount += 1
            include("../" * path * "/" * resultFile) # J'ai des bugs que je ne comprendspas avec cette ligne donc je ne teste pas le diagramme
            if isOptimal
                results[folderCount, fileCount] = solveTime
                if solveTime > maxSolveTime
                    maxSolveTime = solveTime
                end
            end
        end
    end

    results = sort(results, dims=2)
    # print(maxSolveTime)

    # Pour chaque ligne
    for dim in 1: size(results, 1)
        x = Array{Float64, 1}()
        y = Array{Float64, 1}()

        # coordonnée x du point d'inflexion précédent
        previousX = 0
        previousY = 0

        append!(x, previousX)
        append!(y, previousY)
            
        # Position actuelle dans la ligne
        currentId = 1

        # Alors que la fin de la ligne n'est pas atteinte
        while currentId != size(results, 2) && results[dim, currentId] != Inf
            # Nombre d'éléments qui ont la valeur previousX
            identicalValues = 1
            
            # Alors que la valeur est la même
            while results[dim, currentId] == previousX && currentId <= size(results, 2)
                currentId += 1
                identicalValues += 1
            end

            append!(x, previousX)
            append!(y, currentId - 1)

            if results[dim, currentId] != Inf
                append!(x, results[dim, currentId])
                append!(y, currentId - 1)
            end
            
            previousX = results[dim, currentId]
            previousY = currentId - 1  
        end

        append!(x, maxSolveTime)
        append!(y, currentId - 1)

        # Si c'est le premier sous-dossier
        if dim == 1
            plot(x, y, label = folderName[dim], legend = :bottomright, xaxis = "Time (s)", yaxis = "Solved instances",linewidth=3)

        else
            savefig(plot!(x, y, label = folderName[dim], linewidth=3), "performance_diagram")
        end 
    end
end 