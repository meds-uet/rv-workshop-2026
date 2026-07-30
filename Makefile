# =============================================================================
# Makefile - RISC-V Single-Cycle Processor Simulation
# Tools required: Icarus Verilog (iverilog, vvp), GTKWave
# =============================================================================

# ---- Directories ------------------------------------------------------------
SRC_DIR   := src
TB_DIR    := testbench
BUILD_DIR := build

# ---- Source file discovery ---------------------------------------------------
# Automatically picks up every .sv file in src/ and testbench/, so renaming or
# adding new modules does not require editing this Makefile.
SRC_FILES := $(wildcard $(SRC_DIR)/*.sv)
TB_FILES  := $(wildcard $(TB_DIR)/*.sv)
ALL_FILES := $(SRC_FILES) $(TB_FILES)

# ---- Tooling ------------------------------------------------------------
IVERILOG       := iverilog
VVP            := vvp
GTKWAVE        := gtkwave
IVERILOG_FLAGS := -g2012 -Wall

# ---- Outputs ------------------------------------------------------------
SIM_OUT  := $(BUILD_DIR)/sim.out
VCD_FILE := processor.vcd

# =============================================================================
# Targets
# =============================================================================
.PHONY: all compile run wave clean help

all: run

help:
	@echo "Available targets:"
	@echo "  make compile  - Compile all RTL + testbench sources with iverilog"
	@echo "  make run      - Compile (if needed) and run the simulation"
	@echo "  make wave     - Run the simulation and open the waveform in GTKWave"
	@echo "  make clean    - Remove build artifacts and waveform dump"

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile all source + testbench files into a single simulation executable.
# iverilog automatically treats any module not instantiated elsewhere as a
# top-level module, so the testbench module is picked up automatically
# regardless of what it's named internally.
compile: $(BUILD_DIR) $(ALL_FILES)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(SIM_OUT) $(ALL_FILES)

# Run the compiled simulation. vvp executes the compiled testbench, which
# will self-check and print PASS/FAIL to the console, and dump processor.vcd.
run: compile
	$(VVP) $(SIM_OUT)

# Run the simulation, then open the resulting waveform in GTKWave.
wave: run
	$(GTKWAVE) $(VCD_FILE) &

# Remove all generated files so you can rebuild from a clean state.
clean:
	rm -rf $(BUILD_DIR) $(VCD_FILE)