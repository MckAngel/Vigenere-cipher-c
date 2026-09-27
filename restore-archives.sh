#!/bin/bash

if [ "$#" -ne 1 ];then
    echo "Usage: $0"
    exit 1
fi
if ! [ -d .sh-toolbox ];then
	echo "toolbox n'existe pas"
	exit 1
fi


sed '1d' .sh-toolbox/archives.txt > tmp.txt

line=$(head -n 1 tmp.txt)
cpt=0
while ! [ -z "$line" ];do
    
    cpt=$((cpt+1))
    echo "$line ($cpt)"
    sed -i '1d' tmp.txt
    line=$(head -n 1 tmp.txt)
done

echo "veuillez choisir l'archive"
read -r reponse
reponse=$((reponse+1))
choix=$( sed -n "${reponse}p" .sh-toolbox/archives.txt | cut -d':' -f1 )
echo "vous avez choisis $choix"
rm tmp.txt


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






if [ -z "$key" ];then
	echo "aucun fichier identique"
	echo "clé introuvable"
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
		sed -i "${reponse}s/^\([^:]*\):\([^:]*\):.*/\1:\2::f/" .sh-toolbox/archives.txt || exit 3
	else
		sed -i "${reponse}s/^\([^:]*\):\([^:]*\):.*/\1:\2:${keylisible}:s/" .sh-toolbox/archives.txt || exit 3
	fi
	

	if ! [ -d "$1" ];then
		mkdir "$1" || exit 2
	fi

	cat fichier_chiffrés.txt > tmp.txt

	line=$( head -n 1 tmp.txt)

	while ! [ -z "$line" ];do
		name=$(basename $line)
		rep=$(basename $(dirname "$line"))	
		base64 -w 0 "$line" > fich64.txt
		./decipher "$key" fich64.txt || exit 4
		base64 -w 0 -d fich64.txt > "$line"

		if [ -f "$1"/"rep"/"$name" ];then
			echo "fichier $name existe déjà voulez vous écraser son contenu"
			read -p "oui/non: " choix
			if [[ "$choix" == "oui" ]];then
				
				if ! [ -d "$1"/"$rep" ];then
					mkdir "$1"/"$rep"
				fi 
				mv "$line" "$1"/"$rep"/"$name"
			else 
				echo "fichier $name non écraser"
			fi
		else 
			echo "$line:$name" >> "$1"/fichier_chemins.txt
			if ! [ -d "$1"/"$rep" ];then
				mkdir "$1"/"$rep"
			fi 
			mv "$line" "$1"/"$rep"/"$name"
		fi
		sed -i '1d' tmp.txt
		line=$( head -n 1 tmp.txt)
	done
	rm tmp.txt
	
fi


rm fichier_sains.txt
rm fichier_chiffrés.txt
./effacer.sh .sh-toolbox/temp

