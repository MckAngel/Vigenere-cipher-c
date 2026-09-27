# Makefile pour cipher, decipher, findkey et bibliothèque statique

CC = gcc
CFLAGS = -Wall -Wextra -std=c99
TARGETS = cipher decipher findkey libstat.a

# Cible par défaut
all: $(TARGETS)

# Compilation du module fonction
fonction.o: fonction.c
	$(CC) $(CFLAGS) -c fonction.c

# Construction de la bibliothèque statique
libstat.a: fonction.o
	ar rcs libstat.a fonction.o

# Compilation de cipher avec la lib statique
cipher: cipher.c libstat.a
	$(CC) $(CFLAGS) -o cipher cipher.c libstat.a

# Compilation de decipher avec la lib statique
decipher: decipher.c libstat.a
	$(CC) $(CFLAGS) -o decipher decipher.c libstat.a

# Compilation de findkey avec la lib statique
findkey: findkey.c libstat.a
	$(CC) $(CFLAGS) -o findkey findkey.c libstat.a

# Nettoyage
clean:
	rm -f cipher decipher findkey *.o libstat.a
