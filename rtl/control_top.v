module control_top
(
  input  wire        rst_n,
  input  wire        clk,

  input  wire        req,
  output reg         ack,
  output reg  [11:0] min_mvec,
  output reg  [15:0] min_sad,

  // between me_double
  output reg         req_d,
  input  wire [9:0]  min_mvec_d,
  input  wire        ack_d,

  // between me_integer
  output reg         req_i,
  output reg  [11:0] init_pos_i ,
  input  wire [15:0] min_sad_i,
  input  wire [3:0]  min_diff_i,
  input  wire        ack_i
);

localparam INIT             = 4'd0;
localparam WAIT_REQ         = 4'd1;
localparam START_ME_DOUBLE  = 4'd2;
localparam WAIT_ME_DOUBLE   = 4'd3;
localparam DONE_ME_DOUBLE   = 4'd4;
localparam CALC_INIT_MVEC   = 4'd5;
localparam START_ME_INTEGER = 4'd6;
localparam WAIT_ME_INTEGER  = 4'd7;
localparam DONE_ME_INTEGER  = 4'd8;
localparam CALC_MVEC        = 4'd9;
localparam DONE             = 4'd10;
localparam WAIT_REQ_FALL    = 4'd11;

reg [3:0]  state_main;
reg [9:0] mvec_d;
reg [3:0]  diff_i;
reg [11:0] mvec;

wire [5:0] mvec_decoded_h;
wire [5:0] mvec_decoded_w;

always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    state_main <= INIT;
    req_d      <= 0;
    req_i      <= 0;
    mvec_d     <= 0;
    init_pos_i <= 0;
    diff_i     <= 0;
    mvec       <= 0;
    min_mvec   <= 0;
    min_sad    <= 0;
    ack        <= 0;
  end else begin
    case(state_main)
      INIT: begin
        state_main <= #1 WAIT_REQ;
        mvec_d     <= #1 0;
        init_pos_i <= #1 0;
        diff_i     <= #1 0;
        mvec       <= #1 0;
        min_mvec   <= #1 0;
        min_sad    <= #1 0;
        ack        <= #1 0;
      end
      WAIT_REQ: begin
        if(req)
          state_main <= #1 START_ME_DOUBLE;
      end
      START_ME_DOUBLE: begin
        state_main <= #1 WAIT_ME_DOUBLE;
        req_d      <= #1 1;
      end
      WAIT_ME_DOUBLE: begin
        if(ack_d)
          state_main <= #1 DONE_ME_DOUBLE;
      end
      DONE_ME_DOUBLE: begin
        state_main <= #1 CALC_INIT_MVEC;
        mvec_d     <= #1 min_mvec_d;
        req_d      <= #1 0;
      end
      CALC_INIT_MVEC: begin
        state_main       <= #1 START_ME_INTEGER;
        init_pos_i[11:6] <= #1 decode_mvec(mvec_d[9:5]);
        init_pos_i[5:0]  <= #1 decode_mvec(mvec_d[4:0]);
      end
      START_ME_INTEGER: begin
        state_main <= #1 WAIT_ME_INTEGER;
        req_i      <= #1 1;
      end
      WAIT_ME_INTEGER: begin
        if(ack_i)
          state_main <= #1 DONE_ME_INTEGER;
      end
      DONE_ME_INTEGER: begin
        state_main <= #1 CALC_MVEC;
        diff_i     <= #1 min_diff_i;
        req_i      <= #1 0;
      end
      CALC_MVEC: begin // not completed yet
        state_main <= #1 DONE;
        mvec[11:6] <= #1 init_pos_i[11:6] + {4'd0, diff_i[3:2]};
        mvec[5:0]  <= #1 init_pos_i[5:0] + {4'd0, diff_i[1:0]};
      end
      DONE: begin
        state_main <= #1 WAIT_REQ_FALL;
        min_mvec   <= #1 mvec;
        min_sad    <= #1 min_sad_i;
        ack        <= #1 1;
      end
      WAIT_REQ_FALL: begin
        if(~req) begin
          state_main <= #1 WAIT_REQ;
          ack        <= #1 0;
        end
      end
      default: begin
        state_main <= 'dx;
      end
    endcase
  end
end

function [5:0] decode_mvec;
  input [4:0] mvec_in;
  begin
    case(mvec_in)
      5'd7   : decode_mvec = 6'd0;
      5'd8   : decode_mvec = 6'd1;
      5'd9   : decode_mvec = 6'd3;
      5'd10  : decode_mvec = 6'd5;
      5'd11  : decode_mvec = 6'd7;
      5'd12  : decode_mvec = 6'd9;
      5'd13  : decode_mvec = 6'd11;
      5'd14  : decode_mvec = 6'd13;
      5'd15  : decode_mvec = 6'd15;
      5'd16  : decode_mvec = 6'd17;
      5'd17  : decode_mvec = 6'd19;
      5'd18  : decode_mvec = 6'd21;
      5'd19  : decode_mvec = 6'd23;
      5'd20  : decode_mvec = 6'd25;
      5'd21  : decode_mvec = 6'd27;
      5'd22  : decode_mvec = 6'd29;
      5'd23  : decode_mvec = 6'd31;
      5'd24  : decode_mvec = 6'd33;
      5'd25  : decode_mvec = 6'd35;
      5'd26  : decode_mvec = 6'd37;
      5'd27  : decode_mvec = 6'd39;
      5'd28  : decode_mvec = 6'd41;
      5'd29  : decode_mvec = 6'd43;
      5'd30  : decode_mvec = 6'd45;
      5'd31  : decode_mvec = 6'd46;
      default: decode_mvec = 6'dx;
    endcase
  end
endfunction

endmodule
