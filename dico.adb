with Ada.Integer_Text_IO, Ada.Text_IO, Ada.Unchecked_Deallocation;
use Ada.Integer_Text_IO, Ada.Text_IO;

package body Dico is

	-- Cree un dictionnaire D, initialement vide
	function Cree_Dico return Dico_Caracteres is

	begin

	end Cree_Dico;

	-- Libere le dictionnaire D
	-- garantit: en sortie toute la memoire a ete libere, et D = null.
	procedure Libere(D : in out Dico_Caracteres) is

	begin

	end Libere;

	-- Affiche pour chaque caractere: son nombre d'occurences et son code
	-- (s'il a ete genere)
	procedure Affiche(D : in Dico_Caracteres) is

	begin

	end Affiche;


-- Ajouts d'informations dans le dictionnaire

	-- Associe un code a un caractere
	procedure Set_Code(C : in Character; Code : in Code_Binaire; D : in out Dico_Caracteres) is

	begin

	end Set_Code;

	-- Associe les infos associees a un caractere
	-- (operation plus generale, si necessaire)
	procedure Set_Infos(C : in Character; Infos : in Info_Caractere; D : in out Dico_Caracteres) is

	begin

	end Set_Infos;

-- Acces aux informations sur un caractere

	-- retourne True sur le caractere C est present dans le D
	function Est_Present(C : Character; D : Dico_Caracteres) return Boolean is

	begin

	end Est_Present;

	-- Retourne le code binaire d'un caractere
	--  -> leve l'exception Caractere_Absent si C n'est pas dans D
	function Get_Code(C : Character; D : Dico_Caracteres) return Code_Binaire is

	begin

	end Get_Code;

	-- Retourne les infos associees a un caractere
	--  -> leve l'exception Caractere_Absent si C n'est pas dans D
	function Get_Infos(C : Character; D : Dico_Caracteres) return Info_Caractere is

	begin

	end Get_Infos;


-- Statistiques sur le dictionnaire (au besoin)

	-- Retourne le nombre de caracteres differents dans D
	function Nb_Caracteres_Differents(D : in Dico_Caracteres) return Natural is

	begin

	end Nb_Caracteres_Differents;

	-- Retourne le nombre total de caracteres
	--  =  somme des nombre d'occurences de tous les caracteres de D
	function Nb_Total_Caracteres(D : in Dico_Caracteres) return Natural is

	begin

	end Nb_Total_Caracteres;

end Dico;