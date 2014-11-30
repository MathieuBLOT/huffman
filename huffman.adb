with Ada.Integer_Text_IO, Ada.Text_IO, file_priorite, Ada.Unchecked_Deallocation;
use Ada.Integer_Text_IO, Ada.Text_IO;

with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;


package body Huffman is

	type Octet is new Integer range 0 .. 255;
	for Octet'Size use 8; -- permet d'utiliser Octet'Input et Octet'Output,
	                      -- pour lire/ecrire un octet dans un flux

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
		Fichier : Ada.Streams.Stream_IO.File_Type;
		Flux : Ada.Streams.Stream_IO.Stream_Access;
		C : Character;
	begin
		Open(Fichier, In_File, Nom_Fichier);
		Flux := Stream(Fichier);

		Put("~Lecture en cours~");

		Put(Integer'Input(Flux));
		Put(", ");
		Put(Integer(Octet'Input(Flux))); -- cast necessaire Octet -> Integer

		-- lecture tant qu'il reste des caracteres
		while not End_Of_File(Fichier) loop
			C := Character'Input(Flux);
			Put(", "); Put(C);
		end loop;

		Close(Fichier);
	end Cree_Huffman;

	-- Stocke un arbre dans un flux ouvert en ecriture
	-- Le format de stockage est celui decrit dans le sujet
	-- Retourne le nb d'octets ecrits dans le flux (pour les stats)
	function Ecrit_Huffman(H : in Arbre_Huffman; Flux : Ada.Streams.Stream_IO.Stream_Access) return Positive is
		Fichier : Ada.Streams.Stream_IO.File_Type;
		Flux : Ada.Streams.Stream_IO.Stream_Access;
		NbOctets: Positive := 0;
	begin
		Create(Fichier, Out_File, Nom_Fichier);
		Flux := Stream(Fichier);

		Put("~Ecriture en cours~");
		Put(I1); Put(", ");
		Put(Integer(O)); Put(", ");
		Put('a'); Put(", ");
		Put('b'); Put(", ");
		Put('c'); Put(", ");
		New_Line;

		Integer'Output(Flux, I1);
		Octet'Output(Flux, O);
		Character'Output(Flux, 'a');
		Character'Output(Flux, 'b');
		Character'Output(Flux, 'c');

		Close(Fichier);

		return NbOctets;
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