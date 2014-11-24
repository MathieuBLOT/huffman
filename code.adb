with Ada.Integer_Text_IO, Ada.Text_IO, Ada.Unchecked_Deallocation;
use Ada.Integer_Text_IO, Ada.Text_IO;

package body Code is

	-- Cree un code initialement vide
	function Cree_Code return Code_Binaire is

	begin

	end Cree_Code;

	-- Copie un code existant
	function Cree_Code(C : in Code_Binaire) return Code_Binaire is

	begin

	end Cree_Code;

	-- Libere un code
	procedure Libere_Code(C : in out Code_Binaire) is

	begin

	end Libere_Code;

	-- Retourne le nb de bits d'un code
	function Longueur(C : in Code_Binaire) return Natural is

	begin

	end Longueur;

	-- Affiche un code
	procedure Affiche(C : in Code_Binaire) is

	begin

	end Affiche;

	-- Ajoute le bit B en tete du code C
	procedure Ajoute_Avant(B : in Bit; C : in out Code_Binaire) is

	begin

	end Ajoute_Avant;

	-- Ajoute le bit B en queue du code C
	procedure Ajoute_Apres(B : in Bit; C : in out Code_Binaire) is

	begin

	end Ajoute_Apres;

	-- ajoute les bits de C1 apres ceux de C
	procedure Ajoute_Apres(C1 : in Code_Binaire; C : in out Code_Binaire) is

	begin

	end Ajoute_Apres;


	-- Cree un iterateur initialise sur le premier bit du code
	function Cree_Iterateur(C : Code_Binaire) return Iterateur_Code is

	begin

	end Cree_Iterateur;

	-- Libere un iterateur (pas le code parcouru!)
	procedure Libere_Iterateur(It : in out Iterateur_Code) is

	begin

	end Libere_Iterateur;

	-- Retourne True s'il reste des bits dans l'iteration
	function Has_Next(It : Iterateur_Code) return Boolean is

	begin

	end Has_Next;

	-- Retourne le prochain bit et avance dans l'iteration
	-- Leve l'exception Code_Entierement_Parcouru si Has_Next(It) = False
	function Next(It : Iterateur_Code) return Bit is

	begin

	end Next;

end Code;