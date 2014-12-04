with Ada.Streams.Stream_IO;		use Ada.Streams.Stream_IO;
with Ada.Text_IO;				use Ada.Text_IO;
with Ada.Assertions;			use Ada.Assertions;
with Ada.Integer_Text_Io;		use Ada.Integer_Text_Io;
with Ada.Strings.Unbounded;		use Ada.Strings.Unbounded;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;
with Ada.Characters.Handling;

with dico;						use dico;
with file_priorite;

package body Huffman is

	package Priority_Queue is new File_Priorite(
		Arbre,
		Integer,
		"<");
	use Priority_Queue;

--------------------------------------------------------------------------------

	type Octet is new Integer range 0 .. 255;
	for Octet'Size use 8; -- permet d'utiliser Octet'Input et Octet'Output,
	                      -- pour lire/ecrire un octet dans un flux

	-- L'arbre de Huffman est stocké sous la forme d'un arbre binaire
	type Noeud is record
		Lettre: Character;	-- La lettre n'est utile que pour les feuille
		FilsG: Arbre;
		FilsD: Arbre;
	end record;

	-- Les données utile pour l'arbre de huffman
   	type Internal_Huffman is record
   		arb : Arbre;
		dico : Dico_Caracteres;
   		nb_char : Integer;
   	end record;

	-- Caractères utilisés pour séparer le header du reste du fichier compressé
	FIN_EN_TETE_1 : constant Character := '-';
	FIN_EN_TETE_2 : constant Integer := -1;

--------------------------------------------------------------------------------
-- En rapport avec la structure Arbre

	-- Libere un noeud
	procedure Libere is new Ada.Unchecked_Deallocation (Noeud, Arbre);

	-- Retourne true si l'arbre A est une feuille
	function Est_une_Feuille(A : in Arbre) return Boolean;

	-- Retourne vrai si l'arbre est vide
	function Est_Vide (A : in Arbre) return Boolean;

