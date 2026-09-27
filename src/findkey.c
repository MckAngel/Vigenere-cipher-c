#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include "fonction.c"
#define BLOC 254



int main(int argc, char *argv[])
{
    if ((argc != 3) && (argc != 5))
    {
        fprintf(stderr, "Usage: %s <fichier_clair> <fichier_crypter>\n", argv[0]);
        return 1;
    }

    int trouver = 0;
    char *cleFinal = malloc(1);  // Créer une variable locale à la fonction malloc cette variable et realloc après qu'on a le pattern
    if (!cleFinal) {
        perror("malloc cleFinal");
        return 1;
    }
    cleFinal[0] = '\0';

    FILE *f = fopen(argv[1], "r");
    if (!f)
    {
        perror("Erreur fichier clair");
        free(cleFinal);
        return 1;
    }

    FILE *g = fopen(argv[2], "r");
    if (!g)
    {
        perror("Erreur fichier chiffré");
        fclose(f);
        free(cleFinal);
        return 1;
    }

    char **Tableau = malloc(64 * sizeof(char*));
    for (int i = 0; i < 64; i++)
        Tableau[i] = malloc(64);

    iniTableau(Tableau);

    char MEGABUFF[BLOC];
    char MEGABUFF2[BLOC];
    size_t bytes1, bytes2;


    char *final = malloc(1);  // Initialiser final avec un buffer vide
    if (!final) {
        perror("malloc final");
        fclose(f);
        fclose(g);
        free(cleFinal);
        return 1;
    }
    final[0] = '\0';  // La chaîne est vide au départ

    int cpt = 0;
    while (trouver != 1)
    {
        bytes1 = fread(MEGABUFF, 1, BLOC, f);
        bytes2 = fread(MEGABUFF2, 1, BLOC, g);
        
        if (bytes1 == 0 && bytes2 == 0) break;  // Fin des deux fichiers
        
        if (bytes1 != bytes2)
        {
            fprintf(stderr, "Erreur: blocs de tailles différentes !\n");
            break;
        }
        char *res = findkey(MEGABUFF, MEGABUFF2, bytes1, Tableau);
        if (!res)
        {
            fprintf(stderr, "Erreur findkey\n");
            break;
        }

        cpt = strlen(res);
        // Ajouter au tableau final
        char *tmp = realloc(final, strlen(final) + cpt + 1);  // +1 pour '\0'
        if (!tmp)
        {
            perror("realloc final");
            free(final);
            free(res);
            exit(1);
        }
        final = tmp;

        strncat(final, res, cpt);  // Ajouter la nouvelle clé trouvée à final
        free(res);  // Libérer la mémoire de la clé temporaire
        trouver = find_key(final, &cleFinal);
    }
 // mode de stockage 
    if ( argc == 3) // affiche sur la sortie 
    {
        int taille = strlen(cleFinal);
        if ( (taille % 4) != 0 )
        {
            int padding = (4 - (taille % 4)) % 4;
            char *temp = realloc ( cleFinal, (strlen(cleFinal) + padding)*sizeof(char*));
            if (!temp)
            {
                perror("realloc final");
                return 1;
            }
            cleFinal = temp;
            for( int i = 0; i < padding ; i++ )
            {
                cleFinal[taille + i] = '=';
            }
            cleFinal[taille + padding] = '\0';
        }
         fprintf(stdout,"%s\n", cleFinal);
         //fprintf(stderr, "%ld", strlen(cleFinal));
        
        /*if (trouver) {
            
        } else {
            printf("Aucun Paterne de mot cle repere.\n");
            printf("Cle probablement de taille de tout le fichier, cle probable: %s\n", final);
        } */
    }else 
    {
        if ( strcmp(argv[3],"-o")==0 )
        {	
            FILE *h = fopen (argv[4], "wb");
            if (!h)
            {
                perror("Erreur fichier sortie");
                return 1;
            }
            int taille = strlen(cleFinal);
	    if ( (taille % 4) != 0 )
		{
			int padding = (4 - (taille % 4)) % 4;
			char *temp = realloc ( cleFinal, (strlen(cleFinal) + padding)*sizeof(char*));
			if (!temp)
			{
				perror("realloc final");
				return 1;
			}
				cleFinal = temp;
			for( int i = 0; i < padding ; i++ )
			{
				cleFinal[taille + i] = '=';
			}
			cleFinal[taille + padding] = '\0';
		}
		fwrite(cleFinal, 1, strlen(cleFinal), h);
		fclose(h);  
           
    	  
	    } else 
	    {
	     printf("erreur");	
	    }
	
   }
    free(final);


    for (int i = 0; i < 64; i++)
        free(Tableau[i]);
    free(Tableau);

    fclose(f);
    fclose(g);
    free(cleFinal);

    return 0;
}

