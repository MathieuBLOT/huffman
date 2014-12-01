with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;

-- paquetage representant un arbre de Huffman de caracteres

package Huffman is

	type Arbre is private;
    type Arbre_Huffman is private;

	--type Arbre_Huffman is record
		---- l'arbre de Huffman proprement dit
		--A : Arbre;
		---- autres infos utiles: nb total de caracteres lus, ...
		--Nb_Total_Caracteres : Natural;
		---- A completer selon vos besoins!
	--end record;

	-- Libere l'arbre de racine A.
	-- garantit: en sortie toute la memoire a ete libere, et A = null.
	procedure Libere(H : in out Arbre_Huffman);

	procedure Affiche(H : in Arbre_Huffman);


	-- Cree un arbre de Huffman a partir d'un fichier texte
	-- Cette function lit le fichier et compte le nb d'occurences des
	-- differents caracteres presents, puis genere l'arbre correspondant
	-- et le retourne.
	function Cree_Huffman(Nom_Fichier : in String)
		return Arbre_Huffman;

	-- Stocke un arbre dans un flux ouvert en ecriture
	-- Le format de stockage est celui decrit dans le sujet
	-- Retourne le nb d'octets ecrits dans le flux (pour les stats)
	function Ecrit_Huffman(H : in Arbre_Huffman; stream : Stream_Access) return Natural;

private

	type Noeud;
    type Internal_Huffman;

	type Arbre is Access Noeud;
    type Arbre_Huffman is Access Internal_Huffman;

end Huffman;

