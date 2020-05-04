SOURCE=$(wildcard *.pas)
BIN=.\bin
OBJ=$(patsubst %.pas, %.o, $(SOURCE))
FLAG=-FE$(BIN)

All: $(SOURCE)

$(SOURCE): .MKDIR $@
	fpc $@ $(FLAG)

#Game: .MKDIR game.pas
#	fpc game.pas $(FLAG)

#Program: .MKDIR Program1.10.pas
#	fpc Program1.10.Pas $(FLAG)

Clear:
	@echo $(OBJ)

.MKDIR:
	@if not exist $(BIN) mkdir $(BIN)


	