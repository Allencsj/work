#makefile for simulate
#
#target : dependency

#wave = 1
#
#if [$(wave) == 1]
#then
#	waves = +postprocess
#fi

case :=
GUI :=
TEST = $(case) #case name from command line
LOG_CASE = $(case).test.log
LOG_COM = $(case).compile.log

run: compile simulate
run_cov: compile_coverage simulate_coverage

#target:
#[tab] command
compile :
	vcs -full64 -sverilog -timescale=1ns/1ns -debug_acc+all -file ../cfg/flist -l logs/$(LOG_COM) +$(TEST)

simulate :
	./simv -l logs/$(LOG_CASE) $(waves)  +postprocess +$(TEST)

compile_coverage :
	vcs -full64 -sverilog -debug_all -cm line+cond+fsm+tgl+branch -lca -file ../cfg/flist +$(TEST) -timescale=1ns/1ns

simulate_coverage :
	./simv -cm line+cond+fsm+tgl+branch -lca -cm_log logs/cm.log -l logs/$(LOG_CASE) +$(TEST)

report_cov :
	urg -dir simv.vdb -lca \

dve_cov :
	dve -cov  -full64 -covdir simv.vdb -lca

clean :
	rm -rf logs/*.log csrc simv simv.daidir ucli.key *.vpd DVEfiles coverage simv.vdb waves/DVEfiles waves/*.vpd urgReport

clib : 
	rm -rf csrc simv simv.daidir ucli.key DVEfiles coverage simv.vdb
