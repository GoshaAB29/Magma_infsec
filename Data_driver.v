module Data_driver(
    input wire clk,
    input wire reset,
    output wire s_led,

    input wire revert_switch,
    output wire revert_led,

    input wire [3:0] data_wire,
    input wire [3:0] gl_pos_data,

    input wire [2:0] status,

    input wire [2:0] bat,
    input wire       encr_decr,

    output wire [3:0] Gr_pos_led,
    output wire [2:0] mode_pos_led,

    output wire       magma_done,

    output wire [6:0] A_3seg7,
    output wire [6:0] A_2seg7,
    output wire [6:0] A_1seg7,
    output wire [6:0] A_0seg7,

    output wire [6:0] B_3seg7,
    output wire [6:0] B_2seg7,
    output wire [6:0] B_1seg7,
    output wire [6:0] B_0seg7
);

reg  [127:0] data_in;
wire [127:0] data_out;

reg  [255:0] key;

wire [255:0] preset_key = 256'h0xdeda1eda1a1baba1beda1daaa42aa1303ded1c9ef1ed61da4a41bab3da1bed61;

assign revert_led = revert_switch;

wire data_set = status[0];
wire key_set = ~status[0] & status[1];
wire data_out_set = ~status[0] & ~status[1] & status[2];

wire set_on = data_set | key_set;

assign mode_pos_led[0] = ~key_set & ~ data_out_set;
assign mode_pos_led[1] = key_set;
assign mode_pos_led[2] = data_out_set;

assign Gr_pos_led = (key_set)? gl_pos_data: 4'b1 << gl_pos_data;

//Bat_drv============================
wire [2:0] push;

reg [2:0] but_r;
reg [2:0] but_rr;

assign push = but_rr & ~but_r;

wire left = push[0];
wire rigt = push[1];
wire set  = push[2];

always @(posedge clk) begin
but_r <= bat;
but_rr <= but_r;
end
//===================================

//Pos================================
reg [2:0] pos;

always @(posedge clk) begin
if(~reset) begin
    pos <= 4'b0;
end else if (left & ~rigt & ~set & set_on)
pos <= pos + 1;
else if (~left & rigt & ~set & set_on)
    pos <= pos - 1;
end
//===================================

//data_in============================
wire [$clog2(256):0]full_pos = ((gl_pos_data << 3) + pos) << 2;

wire [255:0] mask = 256'hF << full_pos;

wire [255:0] L_new_data = { 8*8{data_wire}};

wire [127:0] new_data_in = (data_in & ~mask) | (L_new_data & mask);

always @(posedge clk) begin
if(~reset) begin
    data_in <= 128'h0;
end else if(set & data_set & set_on)
    data_in <= new_data_in;
else if (rigt & ~set_on)
    data_in <= data_out;
end
//===================================

//key_in=============================
wire [255:0] new_key = (key & ~mask) | (L_new_data & mask);

always @(posedge clk) begin
if(~reset) begin
    key <= 256'b0;
end else if(set & key_set & set_on)
    key <= new_key;
else if (left & ~set_on)
    key <= preset_key;
end
//===================================

//time===============================
reg[23:0] blinker;
wire see = blinker[23];

always @(posedge clk) begin
if(~reset)
    blinker <= 0;
else
    blinker <= blinker + 1;
end

//MAGMA===================================
wire m_start = set;

magma MAGMA (
    .clk       ( clk        ),         //
    .reset_    ( reset      ),         //
    .start     ( m_start    ),         // старт
    .data_in   ( data_in    ),         // входные данные
    .key       ( key        ),         // 256-битный ключ
    .encr_decr ( encr_decr  ),          // выбор режима шифрования

    .data_out  ( data_out   ),         // шифр
    .done      ( magma_done )          // финиш
);

//===================================
wire [255:0] data = (data_set)? new_data_in: (key_set & ~revert_switch)? new_key: (data_out_set)? data_out: (key_set & revert_switch)? key :data_in;
wire [64:0] shift = (gl_pos_data << 5) ;

wire [6:0] A_3seg7_pre;
wire [6:0] A_2seg7_pre;
wire [6:0] A_1seg7_pre;
wire [6:0] A_0seg7_pre;

wire [6:0] B_3seg7_pre;
wire [6:0] B_2seg7_pre;
wire [6:0] B_1seg7_pre;
wire [6:0] B_0seg7_pre;

hex_to_7seg ht70a ((data >> shift) >> 0,  A_0seg7_pre);
hex_to_7seg ht71a ((data >> shift) >> 4,  A_1seg7_pre);
hex_to_7seg ht72a ((data >> shift) >> 8,  A_2seg7_pre);
hex_to_7seg ht73a ((data >> shift) >> 12, A_3seg7_pre);

hex_to_7seg ht70b ((data >> shift) >> 16, B_0seg7_pre);
hex_to_7seg ht71b ((data >> shift) >> 20, B_1seg7_pre);
hex_to_7seg ht72b ((data >> shift) >> 24, B_2seg7_pre);
hex_to_7seg ht73b ((data >> shift) >> 28, B_3seg7_pre);

assign A_0seg7 = ((pos == 0) & (~see & set_on))? ~7'b0 :A_0seg7_pre;
assign A_1seg7 = ((pos == 1) & (~see & set_on))? ~7'b0 :A_1seg7_pre;
assign A_2seg7 = ((pos == 2) & (~see & set_on))? ~7'b0 :A_2seg7_pre;
assign A_3seg7 = ((pos == 3) & (~see & set_on))? ~7'b0 :A_3seg7_pre;

assign B_0seg7 = ((pos == 4) & (~see & set_on))? ~7'b0 :B_0seg7_pre;
assign B_1seg7 = ((pos == 5) & (~see & set_on))? ~7'b0 :B_1seg7_pre;
assign B_2seg7 = ((pos == 6) & (~see & set_on))? ~7'b0 :B_2seg7_pre;
assign B_3seg7 = ((pos == 7) & (~see & set_on))? ~7'b0 :B_3seg7_pre;

//===================================

endmodule

module hex_to_7seg
(
    input wire  [3:0] hex,
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
