DIR := ../sv
all: comp run

clean:
	rm -rf simv* csrc *.log *vpd vc_hdrs.h ucli.key

comp:
	vcs -sverilog -debug_pp +dump_on +dump_top  +librescan +v2k -timescale=1ns/1ns -ntb_opts uvm-1.1 +incdir+$(DIR) -f common.vlist  -l comp.log

run:
	simv  +UVM_NO_RELNOTES   +UVM_TESTNAME=exhaustive_seq_test -l run.log +dump_on +dump_top 

base:	
	simv  +UVM_NO_RELNOTES   +UVM_TESTNAME=base_test -l run.log 
