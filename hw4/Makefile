SRC := testfixture.v ATCONV.v mac.v mmu.v ctrl.v const.v
EXE := conv.out
VCD := wave.vcd
ZIP := HW4_NN6124030_施宇庭.zip

.PHONY: all clean view run format submit

all: run

$(EXE): $(SRC)
	iverilog -o $@ $^

run: $(EXE)
	vvp $<

view: $(VCD)
	open -a gtkwave $<

format: $(wildcard src/*.v)
	istyle $^

clean:
	-@$(RM) -rv $(EXE) $(ZIP) $(VCD)

submit: $(ZIP)

$(ZIP): src doc 
	zip -r $@ $^ -x *.doc* -x *tb.v