--------------------------------------------------------------------------------
-- En rapport avec l'algorithme de compression/decompression

	-- Lit le flux d'entree in_stream et compte les occurence de chacuns des
	-- caractères présent dans le in_steam. Le nombre de carctères lu est
	-- enregistré dans N, et le nombre d'occurences sont enregistrées dans le
	-- dictionnaire D.
	procedure Extrait_Dico(in_stream : in Stream_Access; D : out Dico_Caracteres;
				N : out Integer);

	-- Cree une file de priorité contenant tout les caractères du dictionnaire.
	-- La prioritée est le nombre d'occurence de ces caractères.
	procedure Initialise_Queue_Arbre(queue_arbre : in out File_Prio;
				D : in Dico_Caracteres);

	-- Génère les codes à partir de l'arbre A et les enregistres dans le
	-- dictionnaire D.
	procedure Genere_Code(A: in Arbre; D: in out Dico_Caracteres);

	-- Écrit l'en-tête du fichier compressé
	function Ecrit_EnTete(H : Arbre_Huffman; stream_out : Stream_Access) return Natural;

	-- Lis l'en-tête d'un fichier compressé pour pouvoir généré le dictionnaire
	-- correspondant.
	function Lit_EnTete(in_stream : in Stream_Access) return Dico_Caracteres;

	-- Génère l'arbre de Huffman à partir de la file de prioritée queue_arbre.
	-- Cette file doit contenir tout les caractères avec leur nombre d'occurence.
	function Genere_Arbre(queue_arbre : File_Prio) return Arbre;

    -----------------------------------------------------------------------------

	-- Ce package encapsule les opérations d'écriture et de lecture d'un
	-- caractère dans un flux compressé. Ce flux peut être un flux de sortie
	-- pour écrire un fichier compressé, ou un flux de lecture pour le
	-- décompresser.
	-- Il est écrit ici, car il a besoin de connaitre la structure interne de
	-- l'arbre binaire Arbre. Si Arbre avait été un package séparé, il aurait
	-- été également possible de séparer ce package de Huffman.
	package Stream_Buffer is
		type Stream_Buffer is private;

		function Cree_Stream_Buffer(S : Stream_Access) return Stream_Buffer;

		-- Écrit le code Binaire C dans le flux (le Stream_Access encapsulé
		-- doit-être un flux de sortie
		procedure Write_Code(S : Stream_Buffer; C : Code_Binaire);

		-- Lit le prochain caractère dans le stream encapsulé. Celui-ci doit
		-- être un flux d'entrée. Génère l'exception End_Error quand la fin du
		-- stream est atteinte.
		function Read_Char(S : Stream_Buffer; A : Arbre) return Character;

		-- Ecrit des bits vide à la fin du stream pour compléter le dernier octet.
		procedure Write_Last_Byte(S : Stream_Buffer);

		-- Libere la mémoire du Stream_Buffer.
		procedure Libere(S: in out Stream_Buffer);
	private
		type Stream_Buffer_Internal;
		type Stream_Buffer is access Stream_Buffer_Internal;
	end Stream_Buffer;

    -----------------------------------------------------------------------------

	package body Stream_Buffer is

		-- permet d'accéder à des bits dans un octet de manière indexé.
		type Bit_Number is range 0 .. 7;
		type Octet is array (Bit_Number) of Bit;
		pragma Pack (Octet);
		function To_Octet is new Ada.Unchecked_Conversion(
						Source => Integer,
						Target => Octet);
		function To_Integer is new Ada.Unchecked_Conversion(
						Source => Octet,
						Target => Integer);

    -----------------------------------------------------------------------------

		-- Un Stream_Buffer connait en interne l'index du prochain bit à lire ou à écrire, ainsi que le prochain Octet à lire/écrire.
		type Stream_Buffer_Internal(S: Stream_Access) is record
			O : Octet;
			bit_courant : Bit_Number := 0;
			stream : Stream_Access := S;
		end record;

    -----------------------------------------------------------------------------

		-- Retourne le prochain bit dans le stream (et récupère l'octet suivant si
		-- necessaire
		-- Génère l'exception End_Error lorsque la fin du stream est atteinte
		function Get_Bit(S : Stream_Buffer) return Code.Bit;

    -----------------------------------------------------------------------------
	
		procedure Free is new Ada.Unchecked_Deallocation (Stream_Buffer_Internal,
						Stream_Buffer);
		procedure Libere(S: in out Stream_Buffer) is
		begin
			Free(S);
			S := null;
		end Libere;

    -----------------------------------------------------------------------------

		function Cree_Stream_Buffer(S : Stream_Access) return Stream_Buffer is
		begin
			-- On n'extrait pas tout de suite le premier bit. Cela sera fait
			-- lors du premier appel à Get_Bit
			return new Stream_Buffer_Internal(S);
		end Cree_Stream_Buffer;

    -----------------------------------------------------------------------------

		function Get_Bit(S : Stream_Buffer) return Code.Bit is
		begin
			if S.bit_courant = Bit_Number'Last then
				-- On a atteint le dernier bit de l'octet courant
				S.o := Octet'Input(S.stream);
				S.bit_courant := 0;
			else
				S.bit_courant := S.bit_courant + 1;
			end if;

			return S.o(S.bit_courant);
		end Get_Bit;

    -----------------------------------------------------------------------------

		procedure Write_Code(S : Stream_Buffer; C : Code_Binaire) is
			it : constant Iterateur_Code := Cree_Iterateur(C);
		begin
			while Has_Next(it) loop
				S.O(S.bit_courant) := Next(it);
				if S.bit_courant = Bit_Number'Last then
					-- On a atteind le dernier bitde l'octet courant, il faut donc
					-- l'écrire.
					Octet'Output(S.stream, S.O);
					S.bit_courant := 0;
				else
					S.bit_courant := S.bit_courant + 1;
				end if;
			end loop;
		end Write_Code;

     ---------------------------------------------------------------------------

		procedure Write_Last_Byte(S : Stream_Buffer) is
		begin
			-- On complète les dernier bits par des 0.
			loop
				exit when S.bit_courant = Bit_Number'Last;
				S.O(S.bit_courant) := 0;
				S.bit_courant := S.bit_courant + 1;
			end loop;
			Octet'Output(S.stream, S.O);
		end Write_Last_Byte;

    -----------------------------------------------------------------------------

		function Read_Char(S : Stream_Buffer; A : Arbre) return Character is
			child : Arbre;
			bit : Code.Bit;
		begin
			-- On parcourt l'arbre en fonction de ce que contient jusqu'à
			-- trouver un charactère valide
			bit := Get_Bit(S);
			if bit = ZERO then
				child := A.filsG;
			else
				child := A.filsD;
			end if;

			if Est_une_Feuille(child) then
				return child.lettre;
			else
				return Read_Char(S, child);
			end if;
		end Read_Char;

    -----------------------------------------------------------------------------

	end Stream_Buffer;

	use Stream_Buffer;

--------------------------------------------------------------------------------

	function Est_une_Feuille(A : in Arbre) return Boolean is
	begin
		return A.FilsG = null and then A.FilsD = null;
	end Est_une_Feuille;

	function Est_Vide (A : in Arbre) return Boolean is
	begin
		return A = null;
	end Est_Vide;

--------------------------------------------------------------------------------

	procedure Libere(H : in out Arbre_Huffman) is
	begin
		if Est_Vide(H.arb) then
			return;
		end if;

		Libere(H.arb.FilsD);
		Libere(H.arb.FilsG);

		Libere(H.arb);
		Libere(H.dico);

		H := null;
	end Libere;

--------------------------------------------------------------------------------

    function To_Unbounded_String(A : Arbre; D : Dico_Caracteres) return Unbounded_string is

		function Aligne(profondeur : Integer) return Unbounded_string;
		function Gauche(A : Arbre; profondeur : Integer) return Unbounded_string;
		function Droit(A : Arbre; profondeur : Integer) return Unbounded_string;
		function Child(A : Arbre; profondeur : Integer) return Unbounded_string;
		function Aligne_Tab(profondeur : Integer) return Unbounded_string;
		function Feuille(A : Arbre; profondeur : Integer) return Unbounded_string;

		function Aligne(profondeur : Integer) return Unbounded_string is
		begin
			if profondeur = 0 then
				return To_Unbounded_String("");
			else
				return "│   " & Aligne(profondeur - 1);
			end if;
		end Aligne;

		function Gauche(A : Arbre; profondeur : Integer) return Unbounded_string is
			str : Unbounded_string := Null_Unbounded_String;
		begin
			Append(str, "┬─0─");
			Append(str, Child(A, profondeur));
			return str;
		end Gauche;

		function Droit(A : Arbre; profondeur : Integer) return Unbounded_string is
			str : Unbounded_string := Null_Unbounded_String;
		begin
			Append(str, "└─1─");
			Append(str, Child(A, profondeur));
			return str;
		end Droit;

		 function Child(A : Arbre; profondeur : Integer) return Unbounded_string is
			str : Unbounded_string := Null_Unbounded_String;
		begin
			if Est_une_Feuille(A) then
				return Feuille(A, profondeur);
			else
				Append(str, Gauche(A.FilsG, profondeur + 1));
				Append(str, Aligne(profondeur));
				Append(str, Droit(A.FilsD, profondeur + 1));
			end if;
			return str;
		end Child;

		function Aligne_Tab(profondeur : Integer) return Unbounded_string is
			str : Unbounded_string := Null_Unbounded_String;
		begin
			if profondeur < 10 then
				Append(str, "    ");
				Append(str, Aligne_Tab(profondeur + 1));
			else
				str := To_Unbounded_String("");
			end if;
			return str;
		end Aligne_Tab;

		function Feuille(A : Arbre; profondeur : Integer) return Unbounded_string is
			str : Unbounded_string := Null_Unbounded_String;
		begin
			Append(str, Aligne_Tab(profondeur));
			case A.Lettre is
				when ASCII.HT =>
					Append(str, "\t");
				when ASCII.LF =>
					Append(str, "\n");
				when others =>
					Append(str, A.Lettre);
			end case;
			Append(str, ": ");
			Append(str, To_Unbounded_String(Get_Code(A.Lettre, D)));
			Append(str, " (");
			Append(str, Integer'Image(Get_Occurrence(D, A.Lettre)));
			Append(str, " occurrences)");
			Append(str, ASCII.LF);
			return str;
		end Feuille;
	begin
		return Child(A, 0);
	end To_Unbounded_String;

--------------------------------------------------------------------------------

	procedure Affiche(H : in Arbre_Huffman) is
	begin
		Put_Line(To_String(To_Unbounded_String(H.arb, H.dico)));
	end Affiche;

--------------------------------------------------------------------------------

	procedure Extrait_Dico(in_stream : in Stream_Access; D : out Dico_Caracteres;
				N : out Integer) is
		C, Cnext: Character;
	begin
		D := Cree_Dico;
		N := 0;

		-- lecture tant qu'il reste des caracteres
		Cnext := Character'Val(Octet'Input(in_stream));
		begin
			loop
				C := Cnext;
				Cnext := Character'Val(Octet'Input(in_stream));

				New_Occurrence(D, C);
				N := N + 1;
			end loop;
		exception
			when Ada.Streams.Stream_IO.End_Error =>
				null; -- On a atteint la fin du stream
		end;

	end Extrait_Dico;

--------------------------------------------------------------------------------

	function Genere_Arbre(queue_arbre : File_Prio) return Arbre is
		prio_g, prio_d : Integer;
		fg, fd : Arbre;
	begin
		-- On regroupe les deux noeuds de plus faible valeure et ainsi de suite
		-- jusqu'à ce qu'on n'ai plus qu'un arbre unique
		loop
			Supprime(queue_arbre, fg, prio_g);
			exit when Est_Vide(queue_arbre);
			Supprime(queue_arbre, fd, prio_d);
			Insere(queue_arbre, -- Pour le debug, j'utilise la lettre du fils gauche
					new Noeud'(Ada.Characters.Handling.To_Upper(fg.Lettre), fg, fd),
					prio_g + prio_d);
		end loop;
		-- À ce point la, l'Arbre de huffman est le fils gauche
		return fg;
	end Genere_Arbre;

--------------------------------------------------------------------------------

	procedure Initialise_Queue_Arbre(queue_arbre : in out File_Prio;
				D : in Dico_Caracteres) is
		nb_occur : Integer;
	begin
		-- On ajoute dans la file de priorite les futures feuille de l'arbre de huffman
		-- Ce sont tous les caractères ayant au moins une occurence
		for it_dico in Character'Range loop
			nb_occur := Get_Occurrence(D, it_dico);
			if nb_occur > 0 then
				Insere(queue_arbre,
					   new Noeud'(it_dico,
								   null,
								   null),
					   nb_occur);
			end if;
		end loop;
	end Initialise_Queue_Arbre;

