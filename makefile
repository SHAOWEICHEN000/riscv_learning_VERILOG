TOP = complex_tb
SRC = src
SIM = sim
OUT = build/$(TOP).vvp
VCD = wave.vcd

SRCS := $(wildcard $(SRC)/*.v) $(SIM)/$(TOP).v

all: run

run: $(OUT)
	vvp $(OUT)

$(OUT): $(SRCS)
	@mkdir -p build
	iverilog -g2012 -I$(SRC) -o $(OUT) -s $(TOP) $(SRCS)

wave: run


clean:
	rm -rf build $(VCD)

.PHONY: all run wave clean
