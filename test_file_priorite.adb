with Ada.Integer_Text_IO, Ada.Text_IO, File_Priorite;
use Ada.Integer_Text_IO, Ada.Text_IO;
with Ada.Unchecked_Deallocation;

procedure Test_File_Priorite is
	package Priority_Queue is new File_Priorite(
		Character,
		Integer,
		">");

	use Priority_Queue;

	L: Priority_Queue.File_Prio := Cree_File(10);
	Di: Integer := Character'Pos('A');
	Dc: Character;
	P: Integer := 1;

begin
	while NOT Est_Pleine(L) loop
		Insere(L, Character'Val(Di), P);
		Di := Di + 1;
		P := P + 1;
	end loop;

--------------------------------------------------------------------------------

	Put_Line("****************************************");
	Put_Line("Test de la procedure Prochain");
	Prochain(L, Dc, P);
	Put_Line("Le premier élément de la file (prochain à sortir) est : " & Dc & ", " & Integer'Image(P));
	-- Doit donner J, 10
	Put_Line("(On devrait obtenir J, 10)");
	Put_Line("****************************************");

--------------------------------------------------------------------------------

	Put_Line("****************************************");
	Put_Line("On teste si l'on peut ajouter une autre valeur :");

	begin
		Insere(L, 'Z', 100);
	exception
		when File_Prio_Pleine
		=> Put_Line("L'exception 'File_Prio_Pleine' marche !");
	end;
	Put_Line("****************************************");

--------------------------------------------------------------------------------

	Put_Line("****************************************");
	Put_Line("Voici la liste, triée par ordre de priorité :");
	while NOT Est_Vide(L) loop
		Supprime(L, Dc, P);
		Put_Line("L'élément sorti de la file est : " & Dc & ", " & Integer'Image(P));
	end loop;
	Put_Line("****************************************");

--------------------------------------------------------------------------------

	Put_Line("****************************************");
	Put_Line("Peut-on encore supprimer ?");
	begin
		Supprime(L, Dc, P);
		Put_Line("Y'a rien a sortir normalement...: " & Dc & ", " & Integer'Image(P));
	exception
		when File_Prio_Vide
		=> Put_Line("L'exception 'File_Prio_Vide' marche !");
	end;
	Put_Line("****************************************");

--- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	Put_Line("****************************************");
	Put_Line("Y a-t-il un prochain ?");
	begin
		Prochain(L, Dc, P);
		Put_Line("Y'a pas de prochain normalement...: " & Dc & ", " & Integer'Image(P));
	exception
		when File_Prio_Vide
		=> Put_Line("L'exception 'File_Prio_Vide' marche !");
	end;
	Put_Line("****************************************");

	Libere_File(L);
end;