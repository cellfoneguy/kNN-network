#
#  Makefile for KNN Simulation
#
#  Usage:
#    $ make compile
#          - compile SystemVerolog files using VCS
#    $ make sim
#          - compile and simulate using VCS
#    $ make debug
#          - compile, simulate and see waveform using DVE
#    $ make clear
#          - clear temporary simulation files
#
#  Updated by:
#      Xuanle Ren - xuanler(at)andrew.cmu.edu
#


###################################################################
### Setup
###################################################################

OUTPUT := testing

CODE = rtl
DATA = data


###################################################################
### Constants
###################################################################

# text attributes: normal, bold, underline
n=\e[0m
b=\e[1m
u=\e[4m

# bold+green
g=\e[1;32m

# bold+red
r=\e[1;31m

# debug message
m=$gk-NN Simulation: $n


.PHONY: syn
###################################################################
### Compile Verilog
###################################################################

compile:
	@echo -e "$mCopying Verilog into $(OUTPUT)..."
	@rm -rf $(OUTPUT)/*
	@mkdir -p $(OUTPUT)/
	@cp ./$(CODE)/* $(OUTPUT)/
	@cp ./$(DATA)/*.dat $(OUTPUT)/
	@echo -e "$mCompiling Verilog..."
	cd $(OUTPUT)/; vcs +v2k -debug_pp -sverilog -l compile.log *.sv *.v
	@if grep '*W' $(OUTPUT)/compile.log >/dev/null; \
		then echo -e '$m$rCompiler log has warnings!$n'; fi
	@echo -e "$mCompiling finished."


###################################################################
### Simulate Verilog
###################################################################

sim: compile
	@echo -e "$mSimulating Verilog in $(OUTPUT)..."
	cd $(OUTPUT); ./simv


###################################################################
### Debug Verilog, Waveform
###################################################################

debug: sim
	@echo -e "$mDebugging Verilog in $(OUTPUT)..."
	cd $(OUTPUT); dve -vpd vcdplus.vpd


###################################################################
### Synthesis
###################################################################

syn: compile
	@echo -e "$mSynthesizing the design ..."
	@echo -e "$mThe results are saved under ./syn/"
	#@rm -rf ./$(OUTPUT)
	#@mkdir -p $(OUTPUT)
	#@cp ./$(CODE_SYN)/* ./$(OUTPUT)
	#@cp ./$(JTAG)/*.dat $(OUTPUT)/
	#@cp ./$(DT)/dt_param.dat $(OUTPUT)/
	#@cp ./$(LUT)/LUT.dat $(OUTPUT)/
	@cp t2.tcl ./$(OUTPUT)/
	cd ./$(OUTPUT); dc_shell-xg-t -f t2.tcl


clear:       
	@echo -e "$mClear temporary files ..."
	@rm -rf ./$(OUTPUT)
