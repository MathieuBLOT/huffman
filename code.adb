with Ada.Unchecked_Deallocation;

package body Code is

    type Code_Binaire_Interne is record
        value: Bit;
        next: Code_Binaire;
    end record;

    type Iterateur_Code_Interne is record
        iter: access Code_Binaire_Interne;
    end record;

    procedure Libere is new Ada.Unchecked_Deallocation(Code_Binaire_Interne,
                Code_Binaire);
    procedure Libere is new Ada.Unchecked_Deallocation(Iterateur_Code_Interne,
                Iterateur_Code);

    function To_String(B : in Bit) return String;

-------------------------------------------------------------------------------

    -- Cree un code initialement vide
    function Cree_Code return Code_Binaire is
    begin
        return null;
    end Cree_Code;

    -- Copie un code existant
    function Cree_Code(C : in Code_Binaire) return Code_Binaire is
        it : constant Iterateur_Code := Cree_Iterateur(C);
        copy : Code_Binaire := Cree_Code;
    begin
        if C = null then
            return null;
        end if;

        -- Ce n'est pas performant du tout : parcourt en O(n^2)
        loop
            Ajoute_Apres(Next(it), copy);
            exit when not Has_Next(it);
        end loop;

        return copy;
    end Cree_Code;

    -- Libere un code
    procedure Libere_Code(C : in out Code_Binaire) is
    begin
        if C /= null then
            Libere_Code(C.next);
            Libere(C);
        end if;
    end Libere_Code;

    -- Retourne le nb de bits d'un code
    function Longueur(C : in Code_Binaire) return Natural is
    begin
        if C /= null then
            return 1 + Longueur(C.next);
        else
            return 0;
        end if;
    end Longueur;

    function To_String(B : in Bit) return String is
        img : constant String := Bit'Image(B);
    begin
        return img(img'last..img'last); -- Bit'Image = " 0" ou " 1", donc on
        -- enlève l'espace.
    end To_String;

    function To_Unbounded_String(C : in Code_Binaire) return Unbounded_string is
        str : Unbounded_string := Null_Unbounded_String;
        it : Code_Binaire := C;
    begin
        while it /= null loop
            Append(str, To_String(it.value));
            it := it.next;
        end loop;
        return str;
    end To_Unbounded_String;

    -- Ajoute le bit B en tete du code C
    procedure Ajoute_Avant(B : in Bit; C : in out Code_Binaire) is
        new_code : constant Code_Binaire := new Code_Binaire_Interne;
    begin
        new_code.value := B;
        new_code.next := C;

        C := new_code;
    end Ajoute_Avant;

    -- Ajoute le bit B en queue du code C
    procedure Ajoute_Apres(B : in Bit; C : in out Code_Binaire) is
        it_prev : Code_Binaire := null;
        it : Code_Binaire := C;
    begin
        if C = null then
            Ajoute_Avant(B, C);
            return;
        end if;

        -- on cherche le dernier élément de la liste
        while it /= null loop
            it_prev := it;
            it := it.next;
        end loop;

        -- on ajoute le nouveau bit
        Ajoute_Avant(B, it);

        -- on complete la chaine
        if it_prev /= null then
            it_prev.next := it;
        else
            C := it;
        end if;
    end Ajoute_Apres;

    -- ajoute les bits de C1 apres ceux de C
    procedure Ajoute_Apres(C1 : in Code_Binaire; C : in out Code_Binaire) is
        it_prev : Code_Binaire := null;
        it : Code_Binaire := C;
    begin
        -- on cherche le dernier élément de la liste
        while it /= null loop
            it_prev := it;
            it := it.next;
        end loop;

        -- on complete la chaine
        if it_prev /= null then
            it_prev.next := C1;
        else
            C := C1;
        end if;
    end Ajoute_Apres;


    -- Cree un iterateur initialise sur le premier bit du code
    function Cree_Iterateur(C : Code_Binaire) return Iterateur_Code is
        new_it : constant Iterateur_Code := new Iterateur_Code_Interne;
    begin
        new_it.iter := C;
        return new_it;
    end Cree_Iterateur;

    -- Libere un iterateur (pas le code parcouru!)
    procedure Libere_Iterateur(It : in out Iterateur_Code) is
    begin
        Libere(It);
    end Libere_Iterateur;

    -- Retourne True s'il reste des bits dans l'iteration
    function Has_Next(It : Iterateur_Code) return Boolean is
    begin
        return It.iter /= null;
    end Has_Next;

    -- Retourne le prochain bit et avance dans l'iteration
    -- Leve l'exception Code_Entierement_Parcouru si Has_Next(It) = False
    function Next(It : Iterateur_Code) return Bit is
        ret : Bit;
    begin
        ret := It.iter.value;
        It.iter := it.iter.next;
        return ret;
    end Next;

end Code;
