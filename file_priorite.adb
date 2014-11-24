with Ada.Integer_Text_IO, Ada.Text_IO, Ada.Unchecked_Deallocation;
use Ada.Integer_Text_IO, Ada.Text_IO;

package body File_Priorite is

	-- Cree et retourne une nouvelle file, initialement vide
	-- et de capacite maximale Capacite
	function Cree_File(Capacite: Positive) return File_Prio is

	begin

	end Cree_File;

	-- Libere une file de priorite.
	-- garantit: en sortie toute la memoire a ete libere, et F = null.
	procedure Libere_File(F : in out File_Prio) is

	begin

	end Libere_File;

	-- retourne True si la file est vide, False sinon
	function Est_Vide(F: in File_Prio) return Boolean is

	begin

	end Est_Vide:

	-- retourne True si la file est pleine, False sinon
	function Est_Pleine(F: in File_Prio) return Boolean is

	begin

	end Est_Pleine;

	-- si not Est_Pleine(F)
	--   insere la donnee D de priorite P dans la file F
	-- sinon
	--   leve l'exception File_Pleine
	procedure Insere(F : in File_Prio; D : in Donnee; P : in Priorite) is

	begin

	end Insere;

	-- si not Est_Vide(F)
	--   supprime la donnee la plus prioritaire de F.
	--   sortie: D est la donnee, P sa priorite
	-- sinon
	--   leve l'exception File_Vide
	procedure Supprime(F: in File_Prio; D: out Donnee; P: out Priorite) is

	begin

	end Supprime;

	-- si not Est_Vide(F)
	--   retourne la donnee la plus prioritaire de F (sans la
	--   sortir de la file)
	--   sortie: D est la donnee, P sa priorite
	-- sinon
	--   leve l'exception File_Vide
	procedure Prochain(F: in File_Prio; D: out Donnee; P: out Priorite) is

	begin

	end Prochain;

end File_Priorite;