--------------------------------------------------------------------------------

	procedure Genere_Code(A: in Arbre; D: in out Dico_Caracteres) is
	begin
		-- On génère les codes à partir de l'arbre de huffman
		declare
			procedure Internal_Genere_Code(A: in Arbre; C : in Code_Binaire;
										   D: in out Dico_Caracteres) is
				Code_FG, Code_FD : Code_Binaire;
			begin
				if Est_une_Feuille(A) then
					Set_Code(A.Lettre, C, D);
				else
					-- On fait une copie du Code_Binaire dans l'arbre gauche
					-- L'arbre droit peut en revanche modifier le Code_Binaire
					-- vu que ce code ne sera plus jamais utilisé ailleurs
					Code_FG := C;
					Code_FD := Cree_Code(C);

					Ajoute_Apres(ZERO, Code_FG);
					Ajoute_Apres(UN, Code_FD);

					Internal_Genere_Code(A.FilsG, Code_FG, D);
					Internal_Genere_Code(A.FilsD, Code_FD, D);
				end if;
			end Internal_Genere_Code;

		begin
			Internal_Genere_Code(A, Cree_Code, D);
		end;
	end Genere_Code;

--------------------------------------------------------------------------------

	-- Cree un arbre de Huffman a partir d'un fichier texte
	-- Cette function lit le fichier et compte le nb d'occurences des
	-- differents caracteres presents, puis genere l'arbre correspondant
	-- et le retourne.
	function Cree_Huffman(original_stream : Stream_Access) return Arbre_Huffman is

		D: Dico_Caracteres;
		N: Integer;

		H: Arbre_Huffman;

		A : Arbre;
		queue_arbre : File_Prio := Cree_File(256); -- Il faudrait utiliser un attribut tel que dico'last mais je ne sais pas comment l'utiliser

	begin
		Extrait_Dico(original_stream, D, N);

		Put_Line("~Initialisation de la file de priorite~");
		Initialise_Queue_Arbre(queue_arbre, D);

		Put_Line("~Génération de l'arbre de Huffman~");
		A := Genere_Arbre(queue_arbre);
		new_Line;
        Put_Line("~ Affichage de l'abre de Huffman ~");
		Put_Line(To_String(To_Unbounded_String(A, D)));
		new_Line;

		Put_Line("~Initialistation des codes de compressions~");
		Genere_Code(A, D);
		Affiche(D);

   		H := new Internal_Huffman'(arb => A, dico => D, nb_char => N);
        return H;
	end Cree_Huffman;

