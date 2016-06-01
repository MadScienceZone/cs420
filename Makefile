MODPATH=../../grace/minigrace:../../grace/minigrace/modules
OBJECTS=formatting.gso ifiction.gso parser.gso rooms.gso
TESTOBJ=formatting_test.gso parser_test.gso room_test.gso

all: ifiction 

tests: formatting_test parser_test room_test
	GRACE_MODULE_PATH=$(MODPATH) ./parser_test
	GRACE_MODULE_PATH=$(MODPATH) ./formatting_test
	GRACE_MODULE_PATH=$(MODPATH) ./room_test

room_test: room_test.gso rooms.gso
formatting_test: formatting.gso formatting_test.gso
parser_test: parser.gso parser_test.gso

ifiction: $(OBJECTS)
	GRACE_MODULE_PATH=$(MODPATH) minigrace $<
	
%.gso: %.grace
	GRACE_MODULE_PATH=$(MODPATH) minigrace $<

clean:
	rm -f *.aux *.dvi *.log *.gso *.gso.dSYM *.gct *.gcn *.c

%.pdf: %.tex 
	pdflatex $<
