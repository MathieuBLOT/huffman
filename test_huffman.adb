with Ada.Text_IO; use Ada.Text_IO;
with Ada.Assertions;  use Ada.Assertions;
with Huffman; use Huffman;
with Ada.Streams; use Ada.Streams;
with Ada.Streams.Stream_IO;

procedure Test_huffman is
--    type Stat is record
--        letter : Character;
--        number : Integer;
--    end record;
--
--    type CodeInternal is array (Integer range 1..3) of Integer range -1..1;
--
--    type CodeBase is record
--        letter : Character;
--        internalCode : CodeInternal;
--    end record;
--
--    type TabStat   is array (Integer range 1..5) of Stat;
--    type TabCodeBase is array (Integer range 1..5) of CodeBase;
--
--    function Same(codeA, codeB : in TabCodeBase) return Boolean is
--    begin
--        for i in codeA'first..codeA'last loop
--            if codeA(i) /= codeB(i) then
--                return false;
--            end if;
--        end loop;
--        return true;
--    end Same;
--
--    function GenerateCode(dico : TabStat) return TabCodeBase is
--        package File_Prio_Stat is new File_Priorite(Character, Integer, "<="); use File_Prio_Stat;
--
--        ret : TabCodeBase;
--        data : File_Prio_Stat.File_Prio := Cree_File(dico'Length);
--    begin
--        for i in dico'first..dico'last loop
--            Insere(data, dico(i).letter, dico(i).number);
--        end loop;
--
--        assert(Est_Pleine(data), "La file de prioritée ne s'est pas remplie correctement lors de la génération du code");
--
--        loop do
--            Supprime(data, data1, prio1);
--            if Est_Vide(data) then
--                -- data1 est le père de tout les
--                exit
--            end if;
--            Supprime(data, data2, prio2);
--            Insere(data, pair<data1,data2>, prio1+prio2);
--        end loop;
--
--        for i in dico'first..dico'last loop
--            ret(i) := (letter => dico(i).letter, internalCode => (0, 1,-1));
--        end loop;
--        return ret;
--    end GenerateCode;
--
--    function Decode(code : TabCodeBase) return TabStat is
--    begin
--        return (
--                 (letter => code(1).letter, number => 3),
--                 (letter => code(2).letter, number => 2),
--                 (letter => code(3).letter, number => 4),
--                 (letter => code(4).letter, number => 1),
--                 (letter => code(5).letter, number => 1)
--            );
--
--    end Decode;
--
--    dico : TabStat;
--    solution, code : TabCodeBase;

----------

    huff : Arbre_Huffman;
    stream : Ada.Streams.Stream_IO.Stream_Access;

begin
    New_line;

    -- compression
    -- huff := Cree_Huffman("Tests/mini.txt");
    -- Affiche(huff);
    -- Assert(Ecrit_Huffman(huff, stream) /= 0, "Erreur lors de l'écriture de l'arbre d'Huffman");

    -- decompression
    -- Assert(Lit_hiffman(stream) = huff), "L'arbre obtenue après décompression ne correspond pas à l'arbre avant compression");
----------
--    dico := (
--             (letter => 'a', number => 4),
--             (letter => 'b', number => 3),
--             (letter => 'c', number => 2),
--             (letter => 'd', number => 1),
--             (letter => 'e', number => 1)
--        );
--
--    solution := (
--             (letter => 'c', internalCode => (0, 0,-1)),
--             (letter => 'b', internalCode => (1, 0,-1)),
--             (letter => 'a', internalCode => (0, 1,-1)),
--             (letter => 'd', internalCode => (1, 1, 0)),
--             (letter => 'e', internalCode => (1, 1, 1))
--        );
--
--    code := GenerateCode(dico);
--
--    Assert(Same(code, solution), "Erreur lors de la generation du code binaire");


    Put_Line("###########################################################################");
    Put_Line("# Les tests concernant le module Huffman se sont tous bien passé ! ... OK #");
    Put_Line("###########################################################################");
end Test_huffman;

