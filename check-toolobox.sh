#!/bin/bash

#vérification de l'existance de toolbox et archive.txt
if ! [ -d .sh-toolbox ]; then
    echo "toolbox inexistant"
    exit 1
else
  
    if ! [ -e .sh-toolbox/archives.txt ];then
        echo "archives inexistant"
        exit 2
    fi
fi

cpt=0
echo " Quel fichier voulez vous choisir "

#on propose la liste des noms des archives disponibles
for i in .sh-toolbox/*; do
	if [ -f $i ];then
		if [ "$i" == ".sh-toolbox/archives.txt" ]; then
			continue
		else
			cpt=$((cpt+1))
			i=$(basename "$i")
			echo "$i ($cpt)"
		fi
	else
		continue
	fi
	
done
#on permet à l'utilisateur de selectioné
read -p "choisissez un numero : " reponse 

cpt=0
for j in .sh-toolbox/*;do
	if [ -f $i ];then
		if [ "$j" == ".sh-toolbox/archives.txt" ]; then
			continue
		else
			cpt=$((cpt+1))
			if [[ $cpt == $reponse  ]];then
				fich=$( basename $j )
				echo "vous avez choisis $fich"
				break
			fi
		fi
	else 
		continue
	fi
	
done

mkdir .sh-toolbox/temp

tar -xzvf ".sh-toolbox/$fich" -C .sh-toolbox/temp/ > output.txt # a apprendre cpour le .tar.gz
#on verifie si la décompression a réussie
if [ $? -ne 0 ];then
	echo "erreur de decompréssage"
	exit 3
fi
#on verifie si le fichier des log existe
if ! [ -f .sh-toolbox/temp/var/log/auth.log ];then
	echo "le fichier des logs est manquant"
	exit 4
fi
#on verifie si le dossier des log est vide
ls .sh-toolbox/temp/var/log > .sh-toolbox/contenu

if ! [ -s .sh-toolbox/contenu ];then
	echo "le dossier de données est vide"
	exit 5
fi
rm .sh-toolbox/contenu
	
Ddate=$( grep "admin" .sh-toolbox/temp/var/log/auth.log | grep -i "Accepted" | tail -n 1 | cut -d' ' -f1-3  ) #on cherche la dernière date de connexion de l'utilisatuer admin
echo "la date et l’heure de la dernière connexion de l’utilisateur « admin » : $Ddate"

Ddate=$(date -d "$Ddate" +%s)

#converstion en seconde pour comparer
mkdir .sh-toolbox/modifié  
mkdir .sh-toolbox/nonmodifié
#on parcoure la liste des fichier décomprésser dans temp qui sont stockées dans output
while read -r line ;do
	if [[ "$line" == "var/log/auth.log" ]];then
		continue
	fi
	nom=$( basename $line )
	nom_unique=$( echo "$line" | tr '/' '_' ) #pour le cas où il y as des fichier de même nom 
	if [ -f .sh-toolbox/temp/${line} ];then
		#extraire la date avec stat puisque ls -l donne la date en format français, different du format dans auth.log
    		datef=$(stat -c %Y .sh-toolbox/temp/${line})
    		
    		if [ "$datef" -gt "$Ddate" ];then
    			echo "le fichier $nom a été modifié"
    			cp .sh-toolbox/temp/${line} .sh-toolbox/modifié/${nom_unique}
    			
    		else
    			echo "le fichier $nom n'est pas modifié"
    			cp .sh-toolbox/temp/${line} .sh-toolbox/nonmodifié/${nom_unique}
    		fi
    		
    	fi
done < output.txt
#vérifier si les dossier sont vide ou pas avant de les parcourire
ls .sh-toolbox/modifié > .sh-toolbox/contenu
if ! [ -s .sh-toolbox/contenu ];then
	echo "aucun fichier modifié"
else
	ls .sh-toolbox/nonmodifié > .sh-toolbox/contenu
	if ! [ -s .sh-toolbox/contenu ];then
		echo "aucun fichier non modifié"
	else
		for i in .sh-toolbox/nonmodifié/*;do
			taille1=$( ls -l $i | tr -s ' ' | cut -d ' ' -f5)
			nom1=$(echo "$i" | cut -d '_' -f3)
			echo "fichier dans nonmodifié : $nom1 de taill : $taille1"
			for j in .sh-toolbox/modifié/*;do
				echo "$j"
				taille2=$( ls -l $j | tr -s ' ' | cut -d ' ' -f5)
				nom2=$(echo "$j" | cut -d '_' -f3)
				echo "fichier dans modifié : $nom2 de taill : $taille2"
				if [[ "$nom1" == "$nom2"  && $taille1 == $taille2 ]];then
					echo "le fichier $nom1 a le même nom et la même taille que $nom2"
				fi
			done
		done
	fi
fi

exit 0
