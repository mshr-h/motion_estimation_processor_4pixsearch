.ONESHELL:
all:
	cd testbench
	iverilog -Wall -o tb_me_double.out tb_me_double.v
	vvp tb_me_double.out
	iverilog -Wall -o tb_me_top.out tb_me_top.v
	vvp tb_me_top.out

mif:
	go run tools/convert2mif.go memory/memory_sw_A.txt fpga/memory_sw_A.mif
	go run tools/convert2mif.go memory/memory_sw_B.txt fpga/memory_sw_B.mif
	go run tools/convert2mif.go memory/memory_sw_C.txt fpga/memory_sw_C.mif
	go run tools/convert2mif.go memory/memory_sw_D.txt fpga/memory_sw_D.mif
	go run tools/convert2mif.go memory/memory_tb_A.txt fpga/memory_tb_A.mif
	go run tools/convert2mif.go memory/memory_tb_B.txt fpga/memory_tb_B.mif
	go run tools/convert2mif.go memory/memory_tb_C.txt fpga/memory_tb_C.mif
	go run tools/convert2mif.go memory/memory_tb_D.txt fpga/memory_tb_D.mif

distclean: clean
	rm -f fpga/*.mif
	rm -f memory/*.txt

clean:
	rm -f testbench/*.out
	rm -f testbench/*.vcd
	rm -rf fpga/db
	rm -rf fpga/greybox_tmp
	rm -rf fpga/incremental_db
	rm -rf fpga/output_files
	rm -rf fpga/simulation
	rm -f fpga/*.qws
