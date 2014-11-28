with Ada.Integer_Text_IO, Ada.Text_IO, Ada.Unchecked_Deallocation;
use Ada.Integer_Text_IO, Ada.Text_IO;

package body File_Priorite is

-- 	Erreur_File_Vide, Erreur_File_Pleine: Exception;

	procedure Libere is new Ada.Unchecked_Deallocation (File_Interne, File_Prio);

	type Element_Tas is record
		Value: Donnee;
		Prio: Priorite;
	end record;

	type Tab is array (Integer range <>) of Element_Tas;

	type File_Interne(Size: Positive) is record
		Nombre: Integer;	-- Number of current elements in the file
		T: Tab(1..Size);
	end record;

	-- Cree et retourne une nouvelle file, initialement vide
	-- et de capacite maximale Capacite
	function Cree_File(Capacite: Positive) return File_Prio is
		F: File_Prio;
	begin
		F := new File_Interne(Capacite);
		F.Nombre := 0;
		return F;
	end Cree_File;

	-- Libere une file de priorite.
	-- garantit: en sortie toute la memoire a ete libere, et F = null.
	procedure Libere_File(F : in out File_Prio) is
	begin
		Libere(F);
		F := null;
	end Libere_File;

	-- retourne True si la file est vide, False sinon
	function Est_Vide(F: in File_Prio) return Boolean is
	begin
		return F = null;
-- 		return F.Nombre = 0;	-- Au choix...
	end Est_Vide:

	-- retourne True si la file est pleine, False sinon
	function Est_Pleine(F: in File_Prio) return Boolean is
	begin
		return F.Nombre = F.T'Length;
	end Est_Pleine;

	-- A NE PAS METTRE DANS L'API !
	-- factorisation d'un échange entre 2 éléments de la file de priorité ;
	--   on décide s'il faut faire l'échange en amont.
	procedure Swap2(E1, E2 : Element_Tas) is
		TmpD: Donnee := E1.Value;
		TmpP: Priorite := E1.Prio;
	begin
		E1.Value := E2.Value;
		E1.Prio := E2.Prio;
		E2.Value := TmpD;
		E2.Prio := TmpP;
	end Swap2;

	-- si not Est_Pleine(F)
	--   insere la donnee D de priorite P dans la file F
	-- sinon
	--   leve l'exception File_Pleine
	procedure Insere(F : in File_Prio; D : in Donnee; P : in Priorite) is
		Index: Integer := F.Nombre + 1;
	begin
		if NOT Est_Pleine(F) then
			F.Nombre := Index;
			F.T(F.Nombre).Value := D;
			F.T(F.Nombre).Prio := P;

			while Index /= 1 AND THEN F.T(Index).Prio > F.T(Index/2).Prio loop
				Swap2(F.T(Index), F.T(Index/2));
				Index := Index/2;
			end loop;
		else
			Put_Line("La file est pleine.");	-- En attendant
			raise Erreur_File_Pleine;
	end Insere;

	-- si not Est_Vide(F)
	--   supprime la donnee la plus prioritaire de F.
	--   sortie: D est la donnee, P sa priorite
	-- sinon
	--   leve l'exception File_Vide
	procedure Supprime(F: in File_Prio; D: out Donnee; P: out Priorite) is
		Index: Integer := 1;	-- The algorithm begins at the root
	begin
		if NOT Est_Vide(F) then
			Swap2(F.T(F.T'First), F.T(F.Nombre));	-- A moins que F.T(F.T'Last) ne soit plus lisible ?

			F.Nombre := F.Nombre - 1;
			-- Until it is a leaf
			while Index <= F.Nombre/2 AND THEN (F.T(Index).Prio < F.T(2*Index).Prio OR F.T(Index).Prio < F.T(2*Index + 1).Prio) loop
				if F.T(Index).Prio < F.T(2*Index).Prio then
					Swap2(F.T(Index), F.T(2*Index));
					Index := 2*Index;
				else
					Swap2(F.T(Index), F.T(2*Index + 1));
					Index := 2*Index + 1;
				end if;
			end loop;
		else
			Put_Line("La file est vide.");	-- En attendant
			raise Erreur_File_Vide;
	end Supprime;

	-- si not Est_Vide(F)
	--   retourne la donnee la plus prioritaire de F (sans la
	--   sortir de la file)
	--   sortie: D est la donnee, P sa priorite
	-- sinon
	--   leve l'exception File_Vide
	procedure Prochain(F: in File_Prio; D: out Donnee; P: out Priorite) is
	begin
		if NOT Est_Vide(F) then
			D := F.T(F.T'First).Value;
			P := F.T(F.T'First).Prio;
		else
			Put_Line("La file est vide.");	-- En attendant
			raise Erreur_File_Vide;
	end Prochain;

end File_Priorite;