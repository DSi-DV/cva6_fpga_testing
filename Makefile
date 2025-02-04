####################################################################################################
# VARIABLES
####################################################################################################

# Define the top module
TOP ?= soc

# Get the root directory
ROOT_DIR = $(shell echo $(realpath .))

# Default goal is to clean
.DEFAULT_GOAL := clean

# Define XVLOG_DEFS
XVLOG_DEFS += -d SIMULATION

# Define a command to grep for WARNING and ERROR messages with color highlighting
GREP_EW := grep -E "WARNING:|ERROR:|" --color=auto

TESTNAME?=default

####################################################################################################
# FILE LISTS
####################################################################################################

# package
FLIST += ${ROOT_DIR}/source/dm_pkg.sv
FLIST += ${ROOT_DIR}/source/riscv_pkg.sv
FLIST += ${ROOT_DIR}/source/ariane_pkg.sv
FLIST += ${ROOT_DIR}/source/axi_pkg.sv
FLIST += ${ROOT_DIR}/source/ariane_axi_pkg.sv
FLIST += ${ROOT_DIR}/source/std_cache_pkg.sv
FLIST += ${ROOT_DIR}/source/cf_math_pkg.sv
FLIST += ${ROOT_DIR}/source/soc_pkg.sv

# common
FLIST += ${ROOT_DIR}/source/stream_register.sv
FLIST += ${ROOT_DIR}/source/spill_register_flushable.sv
FLIST += ${ROOT_DIR}/source/spill_register.sv
FLIST += ${ROOT_DIR}/source/rr_arb_tree.sv
FLIST += ${ROOT_DIR}/source/delta_counter.sv
FLIST += ${ROOT_DIR}/source/counter.sv
FLIST += ${ROOT_DIR}/source/onehot_to_bin.sv
FLIST += ${ROOT_DIR}/source/id_queue.sv

# memory
FLIST += ${ROOT_DIR}/source/generic_memory.sv
FLIST += ${ROOT_DIR}/source/block_memory.sv
FLIST += ${ROOT_DIR}/source/axi_atop_filter.sv
FLIST += ${ROOT_DIR}/source/axi_demux_id_counters.sv
FLIST += ${ROOT_DIR}/source/axi_demux_simple.sv
FLIST += ${ROOT_DIR}/source/axi_demux.sv
FLIST += ${ROOT_DIR}/source/axi_err_slv.sv
FLIST += ${ROOT_DIR}/source/axi_burst_splitter_counters.sv
FLIST += ${ROOT_DIR}/source/axi_burst_splitter_ax_chan.sv
FLIST += ${ROOT_DIR}/source/axi_burst_splitter.sv
FLIST += ${ROOT_DIR}/source/axi_to_axi_lite_id_reflect.sv
FLIST += ${ROOT_DIR}/source/axi_to_axi_lite.sv
FLIST += ${ROOT_DIR}/source/axi_ram.sv
FLIST += ${ROOT_DIR}/source/axi_rom.sv

# axi_xbar
FLIST += ${ROOT_DIR}/source/axi_id_prepend.sv
FLIST += ${ROOT_DIR}/source/axi_mux.sv
FLIST += ${ROOT_DIR}/source/addr_decode_dync.sv
FLIST += ${ROOT_DIR}/source/addr_decode.sv
FLIST += ${ROOT_DIR}/source/axi_cut.sv
FLIST += ${ROOT_DIR}/source/axi_multicut.sv
FLIST += ${ROOT_DIR}/source/axi_xbar_unmuxed.sv
FLIST += ${ROOT_DIR}/source/axi_xbar.sv

# block_memory_tb
FLIST += ${ROOT_DIR}/source/block_memory_tb.sv

