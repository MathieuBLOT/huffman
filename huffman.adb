with Ada.Integer_Text_IO, Ada.Text_IO, file_priorite, Ada.Unchecked_Deallocation;
use Ada.Integer_Text_IO, Ada.Text_IO;

package body Huffman is

	package Priorite is new file_priorite(Character, Integer, ">");

	type Noeud is record
		Lettre: Character;
		Priorite: Integer;
		FilsG: Arbre;
		FilsD: Arbre;
	end record;

	procedure Free is new Ada.Unchecked_Deallocation (Noeud, Arbre);


	funcion Est_Vide (A : in Arbre) return Boolean is
	begin
		return A = null;
	end Est_Vide;


	procedure Libere(H : in out Arbre_Huffman) is
	begin
		if Est_Vide(H.A) then
			return;
		end if;

		Libere(H.A.FilsD);
		Libere(H.A.FilsG);

		Free(H.A);
		H.A := null;
	end Libere;


	procedure Affiche(H : in Arbre_Huffman) is
	begin
		if Est_Vide(H.A) then
			return;
		end if;
		Put("[");
		Put(H.A.Lettre);
		Put(", ");
		Put(Integer'Image(H.A.Priorite));
		Put("]");
		if H.A.Fg /= NULL then
			Put(" /");
			Put("(");
			Affiche(H.A.Fg);
			Put(")");
		end if;
		if H.A.Fd /= NULL then
			Put("\");
			Put("(");
			Affiche(H.A.Fd);
			Put(")");
		end if;
		return;
	end Affiche;


	-- Cree un arbre de Huffman a partir d'un fichier texte
	-- Cette function lit le fichier et compte le nb d'occurences des
	-- differents caracteres presents, puis genere l'arbre correspondant
	-- et le retourne.
	function Cree_Huffman(Nom_Fichier : in String) return Arbre_Huffman is

	begin

	end Cree_Huffman;

	-- Stocke un arbre dans un flux ouvert en ecriture
	-- Le format de stockage est celui decrit dans le sujet
	-- Retourne le nb d'octets ecrits dans le flux (pour les stats)
	function Ecrit_Huffman(H : in Arbre_Huffman; Flux : Ada.Streams.Stream_IO.Stream_Access) return Positive is

	begin

	end Ecrit_Huffman;

	-- Lit un arbre stocke dans un flux ouvert en lecture
	-- Le format de stockage est celui decrit dans le sujet
	function Lit_Huffman(Flux : Ada.Streams.Stream_IO.Stream_Access) return Arbre_Huffman is

	begin

	end Lit_Huffman;


	-- Retourne un dictionnaire contenant les caracteres presents
	-- dans l'arbre et leur code binaire (evite les parcours multiples)
	-- de l'arbre
	function Genere_Dictionnaire(H : in Arbre_Huffman) return Dico_Caracteres is

	begin

	end Genere_Dictionnaire;



------ Parcours de l'arbre (decodage)

-- Parcours a l'aide d'un iterateur sur un code, en partant du noeud A
--  * Si un caractere a ete trouve il est retourne dans Caractere et
--    Caractere_Trouve vaut True. Le code n'a eventuellement pas ete
--    totalement parcouru. A est une feuille.
--  * Si l'iteration est terminee (plus de bits a parcourir ds le code)
--    mais que le parcours s'est arrete avant une feuille, alors
--    Caractere_Trouve vaut False, Caractere est indetermine
--    et A est le dernier noeud atteint.
	procedure Get_Caractere(It_Code : in Iterateur_Code; A : in out Arbre; Caractere_Trouve : out Boolean; Caractere : out Character) is

	begin

	end Get_Caractere;

end Huffman;