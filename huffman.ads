with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with code;                  use code;
with dico;                  use dico;

-- paquetage representant un arbre de Huffman de caracteres
package Huffman is

	type Arbre is private;
    type Arbre_Huffman is private;

	-- Libere l'arbre de racine A.
	-- garantit: en sortie toute la memoire a ete libere, et A = null.
	procedure Libere(H : in out Arbre_Huffman);

    -- Affiche l'arbre de Huffman sous forme textuelle
	procedure Affiche(H : in Arbre_Huffman);


	-- Cree un arbre de Huffman a partir d'un fichier texte
	-- Cette function lit le fichier et compte le nb d'occurences des
	-- differents caracteres presents, puis genere l'arbre correspondant
	-- et le retourne.
	function Cree_Huffman(original_stream : Stream_Access) return Arbre_Huffman;

	-- Stocke un arbre dans un flux ouvert en ecriture
	-- Le format de stockage est celui decrit dans le sujet
	-- Retourne le nb d'octets ecrits dans le flux (pour les stats)
    --
    -- note : le nb d'octets est actuellement largement sur-estimé
	function Ecrit_Huffman(H : in Arbre_Huffman;
					in_stream, out_stream : in Stream_Access) return Natural;

	-- Lit un fichier compressé dans un flux in_stream et le décompresse dans 
    -- out_stream
	-- Le format de stockage est est le format simple
	function Lit_Huffman(in_stream, out_stream : Stream_Access) return Arbre_Huffman;

    -- Procedure de test permettant de valider le fonctionnement de l'arbre d'huffman
	procedure Huffman_procedure_test;

    -- permet de récupérer le dictionnaire généré par l'arbre de huffman
	function Get_Dictionnaire(H : Arbre_Huffman) return Dico_Caracteres;

	------ Parcours de l'arbre (decodage)
	-- Parcours a l'aide d'un iterateur sur un code, en partant du noeud A
	-- * Si un caractere a ete trouve il est retourne dans Caractere et
	-- Caractere_Trouve vaut True. Le code n'a eventuellement pas ete
	-- totalement parcouru. A est une feuille.
	-- * Si l'iteration est terminee (plus de bits a parcourir ds le code)
	-- mais que le parcours s'est arrete avant une feuille, alors
	-- Caractere_Trouve vaut False, Caractere est indetermine
	-- et A est le dernier noeud atteint.
    --
    -- Actuellement cette fonction n'est pas fonctionnelle il faut utiliser
    -- Lit_Huffman pour avoir les fonctionnalitées de décompression
	procedure Get_Caractere(It_Code : in Iterateur_Code; A : in out Arbre_Huffman;
					Caractere_Trouve : out Boolean; Caractere : out Character);

private

	type Noeud;
    type Internal_Huffman;

	type Arbre is Access Noeud;
    type Arbre_Huffman is Access Internal_Huffman;

end Huffman;

