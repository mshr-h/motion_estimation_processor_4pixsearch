module fpga_top
(
  input  wire       CLOCK_50,
  input  wire       CLOCK2_50,
  input  wire       CLOCK3_50,
  input  wire       CLOCK4_50,
  output wire [6:0] HEX0,
  output wire [6:0] HEX1,
  output wire [6:0] HEX2,
  output wire [6:0] HEX3,
  output wire [6:0] HEX4,
  output wire [6:0] HEX5,
  input  wire [3:0] KEY,
  output wire [9:0] LEDR
);

localparam MEM_SW_A = "../memory_sw_A.mif";
localparam MEM_SW_B = "../memory_sw_B.mif";
localparam MEM_SW_C = "../memory_sw_C.mif";
localparam MEM_SW_D = "../memory_sw_D.mif";
localparam MEM_TB_A = "../memory_tb_A.mif";
localparam MEM_TB_B = "../memory_tb_B.mif";
localparam MEM_TB_C = "../memory_tb_C.mif";
localparam MEM_TB_D = "../memory_tb_D.mif";

reg         req;
wire [15:0] min_sad;
wire [11:0] min_mvec;
wire        ack;

wire [31:0] pel_sw_d;
wire [31:0] pel_tb_d;
wire [7:0]  pel_sw_i;
wire [7:0]  pel_tb_i;
wire [9:0]  addr_sw_d;
wire [5:0]  addr_tb_d;
wire [11:0] addr_sw_i;
wire [7:0]  addr_tb_i;

wire clk = CLOCK_50;
wire RSTN = KEY[2];
wire SW4N = KEY[0];
wire SW5N = KEY[1];

// detect falling edge
reg [1:0] ff_sw4 = 0;
reg [1:0] ff_sw5 = 0;
always @(posedge clk) begin
  ff_sw4 <= {ff_sw4[0], SW4N};
  ff_sw5 <= {ff_sw5[0], SW5N};
end
wire tri_sw4 = (ff_sw4 == 2'b10);
wire tri_sw5 = (ff_sw5 == 2'b10);

always @(posedge clk or negedge RSTN) begin
  if(~RSTN)
    req <= 0;
  else if(tri_sw4)
    req <= 1;
  else if(tri_sw5)
    req <= 0;
end

me_top _me_top
(
  .rst_n    ( RSTN     ) ,
  .clk      ( clk      ) ,
  .req      ( req      ) ,
  .min_sad  ( min_sad  ) ,
  .min_mvec ( min_mvec ) ,
  .ack      ( ack      ) ,

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
  .rst_n  ( RSTN      ) ,
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
  .rst_n  ( RSTN      ) ,
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

assign LEDR[0] = req;
assign LEDR[1] = ack;
assign LEDR[2] = |min_sad;
assign LEDR[3] = |min_mvec;
assign LEDR[4] = |pel_tb_i;
assign LEDR[5] = |pel_sw_i;
assign LEDR[6] = |pel_tb_d;
assign LEDR[7] = |pel_sw_d;

endmodule
