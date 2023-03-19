SRC := $(addprefix src/, MMS_4num.v MMS_8num.v MMS_tb.v)
EXE := mms
VCD := mytest.vcd
ZIP := HW1_NN6124030_施宇庭.zip

.PHONY: all clean view run format submit

all: run

$(EXE): $(SRC)
	iverilog -o $@ $^

run: $(EXE)
	vvp $<

view: $(VCD)
	open -a gtkwave $<

format: $(SRC)
	istyle $^

clean:
	-@$(RM) -rv $(EXE) $(ZIP)

submit: $(ZIP)

$(ZIP): src doc 
	zip -r $@ $^ -x *.doc* -x *tb.v
