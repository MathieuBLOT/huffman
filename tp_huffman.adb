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
        Nb_Octets_Ecrits : Integer;

		S_In : Stream_Access;
		Fichier_In: Ada.Streams.Stream_IO.File_Type;
		S_Out : Stream_Access;
		Fichier_Out: Ada.Streams.Stream_IO.File_Type;
	begin
		Open(Fichier_In, In_File, Nom_Fichier_In);
		S_In := Stream(Fichier_In);
		Create(Fichier_Out, Out_File, Nom_Fichier_Out);
		S_Out := Stream(Fichier_Out);

		H := Cree_Huffman(S_In);

        -- On revient au début du fichier (je n'ai pas trouvé la fonction
        -- seek ou similaire en ADA
        Close(fichier_in);
		Open(Fichier_In, In_File, Nom_Fichier_In);
		S_In := Stream(Fichier_In);

        Nb_Octets_Ecrits := Ecrit_Huffman(H, S_In, S_Out);

		Close(Fichier_Out);
        Close(fichier_in);
	end Compresse;



------------------------------------------------------------------------------
-- DECOMPRESSION
------------------------------------------------------------------------------

	procedure Decompresse(Nom_Fichier_In, Nom_Fichier_Out : in String) is
		H : Arbre_Huffman;

		S_In : Stream_Access;
		Fichier_In: Ada.Streams.Stream_IO.File_Type;
		S_Out : Stream_Access;
		Fichier_Out: Ada.Streams.Stream_IO.File_Type;

	begin
		Open(Fichier_In, In_File, Nom_Fichier_In);
		S_In := Stream(Fichier_In);
		Create(Fichier_Out, Out_File, Nom_Fichier_Out);
		S_Out := Stream(Fichier_Out);

		H := Lit_Huffman(S_In, S_Out);

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

