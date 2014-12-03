with Ada.Text_Io, Ada.Command_Line, Ada.Streams.Stream_IO;
use Ada.Text_Io, Ada.Command_Line, Ada.Streams.Stream_IO;

with huffman, code;
use huffman, code;

procedure tp_huffman is

	type Code_Buffer is array (Integer range 0..7) of Integer;

	type Octet is new Integer range 0 .. 255;
	for Octet'Size use 8;

------------------------------------------------------------------------------
-- COMPRESSION
------------------------------------------------------------------------------

	procedure Compresse(Nom_Fichier_In, Nom_Fichier_Out : in String) is
		H : Arbre_Huffman;
		Nb_Octets_Ecrits : Natural := 0;

		S_In : Stream_Access;
		Fichier_In: Ada.Streams.Stream_IO.File_Type;
		S_Out : Stream_Access;
		Fichier_Out: Ada.Streams.Stream_IO.File_Type;
	begin
		Create(Fichier_In, In_File, Nom_Fichier_In);
		S_In := Stream(Fichier_In);
		Create(Fichier_Out, Out_File, Nom_Fichier_Out);
		S_Out := Stream(Fichier_Out);

		H := Cree_Huffman(Fichier_In);

		Nb_Octets_Ecrits := Ecrit_Huffman(H, S_Out);

		Put_Line("# " & Natural'Image(Nb_Octets_Ecrits) & " octets ont été écrits en entête (Huffman Tree) #");
	end Compresse;



------------------------------------------------------------------------------
-- DECOMPRESSION
------------------------------------------------------------------------------

	procedure Decompresse(Nom_Fichier_In, Nom_Fichier_Out : in String) is
		H : Arbre_Huffman;
		Tree : Arbre;
		Caractere_Trouve : Boolean := false;
		Caractere : Character;

		S_In : Stream_Access;
		Fichier_In: Ada.Streams.Stream_IO.File_Type;
		S_Out : Stream_Access;
		Fichier_Out: Ada.Streams.Stream_IO.File_Type;

		O : Octet;
		Code_Tmp : Code_Buffer;
		Bit_Tmp : Bit;
		Code_Seq : Code_Binaire := Cree_Code;
		It : Iterateur_Code := Cree_Iterateur(Code_Seq);
	begin
		Create(Fichier_In, In_File, Nom_Fichier_In);
		S_In := Stream(Fichier_In);
		Create(Fichier_Out, Out_File, Nom_Fichier_Out);
		S_Out := Stream(Fichier_Out);

		H := Lit_Huffman(S_In);
		Tree := H.A;

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
			Get_Caractere(It, Tree, Caractere_Trouve, Caractere);

			if Caractere_Trouve then
				Character'Output(S_Out, Caractere);
			end if;

			Close(Fichier_In);
			Close(Fichier_Out);
		end loop;


	end Decompresse;


------------------------------------------------------------------------------
-- PG PRINCIPAL
------------------------------------------------------------------------------

begin

	if (Argument_Count /= 3) then
		Put_Line("utilisation:");
		Put_Line("  compression : ./huffman -c fichier.txt fichier.comp");
		Put_Line("  decompression : ./huffman -d fichier.comp fichier.comp.txt");
		Set_Exit_Status(Failure);
		return;
	end if;

	if (Argument(1) = "-c") then
		Compresse(Argument(2), Argument(3));
	else
		Decompresse(Argument(2), Argument(3));
	end if;

	Set_Exit_Status(Success);

end tp_huffman;

