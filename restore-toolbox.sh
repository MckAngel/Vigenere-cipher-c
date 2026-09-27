#!/bin/bash

#vérification de l'existance de toolbox et archive.txt
if ! [ -d .sh-toolbox ]; then
    echo "toolbox inexistant"
    exit 1
else
    cd .sh-toolbox
    if ! [ -e archives.txt ];then
        echo "archives inexistant"
        exit 2
    fi
fi

#copier le fichier archive dans temp sans la première ligne 
sed '1d' archives.txt > temp.txt
cpt=1
corruption=0
#parcourir temp tant qu'il n'est pas vide
while [ -s temp.txt ]; do
    cpt=$((cpt+1))
    line=$( head -n 1 temp.txt) #on prend la première ligne
    fichier=$(echo "$line" | cut -d ':' -f 1)
    dateD=$(echo "$line" | cut -d ':' -f 2)
    cle=$(echo "$line" | cut -d ':' -f 3)
    
    if [ -z "$cle" ]; then
        cle="sans clé"
    fi
    echo "nom du fichier : $fichier - DATE: $dateD - CLE: $cle "
    
    if ! [ -f "$fichier" ]; then
    	corruption=1
        echo "(ERREUR) le fichier $fichier n'existe pas dans le toolbox"     
        echo "souhaitez-vous supprimer la ligne du fichier $fichier du fichier archives.txt"
        read -p  "(oui/non) : " reponse
        if [[ "$reponse" == "oui" ]];then
              sed -i "${cpt}d" archives.txt #on efface la ligne cpt dans archive
              nb=$( head -n 1 archives.txt )
              nb=$((nb-1))
              sed -i "1s/.*/$nb/" archives.txt
              cpt=$((cpt-1))
        	
        else 
		echo "supression de ligne du fichier obligatoire"
		sed -i "${cpt}d" archives.txt #on efface la ligne cpt dans archive
		nb=$( head -n 1 archives.txt )
		nb=$((nb-1))
		sed -i "1s/.*/$nb/" archives.txt
		cpt=$((cpt-1))        	
        fi
    fi
    sed -i '1d' temp.txt #on efface la première ligne pour passer au fichier suivant
done
rm temp.txt #effacer temp aprés l'utilisation

#on parcourt tous les fichier dans toolbox puis on teste si le fichier existe dans archive ou pas
for fichier in *; do 
    if [[ "$fichier" == "archives.txt" ]]; then
        continue 
    else

        trouve=0
        while read -r line && [ $trouve -eq 0 ]; do
            #oklm=$(echo "$fichier")
            fichier2=$(echo "$line" | cut -d ':' -f 1)
            if [[ "$fichier2" == "$fichier" ]]; then
                trouve=1
            fi
        done < archives.txt
        if [ "$trouve" -eq 0 ]; then
            corruption=1
            echo "(ERREUR) le fichier $fichier existe dans le dossier toolbox n'est pas present dans l'archives.txt"
            echo "suprrimer ce fichier ? (oui/non)" #on demande à la permission pour chaque modification de l'environnement
            read -r reponse
            if [[ "$reponse" == "oui" ]];then
                  rm $fichier 
            else 
                echo "voulez vous l'ajouter dans l'archives.txt"
                read -r reponse
                
                if [[ "$reponse" == "oui" ]];then
                    #Si le fichier non compressé on ne l'ajoute pas
                    if [[ "$fichier" == *.tar.gz ]]; then
                        nb=$( head -n 1 archives.txt )
                        nb=$((nb+1))
                        sed -i "1s/.*/$nb/" archives.txt
                        nom=$(basename $fichier)
                        dateD=$(date '+%Y-%m-%d')
                        echo "$nom:$dateD:" >> archives.txt
                    else
                    	#si le fichier non compressé on ne l'ajoute pas
                        echo "fichier non compréssé; suppression du fichier $fichier"
                        rm $fichier
                    fi
                else
                     echo "refus d'ajout; suppression du fichier $fichier"
                     rm $fichier
               	fi
            fi
        fi
    fi
done

if [ "$corruption" -eq 0 ];then
	exit 0
else 
	exit 3
fi
