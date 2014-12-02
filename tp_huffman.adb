with Ada.Text_Io, Ada.Command_Line, Ada.Streams.Stream_IO;
use Ada.Text_Io, Ada.Command_Line, Ada.Streams.Stream_IO;

with huffman;
use huffman;

procedure tp_huffman is

------------------------------------------------------------------------------
-- COMPRESSION
------------------------------------------------------------------------------

	procedure Compresse(Nom_Fichier_In, Nom_Fichier_Out : in String) is
		H : Arbre_Huffman;
		Nb_Octets_Ecrits : Natural := 0;
		S : Stream_Access;
		Fichier_Out: File_Type;
	begin
		Create(Fichier_Out, Out_File, Nom_Fichier_Out);
		S := Stream(Fichier_Out);

		H := Cree_Huffman(Nom_Fichier_In);

		Nb_Octets_Ecrits := Ecrit_Huffman(H, S);

		Put_Line("# " & Natural'Image(Nb_Octets_Ecrits) & " octets ont été écrits en mémoire (Huffman Tree) #");
	end Compresse;



------------------------------------------------------------------------------
-- DECOMPRESSION
------------------------------------------------------------------------------

	procedure Decompresse(Nom_Fichier_In, Nom_Fichier_Out : in String) is
		H : Arbre_Huffman;
		S_In : Stream_Access;
		Fichier_In: File_Type;
		S_Out : Stream_Access;
		Fichier_Out: File_Type;
	begin
		Create(Fichier_In, In_File, Nom_Fichier_In);
		S_In := Stream(Fichier_In);
		Create(Fichier_Out, Out_File, Nom_Fichier_Out);
		S_Out := Stream(Fichier_Out);

		H := Lit_Huffman(S_In);
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

