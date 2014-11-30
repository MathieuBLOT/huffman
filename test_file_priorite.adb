with Ada.Integer_Text_IO, Ada.Text_IO, File_Priorite;
use Ada.Integer_Text_IO, Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Assertions;  use Ada.Assertions;

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
    New_Line;

    while NOT Est_Pleine(L) loop
        Insere(L, Character'Val(Di), P);
        Di := Di + 1;
        P := P + 1;
    end loop;

--------------------------------------------------------------------------------

    Prochain(L, Dc, P);
    Assert(Dc = 'J' and then P = 10,
            "Test de la procedure Prochain : Le premier élément de la file " &
            "(prochain à sortir) est : " & Dc & ", " & Integer'Image(P) &
            " au lieu de J, 10");

--------------------------------------------------------------------------------

    

    begin
        Insere(L, 'Z', 100);
        Assert(false, "On teste si l'on peut ajouter une autre valeur, " &
                "et l'exception 'File_Prio_Pleine' ne marche pas !");
    exception
        when File_Prio_Pleine
        => null; -- L'exception 'File_Prio_Pleine' marche !
        when others
        => Assert(false, "On teste si l'on peut ajouter une autre valeur, " &
                "et l'exception 'File_Prio_Pleine' ne marche pas !");
    end;

--------------------------------------------------------------------------------

    Put_Line("****************************************");
    Put_Line("Voici la liste, triée par ordre de priorité :");
    while NOT Est_Vide(L) loop
        Supprime(L, Dc, P);
        Put_Line("L'élément sorti de la file est : " & Dc & ", " & Integer'Image(P));
    end loop;
    Put_Line("****************************************");

--------------------------------------------------------------------------------

    begin
        Supprime(L, Dc, P);
        Assert(false, "L'exception 'File_Prio_Vide' ne marche pas. " &
                "Il n'y a rien a sortir normalement...: " & Dc & ", " & Integer'Image(P));
    exception
        when File_Prio_Vide
        => null; -- L'exception 'File_Prio_Vide' marche !
    end;

--- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    begin
        Prochain(L, Dc, P);
        Assert(false, "Il n'y a pas de prochain normalement ou l'exception " &
                "File_Prio_Vide ne marche pas" & Dc & ", " & Integer'Image(P));
    exception
        when File_Prio_Vide
        => null; -- L'exception 'File_Prio_Vide' marche !"
    end;

    Libere_File(L);

    Put_Line("###########################################################################");
    Put_Line("# Les tests concernant les File_Priorite se sont tous bien passé ! ... OK #");
    Put_Line("###########################################################################");
end;
