with Ada.Text_Io, Ada.Command_Line, Ada.Streams.Stream_IO;
use Ada.Text_Io, Ada.Command_Line, Ada.Streams.Stream_IO;

with huffman, dico, code;
use huffman, dico, code;

procedure tp_huffman is

	type Code_Buffer is array (Integer range 0..7) of Integer;
-- 	type Length_Buffer is array (Integer range 0..7) of Natural;

	type Octet is new Integer range 0 .. 255;
	for Octet'Size use 8;

------------------------------------------------------------------------------
-- COMPRESSION
------------------------------------------------------------------------------

	procedure Compresse(Nom_Fichier_In, Nom_Fichier_Out : in String) is
		H : Arbre_Huffman;
		D : Dico_Caracteres := Cree_Dico;
		Nb_Octets_Ecrits : Natural := 0;

		C : Character;
		Code_Tmp : Code_Binaire := Cree_Code;	-- Code de chaque caractere
-- 		Lengths : Length_Buffer;
-- 		Nb_Codes : Integer := 0;
		Code_Seq : Code_Binaire := Cree_Code;	-- Code de plusieurs caracteres (cible : un octet)

		Bit_in_Code_Number : Natural := 0;	-- Number of the bit in the code
		Byte_Buffer : Octet := 0;
		It : Iterateur_Code;

		S_In : Stream_Access;
		Fichier_In: Ada.Streams.Stream_IO.File_Type;
		S_Out : Stream_Access;
		Fichier_Out: Ada.Streams.Stream_IO.File_Type;
	begin
		Create(Fichier_In, In_File, Nom_Fichier_In);
		S_In := Stream(Fichier_In);
		Create(Fichier_Out, Out_File, Nom_Fichier_Out);
		S_Out := Stream(Fichier_Out);

		H := Cree_Huffman(S_In);
		D := Get_Dictionnaire(H);

		Nb_Octets_Ecrits := Ecrit_Huffman(H, S_In, S_Out);

		Put_Line("# " & Natural'Image(Nb_Octets_Ecrits) & " octets ont été écrits en entête (Huffman Tree) #");

		-- lecture tant qu'il reste des caracteres
		while not End_Of_File(Fichier_In) loop
			C := Character'Input(S_In);
			Code_Tmp := Get_Code(C, D);
-- 			Lengths(Nb_Codes) := Longueur(Code_Buffer);
			Ajoute_Apres(Code_Tmp, Code_Seq);
		end loop;

		Close(Fichier_In);

		It := Cree_Iterateur(Code_Seq);
		while Has_Next(It) loop
			if Next(It) = UN then
				Byte_Buffer := Byte_Buffer + Octet(2**Bit_in_Code_Number);	-- Exponent (2^I)
			end if;
			Bit_in_Code_Number := Bit_in_Code_Number + 1;

			if Bit_in_Code_Number = 8 then	-- mod do not suffice : we must check an overflow occurred
				Bit_in_Code_Number := 0;
				Octet'Output(S_Out, Byte_Buffer);
			end if;
		end loop;

		if Bit_in_Code_Number /= 0 then
			Byte_Buffer := Byte_Buffer + Octet(2**(8 - Bit_in_Code_Number));-- We complete the end with 0s (as much as necessary)
			Octet'Output(S_Out, Byte_Buffer);
		end if;

		Close(Fichier_Out);
	end Compresse;



------------------------------------------------------------------------------
-- DECOMPRESSION
------------------------------------------------------------------------------

	procedure Decompresse(Nom_Fichier_In, Nom_Fichier_Out : in String) is
		H : Arbre_Huffman;
-- 		Tree : Arbre;
		Caractere_Trouve : Boolean := false;
		Caractere : Character;

		S_In : Stream_Access;
		Fichier_In: Ada.Streams.Stream_IO.File_Type;
		S_Out : Stream_Access;
		Fichier_Out: Ada.Streams.Stream_IO.File_Type;

		O : Octet;
		Code_Tmp : Code_Buffer;
-- 		Bit_Tmp : Bit;
		Code_Seq : Code_Binaire := Cree_Code;
		It : Iterateur_Code := Cree_Iterateur(Code_Seq);	-- IS supposed to be modified by Get_Caractere
	begin
		Create(Fichier_In, In_File, Nom_Fichier_In);
		S_In := Stream(Fichier_In);
		Create(Fichier_Out, Out_File, Nom_Fichier_Out);
		S_Out := Stream(Fichier_Out);

		H := Lit_Huffman(S_In, S_Out);
-- 		Tree := H.A;

		-- On génère une liste de bits (tout le ficier)
		while not End_Of_File(Fichier_In) loop
			O := Octet'Input(S_In);	-- On récupère un octet
			Code_Tmp(7) := Integer(O)/128;
			Code_Tmp(6) := Integer(O)/64 - Code_Tmp(7)*128;
			Code_Tmp(5) := Integer(O)/32 - Code_Tmp(7)*128 - Code_Tmp(6)*64;
			Code_Tmp(4) := Integer(O)/16 - Code_Tmp(7)*128 - Code_Tmp(6)*64 - Code_Tmp(5)*32;
			Code_Tmp(3) := Integer(O)/8 - Code_Tmp(7)*128 - Code_Tmp(6)*64 - Code_Tmp(5)*32 - Code_Tmp(4)*16;
			Code_Tmp(2) := Integer(O)/4 - Code_Tmp(7)*128 - Code_Tmp(6)*64 - Code_Tmp(5)*32 - Code_Tmp(4)*16 - Code_Tmp(3)*8;
			Code_Tmp(1) := Integer(O)/2 - Code_Tmp(7)*128 - Code_Tmp(6)*64 - Code_Tmp(5)*32 - Code_Tmp(4)*16 - Code_Tmp(3)*8 - Code_Tmp(2)*4;
			Code_Tmp(0) := Integer(O) - Code_Tmp(7)*128 - Code_Tmp(6)*64 - Code_Tmp(5)*32 - Code_Tmp(4)*16 - Code_Tmp(3)*8 - Code_Tmp(2)*4 - Code_Tmp(1)*2;

			for I in 0..7 loop
				if Code_Tmp(I) > 0 then
					Ajoute_Apres(UN, Code_Seq);
				else
					Ajoute_Apres(ZERO, Code_Seq);
				end if;
			end loop;

			--	On le fait à partir de Tree et non pas H.A au cas où un code est à cheval sur 2 bytes
			Get_Caractere(It, H, Caractere_Trouve, Caractere);

			if Caractere_Trouve then
				Character'Output(S_Out, Caractere);
			end if;
		end loop;


		Close(Fichier_In);
		Close(Fichier_Out);

	end Decompresse;


------------------------------------------------------------------------------
-- PG PRINCIPAL
------------------------------------------------------------------------------

    procedure Affiche_Utilisation is
    begin
		Put_Line("utilisation:");
		Put_Line("  compression : ./huffman -c fichier.txt fichier.comp");
		Put_Line("  decompression : ./huffman -d fichier.comp fichier.comp.txt");
		Set_Exit_Status(Failure);
    end Affiche_Utilisation;

begin

	if (Argument_Count /= 3) then
        Affiche_Utilisation;
        return;
	end if;

	if Argument(1) = "-c" then
		Compresse(Argument(2), Argument(3));
	elsif Argument(1) = "-d" then
		Decompresse(Argument(2), Argument(3));
    else
        Affiche_Utilisation;
        return;
	end if;

	Set_Exit_Status(Success);

end tp_huffman;

