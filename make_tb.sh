cd testbench
iverilog -Wall -o tb_me_double.out tb_me_double.v
vvp tb_me_double.out
iverilog -Wall -o tb_me_integer.out tb_me_integer.v
vvp tb_me_integer.out
iverilog -Wall -o tb_me_top.out tb_me_top.v
vvp tb_me_top.out
cd ..
