module control_integer
(
  input  wire        rst_n,
  input  wire        clk,
  input  wire        req,
  input  wire [15:0] sad,
  input  wire [3:0]  vec_diff,
  input  wire [11:0] init_pos,
  output wire        clr,
  output wire        en_addr_sw,
  output reg         en_addr_tb,
  output wire        en_sadarray_sw,
  output wire        en_sadarray_tb,
  output wire [11:0] init_mvec,
  output reg  [15:0] min_sad,
  output reg  [3:0]  min_diff,
  output wire        ack
);

localparam SW_LENGTH       = 18;
localparam TB_LENGTH       = 16;

localparam INIT            = 4'b0000;
localparam WAIT_REQ        = 4'b0001;
localparam RUNNING         = 4'b0010;
localparam WAIT_REQ_FALL   = 4'b0011;
localparam WAIT_RUN        = 4'b0100;
localparam ACTIVE          = 4'b0101;
localparam DISABLE         = 4'b0110;
localparam DONE            = 4'b0111;
localparam WAIT_SW_DONE    = 4'b1000;
localparam WAIT_DUMMY      = 4'b1001;
localparam UPDATE_MIN      = 4'b1010;

reg [3:0] state_main;
assign ack        = (state_main==WAIT_REQ_FALL);
assign clr        = (state_main==WAIT_REQ);
assign en_addr_sw = (state_addr_sw==ACTIVE);
wire   done       = (state_done==DONE);
assign init_mvec  = init_pos;

// FSM main
always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    state_main <= INIT;
  end else begin
    case(state_main)
      INIT          :          state_main <= #1 WAIT_REQ;
      WAIT_REQ      : if( req) state_main <= #1 RUNNING;
      RUNNING       : if(done) state_main <= #1 WAIT_REQ_FALL;
      WAIT_REQ_FALL : if(~req) state_main <= #1 WAIT_REQ;
      default       :          state_main <= #1 'dx;
    endcase
  end
end

// addr_sw
reg [3:0] state_addr_sw;
always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    state_addr_sw <= INIT;
  end else begin
    case(state_addr_sw)
      INIT: begin
        state_addr_sw <= #1 WAIT_RUN;
      end
      WAIT_RUN: begin
        if(state_main==RUNNING)
          state_addr_sw <= #1 ACTIVE;
      end
      ACTIVE: begin
        if((cnt_h==2) && (cnt_w==SW_LENGTH))
          state_addr_sw <= #1 DONE;
      end
      DONE: begin
        if(state_main==WAIT_REQ_FALL)
          state_addr_sw <= #1 WAIT_RUN;
      end
      default: begin
        state_addr_sw <= 'dx;
      end
    endcase
  end
end

// addr_tb
reg [3:0] state_addr_tb;
reg tb_addr_dly;
reg tb_addr_dly2;
always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    state_addr_tb <= INIT;
    en_addr_tb    <= 0;
  end else begin
    case(state_addr_tb)
      INIT: begin
        state_addr_tb <= #1 WAIT_RUN;
        en_addr_tb <= #1 0;
      end
      WAIT_RUN: begin
        if(state_main==RUNNING)
          state_addr_tb <= #1 ACTIVE;
        en_addr_tb <= #1 0;
      end
      ACTIVE: begin
        if(cnt_h==(SW_LENGTH-1) && (cnt_w==(SW_LENGTH-1)))
          state_addr_tb <= #1 DONE;
        if((cnt_h > 1) && (cnt_w > 1))
          en_addr_tb <= #1 1;
        else
          en_addr_tb <= #1 0;
      end
      DONE: begin
        if(state_main==WAIT_REQ_FALL)
          state_addr_tb <= WAIT_RUN;
        en_addr_tb <= #1 0;
      end
      default : begin
        state_addr_tb <= 'dx;
        en_addr_tb    <= 'dx;
      end
    endcase
  end
end

// cnt_h, cnt_w
reg [6:0] cnt_h;
reg [6:0] cnt_w;
always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    cnt_h <= 0;
    cnt_w <= 0;
  end else begin
    case (state_addr_sw)
      INIT: begin
        cnt_h <= #1 0;
        cnt_w <= #1 0;
      end
      WAIT_RUN: begin
        cnt_h <= #1 0;
        cnt_w <= #1 0;
      end
      ACTIVE: begin
        if(cnt_h==(SW_LENGTH-1)) begin
          cnt_h <= 0;
          cnt_w <= #1 cnt_w + 1;
        end else begin
          cnt_h <= #1 cnt_h + 1;
        end
      end
      DONE: begin
        cnt_h <= #1 0;
        cnt_w <= #1 0;
      end
      default : begin
        cnt_h <= 'dx;
        cnt_w <= 'dx;
      end
    endcase
  end
end

localparam N_sw=2;
localparam N_tb=2;
reg [N_sw-1:0] sw_dly;
reg [N_tb-1:0] tb_dly;
assign en_sadarray_sw = sw_dly[N_sw-1];
assign en_sadarray_tb = tb_dly[N_tb-1];

always @(posedge clk) begin
  sw_dly <= #1 {sw_dly[N_sw-2:0], en_addr_sw};
  tb_dly <= #1 {tb_dly[N_tb-2:0], en_addr_tb};
end

// min_sad, min_diff
reg [3:0] state_done;
reg [2:0] cnt_done;
always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    state_done <= INIT;
    cnt_done   <= 0;
    min_sad    <= 16'hFFFF;
    min_diff   <= 4'b0000;
  end else begin
    case (state_done)
      INIT: begin
        state_done <= #1 WAIT_SW_DONE;
        cnt_done   <= #1 0;
        min_sad    <= #1 16'hFFFF;
        min_diff   <= #1 4'b0000;
      end
      WAIT_SW_DONE: begin
        if(state_addr_sw==DONE)
          state_done <= #1 WAIT_DUMMY;
        cnt_done   <= #1 0;
        min_sad    <= #1 16'hFFFF;
        min_diff   <= #1 4'b0000;
      end
      WAIT_DUMMY: begin
        if(cnt_done==3'd2)
          state_done <= #1 UPDATE_MIN;
        cnt_done <= #1 cnt_done + 1;
      end
      UPDATE_MIN: begin
        state_done <= #1 DONE;
        cnt_done   <= #1 0;
        min_sad    <= #1 sad;
        min_diff   <= #1 vec_diff;
      end
      DONE: begin
        if(state_main==WAIT_REQ)
          state_done <= #1 WAIT_SW_DONE;
        cnt_done   <= #1 0;
      end
      default: begin
        state_done <= 'dx;
        cnt_done   <= 'dx;
        min_sad    <= 'dx;
        min_diff   <= 'dx;
      end
    endcase
  end
end

endmodule
