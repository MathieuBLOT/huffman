
CFLAGS = -g -gnata -gnatf -gnatwa -gnatVa -gnat2012 -Wall -E -gnateE # -gnatwe -gnaty3abcdefhiklmnoOprstux -O2
	# -gnato13
             #-fstack-check                 --  Generate stack checking code (part of Ada)
             #-gnata                        --  Enable assertions            (part of Ada)
             #-gnato13                      --  Overflow checking            (part of Ada)
             #-gnatf                        --  Full, verbose error messages
             #-gnatwa                       --  All optional warnings
             #-gnatVa                       --  All validity checks
             #-gnaty3abcdefhiklmnoOprstux   --  Style checks
             #-gnatwe                       --  Treat warnings as errors
             #-gnat2012                     --  Use Ada 2012
             #-Wall                         --  All GCC warnings
             #-O2                           --  Optimise (level 2/3)
			 #-E                            --  Store tracebacks

SRC_PACKAGES = dico.ads dico.adb \
               code.ads code.adb \
               file_priorite.ads file_priorite.adb \
               huffman.ads huffman.adb

EXE = exemple_io tp_huffman
TESTS = test_code test_huffman test_file_priorite

all: $(EXE)

make_tests : $(TESTS)

exe_tests : make_tests
	./test_code
	./test_huffman
	./test_file_priorite


################################################################################
# Programmes

tp_huffman: tp_huffman.adb $(SRC_PACKAGES)
	gnatmake $(CFLAGS) $@

exemple_io: exemple_io.adb
	gnatmake $(CFLAGS) $@

################################################################################
# Tests

test_code: test_code.adb clean
	gnatmake $(CFLAGS) $@

test_huffman: test_huffman.adb clean
	gnatmake $(CFLAGS) $@

test_file_priorite: test_file_priorite.adb clean
	gnatmake $(CFLAGS) $@

################################################################################
# divers

.PHONY: clean cleanall

clean:
	gnatclean -c *
	rm -f b~* ~*

cleanall: clean
	rm -f $(EXE) $(TESTS) exemple_io.txt *~

