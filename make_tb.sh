cd testbench
iverilog -Wall -o tb_me_double.out tb_me_double.v
vvp tb_me_double.out
cd ..
