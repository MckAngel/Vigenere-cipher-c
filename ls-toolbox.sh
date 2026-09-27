#!/bin/bash

#verifier l'existance du toolobx/fichier des archives
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

corruption=0
cpt=0
#lire le fichier archives pour afficher
while read -r line; do
	#sauter la première ligne
	if [ $cpt -eq 0 ]; then
		cpt=1
	else
		#stocker les information de chaque archive
		fichier=$(echo "$line" | cut -d ':' -f 1)
	  	dateD=$(echo "$line" | cut -d ':' -f 2)
		mkdir .sh-toolbox/temp

		tar -xzf ".sh-toolbox/$choix" -C .sh-toolbox/temp/ 
			
		LOGIN_DATE=$(grep "Accepted" .sh-toolbox/temp/var/log/auth.log \
					| grep "admin" \
					| tail -n 1 \
					| awk '{print $1, $2, $3, "2025"}')

		echo "Date lisible : $LOGIN_DATE"

		Ddate=$(date -d "$LOGIN_DATE" +%s)

		echo "en seconde : $Ddate"

		for i in $( find .sh-toolbox/temp/data -type f );do
			echo "$i"
			nom=$( basename $i )
			datef=$(stat -c %Y $i)

			if [ "$datef" -ge "$Ddate" ];then
				echo "$i" >> fichier_chiffrés.txt
			else
				echo "$i" >> fichier_sains.txt
			fi
		done
		if ! [ -d tmp ];then
			mkdir tmp/
			touch tmp/KEY
		fi

		while read -r line1; do
			
			name_modif=$( basename $line1)
			taille_modif=$(stat -c%s "$line1")
			
			while read -r line2;do
				
				name_sain=$( basename $line2)
				taille_sain=$(stat -c%s "$line2")
				
				if [[ "$name_modif" == "$name_sain" ]] && [ "$taille_modif" -eq "$taille_sain" ];then
					echo "$name_modif et $name_sain EGALITÉ zozozozzozo"
					base64 -w 0 "$line1" > fich_chiff64
					base64 -w 0 "$line2" > fich_dechiff64
					./findkey fich_dechiff64 fich_chiff64 -o tmp/KEY 
					key=$(head -n1 tmp/KEY)
					break
				fi
			done < fichier_sains.txt
		done < fichier_chiffrés.txt
		if [ -z "$keylisible" ]; then
			keylisible=$( echo "sans clé")
		else
			
			rm fich_chiff64
			rm fich_dechiff64
			keylisible=$(echo "$key" | base64 --decode )
			echo "$keylisible" | awk '{ if ($0 ~ /[^[:print:]]/) exit 1 }' #commande pour vérifier si la clé contient des caractère non imprimables
			exit_code=$?
			echo "la clé en b64: $key"
			echo "la clé est : $keylisible"
			if [ "$exit_code" -eq 1 ];then
				repertoire=$( basename $choix .tar.gz )
				mv tmp/KEY .sh-toolbox/"$repertoire"/KEY
				echo "nom du fichier : $fichier - DATE: $dateD - CLE EN FICHIER: $keylisible"
			else
				echo "nom du fichier : $fichier - DATE: $dateD - CLE: $keylisible"
			fi

		fi
			#cas où un fichier dans archives.txt n'existe pas dans toolbox
		if ! [ -f $fichier ]; then
	  		echo "(ERREUR) le fichier $fichier n'existe pas dans le toolbox"
	  		corruption=1
		fi
	fi
done < archives.txt


#chercher les fichier qui existe dans toolbox mais pas dans archives.txt
cpt=0
for fichier in *; do
	if [ $cpt -eq 0 ]; then
		cpt=1	
	else
	        trouve=0
		while read -r line && [ $trouve -eq 0 ]; do
			nom=$(echo "$fichier")
			fichier2=$(echo "$line" | cut -d ':' -f 1)
			if [[ "$fichier2" == "$nom" ]]; then
				trouve=1
			fi
		done < archives.txt
		if [ "$trouve" -eq 0 ]; then
			echo "(ERREUR) le fichier $fichier n'existe pas dans le fichier toolbox mais est present dans l'archives.txt"
			corruption=1
		fi
	fi
done
#verifier à l'aide de la variable corruption si l'environement est corrompu ou pas
if [ $corruption -eq 0 ];then
	exit 0 #pas corrompu
else 
	exit 3 #corrompu
fi








