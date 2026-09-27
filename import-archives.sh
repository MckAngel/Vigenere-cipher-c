#!/bin/bash

#vérifier les arguments
if [ $# -eq 0 ]; then
	echo "le nombre d'argument est pas bon"
	exit 0
fi
cpt=0
for arch in $@; do
	cpt=$((cpt+1))
	#on saute l'argument -f en cas de forcage
	if [[ "$arch" == "-f" ]]; then
		continue
	fi 
	#vérification de l'existance de l'archive
	if ! [ -e $arch ];then
		echo "l'archive n'existe pas au chemin passé en parametre"
		exit 2
	else 
		fichier=$(basename $arch)
		#verifier l'existance de toolbox
		if [ -d .sh-toolbox ]; then 
			if [ -f ".sh-toolbox/$fichier" ]; then
				echo "l'archives  existe deja dans le dossier toolbox"
				#cas où l'archive existe déjà mais mais on a tapé -f comme argument
				if [[ "$1" == "-f" ]]; then	
					#shift decaler les arguments
					cp $arch .sh-toolbox/$fichier
					echo "(AVEC FORCAGE) Le contenu du fichier de l'archive a été ecrasé par le fichier $fichier"
					
				else 
					echo "veuillez entrez oui pour écraser l'ancienne version sinon non pour conserver"
					read -r reponse
					if [[ $reponse == "oui" ]]; then
						if  [ -w ".sh-toolbox/archives.txt" ]; then  
							cp $arch .sh-toolbox/$fichier
							echo "Le contenu du fichier de l'archive a été ecrasé par le fichier $fichier"
						else
							echo "vous avez pas les droits pour copier ce document dans "
							exit 4
						fi
					else
						echo "le contenu a pas ete ecrasé "
						
					fi
				fi
						
			else 
				echo "le fichier $fichier n'éxiste pas dans le toolbox"
				if [[ "$fichier" != *.tar.gz ]]; then
					echo "(ERREUR)il n est pas compressé "
					exit 3
				fi
				echo "on le copie à l'interieur "		
				cp "$arch" ".sh-toolbox/"
				echo "fichier copié dans l'archives"
				dateD=$(date '+%Y-%m-%d')
				nb=$(head -n 1 .sh-toolbox/archives.txt)
				nb=$((nb+1))
				sed -i "1s/.*/$nb/" .sh-toolbox/archives.txt
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
						echo "$fichier:$dateD::f" >> archives.txt
					else
						echo "$fichier:$dateD:$keylisible:s" >> archives.txt
					fi

				fi
				

						
			fi
		else 
		 	echo "le dosssier toolbox existe pas"
		 	exit 1
		fi
	 fi
done
exit 0
