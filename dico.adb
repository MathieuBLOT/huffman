with Ada.Integer_Text_IO, Ada.Text_IO, Ada.Unchecked_Deallocation;
use Ada.Integer_Text_IO, Ada.Text_IO;

package body Dico is

	type Tab is array (Character <>) of Info_Caractere;

	type Dico_Caracteres_Interne is record
		Number: Integer;	-- Number of different characters
		T: Tab(0..127);
	end record;

	procedure Free is new Ada.Unchecked_Deallocation (Dico_Caracteres_Interne, Dico_Caracteres);

	-- Cree un dictionnaire D, initialement vide
	function Cree_Dico return Dico_Caracteres is
		D: Dico_Caracteres := new Dico_Caracteres_Interne;
	begin
		return D;
	end Cree_Dico;

	-- Libere le dictionnaire D
	-- garantit: en sortie toute la memoire a ete libere, et D = null.
	procedure Libere(D : in out Dico_Caracteres) is
	begin
		Free(D);
	end Libere;

	-- Affiche pour chaque caractere: son nombre d'occurences et son code
	-- (s'il a ete genere)
	procedure Affiche(D : in Dico_Caracteres) is
	begin
		for I in D.T'First..D.T'Last loop
			Put_Line();
			Put(I & " : ");	-- Print Character -> Morph into generic Put ?
			Put(Integer'Image(D.T(I).Occurrence) & " occurrence(s)");
			if Integer'Image(D.T(I).Occurrence > 0 then
				Put(", de code : ");
				Afffiche(Integer'Image(D.T(I).Code);
				Put(".");
			end if;
		end loop;
	end Affiche;


-- Ajouts d'informations dans le dictionnaire

	-- Nouvelle occurence d'un caractere
	procedure New_Occurrence(D : in Dico_Caracteres; C : Character) is
	begin
		D.T(C).Occurrence := D.T(C).Occurrence +1;
	end New_Occurrence;

	-- Associe un code a un caractere
	procedure Set_Code(C : in Character; Code : in Code_Binaire; D : in out Dico_Caracteres) is
	begin
		D.T(C).Code := Code;
	end Set_Code;

	-- Associe les infos associees a un caractere
	-- (operation plus generale, si necessaire)
	procedure Set_Infos(C : in Character; Infos : in Info_Caractere; D : in out Dico_Caracteres) is
	begin
		D.T(C).all := Infos.all;	-- Eventuellement un appel à Set_Code ?
	end Set_Infos;

-- Acces aux informations sur un caractere

	-- retourne True sur le caractere C est present dans le D
	function Est_Present(C : Character; D : Dico_Caracteres) return Boolean is
	begin
		return D.T(C).Occurrence > 0;	-- When to update this value ?!?
	end Est_Present;

	-- Retourne le nombre d'occurence d'un caractere
	function Get_Occurrence(D : in Dico_Caracteres; C : Character) return Integer is
	begin
		return D.T(C).Occurrence;
	end Get_Occurrence;

	-- Retourne le code binaire d'un caractere
	--  -> leve l'exception Caractere_Absent si C n'est pas dans D
	function Get_Code(C : Character; D : Dico_Caracteres) return Code_Binaire is
	begin
		if Est_Present(C, D) then
			return D.T(C).Code;
		else
			Put_Line("Le caractère est absent.");
			raise Caractere_Absent;
	end Get_Code;

	-- Retourne les infos associees a un caractere
	--  -> leve l'exception Caractere_Absent si C n'est pas dans D
	function Get_Infos(C : Character; D : Dico_Caracteres) return Info_Caractere is
	begin
		if Est_Present(C, D) then
			return D.T(C);
		else
			Put_Line("Le caractère est absent.");
			raise Caractere_Absent;
	end Get_Infos;


-- Statistiques sur le dictionnaire (au besoin)

	-- Retourne le nombre de caracteres differents dans D
	function Nb_Caracteres_Differents(D : in Dico_Caracteres) return Natural is

	begin

	end Nb_Caracteres_Differents;

	-- Retourne le nombre total de caracteres
	--  =  somme des nombre d'occurences de tous les caracteres de D
	function Nb_Total_Caracteres(D : in Dico_Caracteres) return Natural is
		Nb: Natural := 0;
	begin
		for I in 0..D.T'Last loop
			Nb := Nb + D.T(I).Occurrence;
		end loop;
	end Nb_Total_Caracteres;

end Dico;