with Ada.Integer_Text_IO, Ada.Text_IO, Ada.Unchecked_Deallocation;
--use Ada.Integer_Text_IO, Ada.Text_IO;

package body File_Priorite is

	type Element_Tas is record
		Value: Donnee;
		Prio: Priorite;
	end record;

	type Tab is array (Integer range <>) of Element_Tas;

	type File_Interne(Size: Positive) is record
		Nombre: Integer;	-- Number of current elements in the file
		T: Tab(1..Size);
	end record;

	procedure Libere is new Ada.Unchecked_Deallocation (File_Interne, File_Prio);
	procedure Swap2(E1, E2 : in out Element_Tas);

--------------------------------------------------------------------------------

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
		return F.Nombre = 0;
	end Est_Vide;

	-- retourne True si la file est pleine, False sinon
	function Est_Pleine(F: in File_Prio) return Boolean is
	begin
-- 		return F.Nombre = F.T'Length;
		return F.Nombre = F.T'Last;	-- Au choix...
	end Est_Pleine;

    function Contient(F : in File_Prio; D : in Donnee) return Boolean is
    begin
        for i in F.T'First .. F.T'First + F.Nombre - 1 loop
            if F.T(i).Value = D then
                return true;
            end if;
        end loop;
        return false;
    end Contient;

	-- A NE PAS METTRE DANS L'API !
	-- factorisation d'un échange entre 2 éléments de la file de priorité ;
	--   on décide s'il faut faire l'échange en amont.
	procedure Swap2(E1, E2 : in out Element_Tas) is
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

			while Index > F.T'First
                    AND THEN Est_Prioritaire(F.T(Index).Prio, F.T(Index/2).Prio) loop
				Swap2(F.T(Index), F.T(Index/2));
				Index := Index/2;
			end loop;
		else
-- 			Put_Line("La file est pleine.");	-- En attendant
			raise File_Prio_Pleine;
		end if;
	end Insere;

	-- si not Est_Vide(F)
	--   supprime la donnee la plus prioritaire de F.
	--   sortie: D est la donnee, P sa priorite
	-- sinon
	--   leve l'exception File_Vide
	procedure Supprime(F: in File_Prio; D: out Donnee; P: out Priorite) is
		Index: Integer := F.T'First;	-- The algorithm begins at the root
        fg_est_prio, fd_est_prio, fg_existe, fd_existe: Boolean;
        begin
        if NOT Est_Vide(F) then
            D := F.T(F.T'First).Value;
            P := F.T(F.T'First).Prio;

            Swap2(F.T(F.T'First), F.T(F.Nombre));

            F.Nombre := F.Nombre - 1;
            -- Until it is a leaf					    -- Left son should cliimb
            -- Check the right son belongs to the heap	-- Right son should climb
            loop
                fg_existe := 2*Index     < F.T'First + F.Nombre;
                fd_existe := 2*Index + 1 < F.T'First + F.Nombre;

                fg_est_prio := fg_existe and then Est_Prioritaire(F.T(2*Index).Prio, F.T(Index).Prio);
                fd_est_prio := fd_existe and then Est_Prioritaire(F.T(2*Index + 1).Prio, F.T(Index).Prio);

                if fg_existe then
                    if fd_existe then
                        if Est_Prioritaire(F.T(2*Index).Prio, F.T(2*Index + 1).Prio) then
                            Swap2(F.T(Index), F.T(2*Index));
                            Index := 2*Index;
                        else
                            Swap2(F.T(Index), F.T(2*Index + 1));
                            Index := 2*Index + 1;
                        end if;
                    else
                        exit;
                    end if;
                else
                    if fg_est_prio then
                        Swap2(F.T(Index), F.T(2*Index));
                    end if;
                    exit;
                end if;
			end loop;
		else
			raise File_Prio_Vide;
		end if;
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
-- 			Put_Line("La file est vide.");	-- En attendant
			raise File_Prio_Vide;
		end if;
	end Prochain;

end File_Priorite;