# ariane
FLIST += ${ROOT_DIR}/source/ras.sv
FLIST += ${ROOT_DIR}/source/btb.sv
FLIST += ${ROOT_DIR}/source/bht.sv
FLIST += ${ROOT_DIR}/source/instr_scan.sv
FLIST += ${ROOT_DIR}/source/fifo_v3.sv
FLIST += ${ROOT_DIR}/source/fifo_v2.sv
FLIST += ${ROOT_DIR}/source/frontend.sv
FLIST += ${ROOT_DIR}/source/instr_realigner.sv
FLIST += ${ROOT_DIR}/source/compressed_decoder.sv
FLIST += ${ROOT_DIR}/source/decoder.sv
FLIST += ${ROOT_DIR}/source/id_stage.sv
FLIST += ${ROOT_DIR}/source/re_name.sv
FLIST += ${ROOT_DIR}/source/scoreboard.sv
FLIST += ${ROOT_DIR}/source/ariane_regfile.sv
FLIST += ${ROOT_DIR}/source/issue_read_operands.sv
FLIST += ${ROOT_DIR}/source/issue_stage.sv
FLIST += ${ROOT_DIR}/source/alu.sv
FLIST += ${ROOT_DIR}/source/branch_unit.sv
FLIST += ${ROOT_DIR}/source/csr_buffer.sv
FLIST += ${ROOT_DIR}/source/multiplier.sv
FLIST += ${ROOT_DIR}/source/lzc.sv
FLIST += ${ROOT_DIR}/source/serdiv.sv
FLIST += ${ROOT_DIR}/source/mult.sv
FLIST += ${ROOT_DIR}/source/tlb.sv
FLIST += ${ROOT_DIR}/source/ptw.sv
FLIST += ${ROOT_DIR}/source/mmu.sv
FLIST += ${ROOT_DIR}/source/store_buffer.sv
FLIST += ${ROOT_DIR}/source/amo_buffer.sv
FLIST += ${ROOT_DIR}/source/store_unit.sv
FLIST += ${ROOT_DIR}/source/load_unit.sv
FLIST += ${ROOT_DIR}/source/pipe_reg_simple.sv
FLIST += ${ROOT_DIR}/source/lsu_bypass.sv
FLIST += ${ROOT_DIR}/source/load_store_unit.sv
FLIST += ${ROOT_DIR}/source/ex_stage.sv
FLIST += ${ROOT_DIR}/source/commit_stage.sv
FLIST += ${ROOT_DIR}/source/csr_regfile.sv
FLIST += ${ROOT_DIR}/source/perf_counters.sv
FLIST += ${ROOT_DIR}/source/controller.sv
FLIST += ${ROOT_DIR}/source/SyncSpRamBeNx64.sv
FLIST += ${ROOT_DIR}/source/sram.sv
FLIST += ${ROOT_DIR}/source/lfsr_8bit.sv
FLIST += ${ROOT_DIR}/source/std_icache.sv
FLIST += ${ROOT_DIR}/source/cache_ctrl.sv
FLIST += ${ROOT_DIR}/source/arbiter.sv
FLIST += ${ROOT_DIR}/source/axi_adapter.sv
FLIST += ${ROOT_DIR}/source/amo_alu.sv
FLIST += ${ROOT_DIR}/source/miss_handler.sv
FLIST += ${ROOT_DIR}/source/tag_cmp.sv
FLIST += ${ROOT_DIR}/source/std_nbdcache.sv
FLIST += ${ROOT_DIR}/source/rrarbiter.sv
FLIST += ${ROOT_DIR}/source/stream_arbiter.sv
FLIST += ${ROOT_DIR}/source/stream_mux.sv
FLIST += ${ROOT_DIR}/source/stream_demux.sv
FLIST += ${ROOT_DIR}/source/std_cache_subsystem.sv
FLIST += ${ROOT_DIR}/source/ariane.sv

# ariane_tb
FLIST += ${ROOT_DIR}/source/ariane_tb.sv

# soc
FLIST += ${ROOT_DIR}/source/soc.sv

####################################################################################################
# MEMORY
####################################################################################################

####################################################################################################
# TARGETS
####################################################################################################

# Build target: creates build directory and adds it to gitignore
build:
	@mkdir -p build
	@echo "*" > build/.gitignore
	@git add build > /dev/null 2>&1

# Log target: creates log directory and adds it to gitignore
log:
	@mkdir -p log
	@echo "*" > log/.gitignore
	@git add log > /dev/null 2>&1

# Clean target: removes build directory and rebuilds it
.PHONY: clean
clean:
	@echo -e "\033[3;35mCleaning build directory...\033[0m"
	@rm -rf build
	@make -s build
	@echo -e "\033[3;35mCleaned build directory\033[0m"

.PHONY: clean_full
clean_full: clean
	@echo -e "\033[3;35mCleaning log directory...\033[0m"
	@rm -rf log
	@make -s log
	@echo -e "\033[3;35mCleaned log directory\033[0m"

# Define compile function: compiles the source files in chunks
define compile
  $(eval SUB_LIB := $(shell echo "$(wordlist 1, 25,$(COMPILE_LIB))"))
  cd build; xvlog -i ${ROOT_DIR}/include -sv $(SUB_LIB) --nolog $(XVLOG_DEFS) | $(GREP_EW)
  $(eval COMPILE_LIB := $(wordlist 26, $(words $(COMPILE_LIB)), $(COMPILE_LIB)))
  $(if $(COMPILE_LIB), $(call compile))
endef

build/build_$(TOP): source/$(TOP).sv build
	@make -s clean
	@echo -e "\033[3;35mCompiling...\033[0m"
	@$(eval COMPILE_LIB := $(FLIST))
	@$(call compile)
	@echo -e "\033[3;35mCompiled\033[0m"
	@echo -e "\033[3;35mElaborating $(TOP)...\033[0m"
	@cd build; xelab $(TOP) --O0 --incr --nolog --timescale 1ns/1ps | $(GREP_EW)
	@echo -e "\033[3;35mElaborated $(TOP)\033[0m"
	@echo "" > build/build_$(TOP)

.PHONY: simulate
simulate: build/build_$(TOP)
	@echo "--testplusarg TESTNAME=$(TESTNAME)" > build/xsim_args
	@cd build; xsim $(TOP) -f xsim_args -runall -log ../log/$(TOP)_$(TESTNAME).txt

.PHONY: simulate_gui
simulate_gui: build/build_$(TOP)
	@echo "--testplusarg TESTNAME=$(TESTNAME)" > build/xsim_args
	@cd build; xsim $(TOP) -f xsim_args -gui

.PHONY: run
run: clean simulate

.PHONY: run_gui
run_gui: clean simulate_gui

.PHONY: print_logo
print_logo:
	@echo -e "\033[1;36m  ___  ___ _        ___       ___  \033[0m"
	@echo -e "\033[1;36m |   \/ __(_)  __  / __| ___ / __| \033[0m"
	@echo -e "\033[1;36m | |) \__ \ | |__| \__ \/ _ \ (__  \033[0m"
	@echo -e "\033[1;36m |___/|___/_|      |___/\___/\___| \033[0m"
	@echo -e "\033[1;36m                                   \033[0m"