--------------------------------------------------------------------------------

	procedure Huffman_procedure_test is
		nom_fichier : constant String := "Tests/3a_4b_5c_6d_7e.txt";
		nom_fichier_compress : constant String := "Tests/3a_4b_5c_6d_7e.comp";
		nom_fichier_apres_decompress : constant String := "Tests/3a_4b_5c_6d_7e.apres_decompress";

		original_file : Ada.Streams.Stream_IO.File_Type;
		original_stream : Stream_Access;

		arbre_solution : constant String :=
			"┬─0─┬─0─                                c:  ( 5 occurrences)" & ASCII.LF &
			"│   └─1─                                d:  ( 6 occurrences)" & ASCII.LF &
			"└─1─┬─0─                                e:  ( 7 occurrences)" & ASCII.LF &
			"│   └─1─┬─0─                            a:  ( 3 occurrences)" & ASCII.LF &
			"│   │   └─1─                            b:  ( 4 occurrences)" & ASCII.LF ;

		arbre_solution_avec_code : constant String :=
			"┬─0─┬─0─                                c: 00 ( 5 occurrences)" & ASCII.LF &
			"│   └─1─                                d: 01 ( 6 occurrences)" & ASCII.LF &
			"└─1─┬─0─                                e: 10 ( 7 occurrences)" & ASCII.LF &
			"│   └─1─┬─0─                            a: 110 ( 3 occurrences)" & ASCII.LF &
			"│   │   └─1─                            b: 111 ( 4 occurrences)" & ASCII.LF ;

	begin

		-- Compression
		declare
			NbCarac : Natural := 0;
			fichier_compress : Ada.Streams.Stream_IO.File_Type;
			stream_compress : Stream_Access;
			D: Dico_Caracteres;
			N: Integer;

			H: Arbre_Huffman;

			A : Arbre;
			queue_arbre : File_Prio := Cree_File(256); -- Il faudrait utiliser un attribut tel que dico'last mais je ne sais pas comment l'utiliser

		begin
			Put_Line("~Test de compression du fichier " & Nom_Fichier & " ~");
			Open(original_file, In_File, Nom_Fichier);
			original_stream := Stream(original_file);
			Extrait_Dico(original_stream, D, N);

			-- On revient au début du fichier (je n'ai pas trouvé la fonction
			-- seek ou similaire en ADA
			Close(original_file);
			Open(original_file, In_File, Nom_Fichier);
			original_stream := Stream(original_file);


			Assert(Get_Occurrence(D, 'a') = 3, "Le nombre de a lu ne correspond pas");
			Assert(Get_Occurrence(D, 'b') = 4, "Le nombre de b lu ne correspond pas");
			Assert(Get_Occurrence(D, 'c') = 5, "Le nombre de c lu ne correspond pas");
			Assert(Get_Occurrence(D, 'd') = 6, "Le nombre de d lu ne correspond pas");
			Assert(Get_Occurrence(D, 'e') = 7, "Le nombre de e lu ne correspond pas");

			Initialise_Queue_Arbre(queue_arbre, D);
			A := Genere_Arbre(queue_arbre);

			if To_String(To_Unbounded_String(A,D)) /= arbre_solution then
				Put("L'arbre généré n'est pas le bon : " & ASCII.LF & ASCII.LF &
					To_String(To_Unbounded_String(A, D)) & ASCII.LF & ASCII.LF &
					"Au lieu de : " & ASCII.LF & ASCII.LF &
					arbre_solution);
				Assert(false);
			end if;

			Genere_Code(A, D);
			if To_String(To_Unbounded_String(A,D)) /= arbre_solution_avec_code then
				Put("L'arbre généré n'est pas le bon : " & ASCII.LF & ASCII.LF &
					To_String(To_Unbounded_String(A, D)) & ASCII.LF & ASCII.LF &
					"Au lieu de : " & ASCII.LF & ASCII.LF &
					arbre_solution_avec_code);
				Assert(false);
			end if;

			H := new Internal_Huffman'(arb => A, dico => D, nb_char => N);

			Create(fichier_compress, Out_File, nom_fichier_compress);
			stream_compress := Stream(fichier_compress);
			NbCarac := Ecrit_Huffman(H, original_stream, stream_compress);

			Put_Line ("Taille avant compression : " & Integer'Image(N) & " et " &
					  "taille après compression : " & Integer'Image(NbCarac));
			Close(original_file);
			Close(fichier_compress);
		end;

		New_Line;

		-- Decompression
		declare
			NbCarac : Natural := 0;
			fichier_decompress : Ada.Streams.Stream_IO.File_Type;
			stream_decompress : Stream_Access;
			fichier_apres_decompress : Ada.Streams.Stream_IO.File_Type;
			stream_apres_decompress : Stream_Access;
			D: Dico_Caracteres;
			N: Integer;

			H: Arbre_Huffman;

			A : Arbre;
			queue_arbre : File_Prio := Cree_File(256); -- Il faudrait utiliser un attribut tel que dico'last mais je ne sais pas comment l'utiliser
		begin
			Put_Line("~Test de decompression du fichier " & nom_fichier_compress & " ~");

			-- Lecture de l'en-tête
			Open(fichier_decompress, In_File, nom_fichier_compress);
			stream_decompress := Stream(fichier_decompress);
			Create(fichier_apres_decompress, Out_File, nom_fichier_apres_decompress);
			stream_apres_decompress := Stream(fichier_apres_decompress);

			D := Lit_EnTete(stream_decompress);

			-- Récupération de l'arbre de Huffman
			Initialise_Queue_Arbre(queue_arbre, D);
			A := Genere_Arbre(queue_arbre);
			Genere_Code(A, D);
			-- On s'assure que le code généré à partir de l'entête est bien celui utilisé lors de la compression.
			if To_String(To_Unbounded_String(A,D)) /= arbre_solution_avec_code then
				Put("L'arbre généré n'est pas le bon : " & ASCII.LF & ASCII.LF &
					To_String(To_Unbounded_String(A, D)) & ASCII.LF & ASCII.LF &
					"Au lieu de : " & ASCII.LF & ASCII.LF &
					arbre_solution_avec_code);
				Assert(false);
			end if;


			-- Récupération de l'arbre de Huffman
			Initialise_Queue_Arbre(queue_arbre, D);
			A := Genere_Arbre(queue_arbre);
			Genere_Code(A, D);
			H := new Internal_Huffman'(arb => A, dico => D, nb_char => N);

			Decompresse_Corps_Fichier(stream_decompress, stream_apres_decompress, A);

			Close(fichier_decompress);
			Close(fichier_apres_decompress);
		end;

		-----------------------------------------------------------------------------

		Put_Line("~Les tests de l'arbre de huffman se sont bien passés ... OK~");
		New_Line;
	end Huffman_procedure_test;

--------------------------------------------------------------------------------

	function Ecrit_EnTete(H : Arbre_Huffman; stream_out : Stream_Access) return Natural is
		NbOctets: Natural := 0;

	begin
		-- On n'écrit les stats uniquements pour les caractères présents dans le fichier
		for C in Character'Range loop
			if Est_Present(C, H.dico) then
				Character'Output(stream_out, C);
				Integer'Output(stream_out, Get_Occurrence(H.dico, C));
				NbOctets := NbOctets + Character'Size + Integer'Size;
			end if;
		end loop;

		-- On rajoute des marqueurs de fin pour séparer l'en-tête du reste du fichier
		Character'Output(stream_out, FIN_EN_TETE_1);
		Integer'Output(stream_out, FIN_EN_TETE_2);
		NbOctets := NbOctets + Character'Size + Integer'Size;

		return NbOctets;
	end Ecrit_EnTete;

--------------------------------------------------------------------------------

	function Ecrit_Texte(H : Arbre_Huffman; in_stream, out_stream : Stream_Access) return Natural is
		NbOctets: Natural := 0;
		out_buf : Stream_Buffer.Stream_Buffer := Cree_Stream_Buffer(out_stream);
		NextC, C : Character;
	begin
		NextC := Character'Input(in_stream);
		--while not End_Of_File(in_stream) loop
		begin
			loop
				C := NextC;
				NextC := Character'Input(in_stream);
				Put(C);
				Write_Code(out_buf, Get_Code(C, H.dico));
				-- normalement il faudrait faire +1 uniquement quand le
				-- stream_buffer écrit dans le fichier. Le calcul du nombre
				-- d'octet en compression n'est donc actuellement pas bon.
				NbOctets := NbOctets + 1;
			end loop;
		exception
			when Ada.Text_IO.End_Error =>
				null; -- On a atteint la fin du stream
		end;

		Write_Last_Byte(out_buf);
		Libere(out_buf);
		return NbOctets;
	end Ecrit_Texte;

--------------------------------------------------------------------------------

	-- Stocke un arbre dans un flux ouvert en ecriture
	-- Le format de stockage est celui decrit dans le sujet
	-- Retourne le nb d'octets ecrits dans le flux (pour les stats)
	function Ecrit_Huffman(H : in Arbre_Huffman;
					in_stream, out_stream : in Stream_Access) return Natural is
		Fichier : Ada.Streams.Stream_IO.File_Type;
		NbOctets: Natural := 0;
		O: Octet;
        Nom_Fichier : String := ""; -- fix
	begin
		Put_Line("~Stockage de l'arbre en cours~");
		NbOctets := NbOctets + Ecrit_EnTete(H, out_stream);

		Put_Line("~Ecriture en cours~");

		NbOctets := NbOctets + Ecrit_Texte(H, in_stream, out_stream);

		Put("fin d'écriture");

		return NbOctets;
	end Ecrit_Huffman;

--------------------------------------------------------------------------------

	function Lit_EnTete(in_stream : in Stream_Access) return Dico_Caracteres is
		I : Integer;
		C : Character;
		D : Dico_Caracteres := Cree_Dico;
	begin
		-- On Récupère l'en-tête du fichier compressé
		loop
			C := Character'Input(in_stream);
			I := Integer'Input(in_stream);
			exit when C = FIN_EN_TETE_1 and I = FIN_EN_TETE_2;
			Set_Occurrence(D, C, I);
			New_Line;
		end loop;

		return D;
	end Lit_EnTete;

--------------------------------------------------------------------------------

	procedure Decompresse_Corps_Fichier(in_stream, out_stream : in Stream_Access;
				A : Arbre) is
		in_buf : Stream_Buffer.Stream_Buffer := Cree_Stream_Buffer(in_stream);
		C : Character;
	begin
		Put_Line("Decompresse_Corps_Fichier");
		--while not End_Of_File(in_stream) loop
		begin
			loop
				C := Read_Char(in_buf, A);
				Put(c);
				Character'Output(out_stream, C); -- pour le débug, à supprimer ensuite
			end loop;
		exception
			when Ada.Text_IO.End_Error =>
				null; -- On a atteint la fin du stream
		end;
		Put_Line("Fin Decompresse_Corps_Fichier");
	end Decompresse_Corps_Fichier;

--------------------------------------------------------------------------------

	-- Lit un arbre stocke dans un flux ouvert en lecture
	-- Le format de stockage est celui decrit dans le sujet
	function Lit_Huffman(in_stream, out_stream : Stream_Access) return Arbre_Huffman is
		H: Arbre_Huffman;
		D: Dico_Caracteres;
		N: Integer;
		A : Arbre;
		queue_arbre : File_Prio := Cree_File(256); -- Il faudrait utiliser un attribut tel que dico'last mais je ne sais pas comment l'utiliser
	begin
		D:= Lit_EnTete(in_stream);

		-- Récupération de l'arbre de Huffman
		Initialise_Queue_Arbre(queue_arbre, D);
		A := Genere_Arbre(queue_arbre);
		Genere_Code(A, D);
		H := new Internal_Huffman'(arb => A, dico => D, nb_char => N);

		Decompresse_Corps_Fichier(in_stream, out_stream, A);
		return H;
	end Lit_Huffman;

--------------------------------------------------------------------------------
	function Get_Dictionnaire(H : Arbre_Huffman) return Dico_Caracteres is
	begin
		return H.dico;
	end Get_Dictionnaire;
--------------------------------------------------------------------------------

------ Parcours de l'arbre (decodage)

-- Parcours a l'aide d'un iterateur sur un code, en partant du noeud A
--  * Si un caractere a ete trouve il est retourne dans Caractere et
--    Caractere_Trouve vaut True. Le code n'a eventuellement pas ete
--    totalement parcouru. A est une feuille.
--  * Si l'iteration est terminee (plus de bits a parcourir ds le code)
--    mais que le parcours s'est arrete avant une feuille, alors
--    Caractere_Trouve vaut False, Caractere est indetermine
--    et A est le dernier noeud atteint.
	procedure Get_Caractere(It_Code : in Iterateur_Code; A : in out Arbre_Huffman;
					Caractere_Trouve : out Boolean; Caractere : out Character) is
	begin
		null; -- Il faudrait utiliser la fonction Stream_Buffer.Read_Char dans
		-- cette fonction end Get_Caractere;
	end Get_Caractere;

end Huffman;
