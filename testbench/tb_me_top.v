`include "./memory_dual_port.v"
`include "../rtl/memory_sw.v"
`include "../rtl/memory_tb.v"
`include "../rtl/addr_gen.v"
`include "../rtl/control_double.v"
`include "../rtl/pe.v"
`include "../rtl/pe_line.v"
`include "../rtl/shift_register.v"
`include "../rtl/sum.v"
`include "../rtl/pe_array.v"
`include "../rtl/pa_array.v"
`include "../rtl/me_double.v"
`include "../rtl/addr_gen_integer.v"
`include "../rtl/control_integer.v"
`include "../rtl/SAD.v"
`include "../rtl/SAD_array.v"
`include "../rtl/me_integer.v"
`include "../rtl/control_top.v"
`include "../rtl/me_top.v"

`default_nettype none

module tb_me_top;

localparam MEM_SW_A = "../memory/memory_sw_A.txt";
localparam MEM_SW_B = "../memory/memory_sw_B.txt";
localparam MEM_SW_C = "../memory/memory_sw_C.txt";
localparam MEM_SW_D = "../memory/memory_sw_D.txt";
localparam MEM_TB_A = "../memory/memory_tb_A.txt";
localparam MEM_TB_B = "../memory/memory_tb_B.txt";
localparam MEM_TB_C = "../memory/memory_tb_C.txt";
localparam MEM_TB_D = "../memory/memory_tb_D.txt";

reg         rst_n;
reg         clk;
reg         req;
wire [15:0] min_sad;
wire [5:0]  min_mvec_h;
wire [5:0]  min_mvec_w;
wire        ack;
wire [31:0] pel_sw_d;
wire [31:0] pel_tb_d;
wire [9:0]  addr_sw_d;
wire [5:0]  addr_tb_d;
wire [7:0]  pel_sw_i;
wire [7:0]  pel_tb_i;
wire [11:0] addr_sw_i;
wire [7:0]  addr_tb_i;

me_top _me_top
(
  .rst_n    ( rst_n                    ) ,
  .clk      ( clk                      ) ,
  .req      ( req                      ) ,
  .min_sad  ( min_sad                  ) ,
  .min_mvec ( {min_mvec_h, min_mvec_w} ) ,
  .ack      ( ack                      ) ,

  // memory access ports
  .pel_sw_d  ( pel_sw_d  ) ,
  .pel_tb_d  ( pel_tb_d  ) ,
  .addr_sw_d ( addr_sw_d ) ,
  .addr_tb_d ( addr_tb_d ) ,
  .pel_sw_i  ( pel_sw_i  ) ,
  .pel_tb_i  ( pel_tb_i  ) ,
  .addr_sw_i ( addr_sw_i ) ,
  .addr_tb_i ( addr_tb_i )
);

memory_sw
_memory_sw
(
  .rst_n  ( rst_n     ) ,
  .clk    ( clk       ) ,
  .addr_a ( addr_sw_d ) ,
  .addr_b ( addr_sw_i ) ,
  .data_a ( pel_sw_d  ) ,
  .data_b ( pel_sw_i  )
);
defparam _memory_sw.MEM_SW_A = MEM_SW_A;
defparam _memory_sw.MEM_SW_B = MEM_SW_B;
defparam _memory_sw.MEM_SW_C = MEM_SW_C;
defparam _memory_sw.MEM_SW_D = MEM_SW_D;

memory_tb
_memory_tb
(
  .rst_n  ( rst_n     ) ,
  .clk    ( clk       ) ,
  .addr_a ( addr_tb_d ) ,
  .addr_b ( addr_tb_i ) ,
  .data_a ( pel_tb_d  ) ,
  .data_b ( pel_tb_i  )
);
defparam _memory_tb.MEM_TB_A = MEM_TB_A;
defparam _memory_tb.MEM_TB_B = MEM_TB_B;
defparam _memory_tb.MEM_TB_C = MEM_TB_C;
defparam _memory_tb.MEM_TB_D = MEM_TB_D;


localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;

initial begin
  $dumpfile("tb_me_top.vcd");
  $dumpvars(0, tb_me_top);
end

initial begin
  #1 rst_n<=1'bx;clk<=1'bx;req<=1'bx;
  #(CLK_PERIOD) rst_n<=1;
  #(CLK_PERIOD*3) rst_n<=0;clk<=0;req<=0;
  repeat(5) @(posedge clk);
  rst_n<=1;
  repeat(3) @(posedge clk);
  req<=1;
  repeat(1500) @(posedge clk); // while(~ack) @(posedge clk);
  $display("motion vector");
  $display("  h  : %d", min_mvec_h);
  $display("  w  : %d", min_mvec_w);
  $display("  sad: %d", min_sad);
  repeat(10) @(posedge clk);
  req<=0;
  repeat(10) @(posedge clk);
  $finish(2);
end


endmodule

`default_nettype wire
