with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Assertions;  use Ada.Assertions;
with code; use code;

procedure test_code is
    code, code1, code2, code3 : Code_Binaire;
    str_code : Unbounded_string;
    i : Integer;
    it : Iterateur_Code;
    b : Bit; -- Pour pouvoir ignorer le retour de la fonction Next(it)
begin
    New_Line;

    code := Cree_Code;
    Ajoute_Apres(ZERO, code);
    Ajoute_Apres(ZERO, code);
    Ajoute_Apres(UN, code);
    Ajoute_Apres(ZERO, code);
    str_code := To_Unbounded_String(code);
    Assert(str_code = "0010", "Ajoute_Apres : " & To_String(str_code) & " au lieu de 0010");

    i := 0;
    it := Cree_Iterateur(code);
    while Has_Next(it) loop
        i := i + 1;
        b := Next(it);
    end loop;
    Assert(i = 4, "Nombre de Bit dans le code, compté avec un itérateur : " & Integer'Image(i) & " au lieu de 4");

    code1 := Cree_Code(code);
    str_code := To_Unbounded_String(code1);
    Assert(str_code = "0010", "Copy : " & To_String(str_code) & " au lieu de 0010");

    code2 := Cree_Code;
    Ajoute_Avant(ZERO, code2);
    Ajoute_Avant(UN, code2);
    Ajoute_Avant(ZERO, code2);
    Ajoute_Avant(ZERO, code2);
    str_code := To_Unbounded_String(code2);
    Assert(str_code = "0010", "Ajoute_Avant : " & To_String(str_code) & " au lieu de 0010");

    code3 := Cree_Code;
    Ajoute_Apres(UN, code3);
    Ajoute_Apres(UN, code3);
    Ajoute_Apres(UN, code3);
    Ajoute_Apres(code2, code3);
    str_code := To_Unbounded_String(code3);
    Assert(str_code = "1110010", "Ajoute_apres(Code, Code) : " & To_String(str_code)
            & " au lieu de 1110010");

    Put_Line("########################################################################");
    Put_Line("# Les tests concernant le module Code se sont tous bien passé ! ... OK #");
    Put_Line("########################################################################");
end test_code;
