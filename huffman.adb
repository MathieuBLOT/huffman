with Ada.Integer_Text_IO, Ada.Text_IO, file_priorite, Ada.Unchecked_Deallocation;
use Ada.Integer_Text_IO, Ada.Text_IO;
with Ada.Assertions;  use Ada.Assertions;

package body Huffman is

	package Priority_Queue is new File_Priorite(
		Arbre,
		Integer,
		">");

	use Priority_Queue;

	type Octet is new Integer range 0 .. 255;
	for Octet'Size use 8; -- permet d'utiliser Octet'Input et Octet'Output,
	                      -- pour lire/ecrire un octet dans un flux

	package Priorite is new file_priorite(Character, Integer, ">");

	type Noeud is record
		Lettre: Character;	-- Only the leaves matter...
		Poids: Integer;
		FilsG: Arbre;
		FilsD: Arbre;
	end record;

	procedure Libere is new Ada.Unchecked_Deallocation (Noeud, Arbre);
	procedure Insere_Noeud(C : in Character; P : in Integer; H : in out Arbre_Huffman);
	function Est_Vide (A : in Arbre) return Boolean;
	procedure Generate_Dictionary(A : in Arbre; D: in out Dico_Caracteres);

--------------------------------------------------------------------------------

	function Est_Vide (A : in Arbre) return Boolean is
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

		Libere(H.A);
		H.A := null;
	end Libere;


	procedure Affiche(H : in Arbre_Huffman) is
        procedure Affiche(A : in Arbre) is
        begin
            if Est_Vide(A) then
                return;
            end if;
            Put("[");
            Put(A.Lettre);
            Put(", ");
            Put(Integer'Image(A.Poids));
            Put("]");
            if A.FilsG /= NULL then
                Put(" /");
                Put("(");
                Affiche(A.FilsG);
                Put(")");
            end if;
            if A.FilsD /= NULL then
                Put("\");
                Put("(");
                Affiche(A.FilsD);
                Put(")");
            end if;
        end Affiche;
	begin
        Put_Line("~ Affichage de l'abre de Huffman ~");
        Affiche(H.A);
	end Affiche;

	procedure Insere_Noeud(C : in Character; P : in Integer; H : in out Arbre_Huffman) is
	begin
        null;

        --
        -- À fixer
        --

		--if H.A = null then
			--H.A := new Noeud'(C, P, null, null);
		--else
			--if H.A.FilsG = null then
				--Insere(C, P, H.A.FilsG);
			--else
				--Insere(C, P, H.A.FilsD);
			--end if;
		--end if;
	end Insere_Noeud;


	-- Cree un arbre de Huffman a partir d'un fichier texte
	-- Cette function lit le fichier et compte le nb d'occurences des
	-- differents caracteres presents, puis genere l'arbre correspondant
	-- et le retourne.
	function Cree_Huffman(Nom_Fichier : in String) return Arbre_Huffman is
		Fichier : Ada.Streams.Stream_IO.File_Type;
		Flux : Ada.Streams.Stream_IO.Stream_Access;

		C: Character;
		F: File_Prio := Cree_File(128);
		D: Dico_Caracteres := Cree_Dico;	-- Replace with simple Array ?
		Code: Code_Binaire := Cree_Code;

		H: Arbre_Huffman;
		--Character_Buffer1: Character;
		--Character_Buffer2: Character;
		Priority_Buffer1: Integer;
		Priority_Buffer2: Integer;
	begin
		Open(Fichier, In_File, Nom_Fichier);
		Flux := Stream(Fichier);

		Put_Line("~Lecture en cours~");
		Assert( not End_Of_File(Fichier), "Le fichier " & nom_fichier & " semble vide");
		-- lecture tant qu'il reste des caracteres
		while not End_Of_File(Fichier) loop
			C := Character'Val(Octet'Input(Flux));
			Put(C);
			New_Occurrence(D, C);
		end loop;
		New_Line;

		Close(Fichier);

		-- Might as well process data after stream closed...
		Put_Line("~Initialisation de la file de priorite~");
		for C in Character'First..Character'Last loop
			-- Generate Code
			Set_Code(C, Code, D);	-- Associate Character with (Binary) Code
			--Insere(F, Insere_Noeud(C, Get_Occurrence(D, C), H.A), Get_Occurrence(D, C));	-- Insert Character in Priority_Queue
		end loop;
		Affiche(D);
		New_Line;

		Put_Line("~Initialistation de l'arbre de Huffman~");
		while NOT Est_Vide(F) loop
			--Supprime(F, Character_Buffer1, Priority_Buffer1);
			--Supprime(F, Character_Buffer2, Priority_Buffer2);	-- To test for exception...

			--				Random character... I'm super duper inspired...
			H.A := new Noeud'('~', Priority_Buffer1 + Priority_Buffer2, null, null);
			--Insere_Noeud(Character_Buffer1, Priority_Buffer1, H);
			--Insere_Noeud(Character_Buffer2, Priority_Buffer2, H);

			Insere(F, H.A, Priority_Buffer1 + Priority_Buffer2);	-- Normally, replaceable with H.A.Poids
		end loop;

		-- Here, H should contain the Huffman Tree
        return H;
	end Cree_Huffman;

	-- Stocke un arbre dans un flux ouvert en ecriture
	-- Le format de stockage est celui decrit dans le sujet
	-- Retourne le nb d'octets ecrits dans le flux (pour les stats)
	function Ecrit_Huffman(H : in Arbre_Huffman; Flux : Ada.Streams.Stream_IO.Stream_Access) return Positive is
		Fichier : Ada.Streams.Stream_IO.File_Type;
		stream : Ada.Streams.Stream_IO.Stream_Access;
		NbOctets: constant Positive := 0;
		O: Octet;
        Nom_Fichier : String := ""; -- fix
	begin
		Create(Fichier, Out_File, Nom_Fichier);
		--stream := Stream(Fichier);

		Put("~Ecriture en cours~");

		--Integer'Output(stream, I1);
		Octet'Output(stream, O);
		Character'Output(stream, 'a');
		Character'Output(stream, 'b');
		Character'Output(stream, 'c');

		Close(Fichier);

		return NbOctets;
	end Ecrit_Huffman;

	-- Lit un arbre stocke dans un flux ouvert en lecture
	-- Le format de stockage est celui decrit dans le sujet
    function Lit_Huffman(Flux : Ada.Streams.Stream_IO.Stream_Access) return Arbre_Huffman is

    begin
        return Cree_Huffman("tofix"); -- fix
    end Lit_Huffman;


	-- Retourne un dictionnaire contenant les caracteres presents
	-- dans l'arbre et leur code binaire (evite les parcours multiples)
	-- de l'arbre
	function Genere_Dictionnaire(H : in Arbre_Huffman) return Dico_Caracteres is
		D: Dico_Caracteres := Cree_Dico;
	begin
		if NOT Est_Vide(H.A) then
			Generate_Dictionary(H.A, D);
			return D;
		else
			--return null;
			return D; -- fix
		end if;
	end Genere_Dictionnaire;

	procedure Generate_Dictionary(A : in Arbre; D: in out Dico_Caracteres) is
		Code: Code_Binaire := Cree_Code;
	begin
		if Est_Vide(A.FilsG) AND THEN Est_Vide(A.FilsG) then
			-- Process to generate Map
            null;
		elsif Est_Vide(A.FilsG) then
			Generate_Dictionary(A.FilsD, D);
		else
			Generate_Dictionary(A.FilsG, D);
		end if;
	end Generate_Dictionary;



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
        null;
	end Get_Caractere;

end Huffman;
