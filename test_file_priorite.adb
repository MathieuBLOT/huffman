with Ada.Integer_Text_IO, Ada.Text_IO, File_Priorite;
use Ada.Integer_Text_IO, Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Assertions;  use Ada.Assertions;

procedure Test_File_Priorite is
    package Priority_Queue is new File_Priorite(
        Character,
        Integer,
        ">");

    L: Priority_Queue.File_Prio := Priority_Queue.Cree_File(10);
    Di: Integer := Character'Pos('A');
    Dc: Character;
    P: Integer := 1;

begin
    New_Line;

    -- On ajoute des lettre de 'a' à 'j' de prioritée 1..10
    while NOT Priority_Queue.Est_Pleine(L) loop
        Priority_Queue.Insere(L, Character'Val(Di), P);
        Di := Di + 1;
        P := P + 1;
    end loop;

--------------------------------------------------------------------------------

    Priority_Queue.Prochain(L, Dc, P);
    Assert(Dc = 'J' and then P = 10,
            "Test de la procedure Prochain : Le premier élément de la file " &
            "(prochain à sortir) est : " & Dc & ", " & Integer'Image(P) &
            " au lieu de J, 10");

--------------------------------------------------------------------------------

    begin
        Priority_Queue.Insere(L, 'Z', 100);
        Assert(false, "On teste si l'on peut ajouter une autre valeur, " &
                "et l'exception 'File_Prio_Pleine' ne marche pas !");
    exception
        when Priority_Queue.File_Prio_Pleine
        => null; -- L'exception 'File_Prio_Pleine' marche !
        when others
        => Assert(false, "On teste si l'on peut ajouter une autre valeur, " &
                "et l'exception 'File_Prio_Pleine' ne marche pas !");
    end;

--------------------------------------------------------------------------------

    Put_Line("****************************************");
    Put_Line("Voici la liste, triée par ordre de priorité :");
    while NOT Priority_Queue.Est_Vide(L) loop
        Priority_Queue.Supprime(L, Dc, P);
        Put_Line("L'élément sorti de la file est : " & Dc & ", " & Integer'Image(P));
        Assert(not Priority_Queue.Contient(L, Dc), "L'élément n'est pas correctement supprimé de la file");
    end loop;
    Put_Line("****************************************");

--------------------------------------------------------------------------------

    begin
        Priority_Queue.Supprime(L, Dc, P);
        Assert(false, "L'exception 'File_Prio_Vide' ne marche pas. " &
                "Il n'y a rien a sortir normalement...: " & Dc & ", " & Integer'Image(P));
    exception
        when Priority_Queue.File_Prio_Vide
        => null; -- L'exception 'File_Prio_Vide' marche !
    end;

--------------------------------------------------------------------------------

    begin
        Priority_Queue.Prochain(L, Dc, P);
        Assert(false, "Il n'y a pas de prochain normalement ou l'exception " &
                "File_Prio_Vide ne marche pas" & Dc & ", " & Integer'Image(P));
    exception
        when Priority_Queue.File_Prio_Vide
        => null; -- L'exception 'File_Prio_Vide' marche !"
    end;

--------------------------------------------------------------------------------

    begin
        Priority_Queue.Insere(L, 'b', 2);
        Priority_Queue.Insere(L, 'c', 3);
        Priority_Queue.Supprime(L, Dc, P);
        Assert(Dc = 'c' and then P = 3,
                "Ce n'est pas le bon élément qui est sortie de la file : "
                & Character'Image(Dc) & " " & Integer'Image(P));
        Priority_Queue.Supprime(L, Dc, P);
        Assert(Dc = 'b' and then P = 2,
                "Ce n'est pas le bon élément qui est sortie de la file : "
                & Character'Image(Dc) & " " & Integer'Image(P));
        Priority_Queue.Insere(L, 'e', 5);
        Priority_Queue.Insere(L, 'd', 4);
        Priority_Queue.Supprime(L, Dc, P);
        Assert(Dc = 'e' and then P = 5,
                "Ce n'est pas le bon élément qui est sortie de la file : "
                & Character'Image(Dc) & " " & Integer'Image(P));
        Priority_Queue.Insere(L, 'a', 1);
        Priority_Queue.Supprime(L, Dc, P);
        Assert(Dc = 'd' and then P = 4,
                "Ce n'est pas le bon élément qui est sortie de la file : "
                & Character'Image(Dc) & " " & Integer'Image(P));
        Priority_Queue.Supprime(L, Dc, P);
        Assert(Dc = 'a' and then P = 1,
                "Ce n'est pas le bon élément qui est sortie de la file : "
                & Character'Image(Dc) & " " & Integer'Image(P));
        Assert(Priority_Queue.Est_Vide(L), "La file devrait être vide");
    end;

--------------------------------------------------------------------------------

    declare
        package Croissant is new File_Priorite(
            Character,
            Integer,
            "<");
        L2: Croissant.File_Prio := Croissant.Cree_File(10);
    begin
        Croissant.Insere(L2, 'a', 3);
        Croissant.Insere(L2, 'b', 4);
        Croissant.Insere(L2, 'c', 5);
        Croissant.Insere(L2, 'd', 6);
        Croissant.Insere(L2, 'e', 7);

        Croissant.Supprime(L2, Dc, P);
        Assert(Dc = 'a' and then P = 3,
                "Assert(Dc = 'a' and then P = 3" & " --- " &
                "Ce n'est pas le bon élément qui est sortie de la file : "
                & Character'Image(Dc) & " " & Integer'Image(P));
        Croissant.Supprime(L2, Dc, P);
        Assert(Dc = 'b' and then P = 4,
                "Assert(Dc = 'b' and then P = 4" & " --- " &
                "Ce n'est pas le bon élément qui est sortie de la file : "
                & Character'Image(Dc) & " " & Integer'Image(P));
        Croissant.Insere(L2, 'A', 7);

        Croissant.Supprime(L2, Dc, P);
        Assert(Dc = 'c' and then P = 5,
                "Assert(Dc = 'c' and then P = 5" & " --- " &
                "Ce n'est pas le bon élément qui est sortie de la file : "
                & Character'Image(Dc) & " " & Integer'Image(P));
        Croissant.Supprime(L2, Dc, P);
        Assert(Dc = 'd' and then P = 6,
                "Assert(Dc = 'd' and then P = 6" & " --- " &
                "Ce n'est pas le bon élément qui est sortie de la file : "
                & Character'Image(Dc) & " " & Integer'Image(P));
        Croissant.Insere(L2, 'C', 11);

        Croissant.Supprime(L2, Dc, P);
        Assert(Dc = 'A' and then P = 7,
                "Assert(Dc = 'A' and then P = 7" & " --- " &
                "Ce n'est pas le bon élément qui est sortie de la file : "
                & Character'Image(Dc) & " " & Integer'Image(P));
        Croissant.Supprime(L2, Dc, P);
        Assert(Dc = 'e' and then P = 7,
                "Assert(Dc = 'e' and then P = 7" & " --- " &
                "Ce n'est pas le bon élément qui est sortie de la file : "
                & Character'Image(Dc) & " " & Integer'Image(P));
        Croissant.Insere(L2, 'A', 14);

        Croissant.Supprime(L2, Dc, P);
        Assert(Dc = 'C' and then P = 11,
                "Assert(Dc = 'C' and then P = 11" & " --- " &
                "Ce n'est pas le bon élément qui est sortie de la file : "
                & Character'Image(Dc) & " " & Integer'Image(P));
        Croissant.Supprime(L2, Dc, P);
        Assert(Dc = 'A' and then P = 14,
                "Assert(Dc = 'E' and then P = 14" & " --- " &
                "Ce n'est pas le bon élément qui est sortie de la file : "
                & Character'Image(Dc) & " " & Integer'Image(P));
        Croissant.Insere(L2, 'C', 25);

        Croissant.Supprime(L2, Dc, P);
        Assert(Dc = 'C' and then P = 25,
                "Assert(Dc = 'C' and then P = 25" & " --- " &
                "Ce n'est pas le bon élément qui est sortie de la file : "
                & Character'Image(Dc) & " " & Integer'Image(P));

        Assert(Croissant.Est_Vide(L2), "La file devrait être vide");
        Croissant.Libere_File(L2);
    end;
--------------------------------------------------------------------------------

    Priority_Queue.Libere_File(L);

    Put_Line("###########################################################################");
    Put_Line("# Les tests concernant les File_Priorite se sont tous bien passé ! ... OK #");
    Put_Line("###########################################################################");
end;
