module Data_driver(
    input wire but_1,
    input wire clk,
    input wire reset,
    output wire s_led,

    input wire [3:0] data_wire,
    input wire [3:0] gl_pos_data,

    input wire [3:0] bat,

    output wire [3:0] Gr_pos_led,
    output wire [8:0] L_pos_led,

    output wire [6:0] A_3seg7,
    output wire [6:0] A_2seg7,
    output wire [6:0] A_1seg7,
    output wire [6:0] A_0seg7,
	 
    output wire [6:0] B_3seg7,
    output wire [6:0] B_2seg7,
    output wire [6:0] B_1seg7,
    output wire [6:0] B_0seg7
);

reg [127:0] data_in;
reg [127:0] data_out;

reg [127:0] key;

//Bat_drv============================
wire [3:0] push;

reg [3:0] but_r;
reg [3:0] but_rr;

assign push = but_rr & ~but_r;

wire left = push[0];
wire rigt = push[1];
wire set  = push[2];

always @(posedge clk) begin
	  but_r <= but_1;
	  but_rr <= but_r;
end
//===================================

//Pos================================
reg [2:0] pos;

always @(posedge clk) begin
    if(reset) begin
        pos = 4'b0;
    end else if (left & ~rigt & ~set)
        pos = pos + 1;
    else if (~left & rigt & ~set)
        pos = pos - 1;
end
//===================================

//data_in============================
wire full_pos = (gl_pos_data << 3 + pos) << 4;

wire [127:0] mask = 128'b1111 << full_pos; 

wire [3:0]   L_new_data = {121'b0, data_wire};

wire [127:0] new_data = (data_in & ~mask) | L_new_data; 

always @(posedge clk) begin
    if(reset) begin
        data_in <= 128'b0;
    end else if(set)
        data_in <= new_data;
end
//===================================

//===================================
wire [127:0] data = data_in;
wire [31:0] shift = (gl_pos_data << 7) ;

wire [6:0] A_3seg7_pre;
wire [6:0] A_2seg7_pre;
wire [6:0] A_1seg7_pre;
wire [6:0] A_0seg7_pre;

wire [6:0] B_3seg7_pre;
wire [6:0] B_2seg7_pre;
wire [6:0] B_1seg7_pre;
wire [6:0] B_0seg7_pre;

hex_to_7seg ht70a ((data >> shift) >> 0, A_0seg7_pre);
hex_to_7seg ht71a ((data >> shift) >> 4, A_0seg7_pre);
hex_to_7seg ht72a ((data >> shift) >> 8, A_0seg7_pre);
hex_to_7seg ht73a ((data >> shift) >> 12, A_0seg7_pre);

hex_to_7seg ht70b ((data >> shift) >> 16, B_0seg7_pre);
hex_to_7seg ht71b ((data >> shift) >> 20, B_0seg7_pre);
hex_to_7seg ht72b ((data >> shift) >> 24, B_0seg7_pre);
hex_to_7seg ht73b ((data >> shift) >> 28, B_0seg7_pre);

assign A_0seg7 = A_0seg7_pre;
assign A_1seg7 = A_1seg7_pre;
assign A_2seg7 = A_2seg7_pre;
assign A_3seg7 = A_3seg7_pre;

assign B_0seg7 = B_0seg7_pre;
assign B_1seg7 = B_1seg7_pre;
assign B_2seg7 = B_2seg7_pre;
assign B_3seg7 = B_3seg7_pre;

//===================================

always @(posedge clk) begin
    if(reset) begin
        data_out <= 128'b0;
        key      <= 128'b0;
    end
end




endmodule

module hex_to_7seg
(
    input wire [3:0] hex,
    output wire [6:0] seg7
);

assign seg7 = (hex == 4'h0)? ~7'b0_111_111:
              (hex == 4'h1)? ~7'b0_000_110:
              (hex == 4'h2)? ~7'b1_011_011:
              (hex == 4'h3)? ~7'b1_001_111:
              (hex == 4'h4)? ~7'b1_100_110:
              (hex == 4'h5)? ~7'b1_101_101:
              (hex == 4'h6)? ~7'b1_111_101:
              (hex == 4'h7)? ~7'b0_000_111:
              (hex == 4'h8)? ~7'b1_111_111:
              (hex == 4'h9)? ~7'b1_101_111:
              (hex == 4'ha)? ~7'b1_110_111:
              (hex == 4'hb)? ~7'b1_111_100:
              (hex == 4'hc)? ~7'b0_111_001:
              (hex == 4'hd)? ~7'b1_011_110:
              (hex == 4'he)? ~7'b1_111_001:
				  (hex == 4'hf)? ~7'b1_110_001:
				  ~7'b0_000_000;

endmodule