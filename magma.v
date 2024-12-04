`ifndef __MAGMA__
`define __MAGMA__

module magma
(
    input               clock,
    input               enable,         // mma s0(e1) stage

    input   [64 -1:0]   text_sum,       // mma s0(e1) stage
    input   [64 -1:0]   op3,            // mma s0(e1) stage (?) TODO: check

    output  [64 -1:0]   result,

    input   [1:0]       def_op_sum,     // mma s0(e1) stage (?)
    input   [1:0]       def_op3,        // mma s0(e1) stage (?) TODO: check
    output  [1:0]       def_res
);

genvar      Gi, Gk;

reg  [63:0]     data_s0, data_s1, op3_s1;

reg  [1:0]      def_res_s0, def_res_s1;

always @(posedge clock)
begin
    def_res_s1  <=  def_res_s0;
end

//always @(posedge clock)
//if (enable)
always @*       // TODO: cleanup
begin
    def_res_s0  =   def_op_sum | def_op3;
    data_s0     =   text_sum;
end

wire    [3:0]   SBOX    [0:7][15:0];

assign  {SBOX[0][0],SBOX[0][1],SBOX[0][2],SBOX[0][3],SBOX[0][4],SBOX[0][5],SBOX[0][6],SBOX[0][7],
        SBOX[0][8],SBOX[0][9],SBOX[0][10],SBOX[0][11],SBOX[0][12],SBOX[0][13],SBOX[0][14],SBOX[0][15]}
    =   {4'd12, 4'd4, 4'd6, 4'd2, 4'd10, 4'd5, 4'd11, 4'd9, 4'd14, 4'd8, 4'd13, 4'd7, 4'd0, 4'd3, 4'd15, 4'd1};

assign  {SBOX[1][0],SBOX[1][1],SBOX[1][2],SBOX[1][3],SBOX[1][4],SBOX[1][5],SBOX[1][6],SBOX[1][7],
        SBOX[1][8],SBOX[1][9],SBOX[1][10],SBOX[1][11],SBOX[1][12],SBOX[1][13],SBOX[1][14],SBOX[1][15]}
    =   {4'd6, 4'd8, 4'd2, 4'd3, 4'd9, 4'd10, 4'd5, 4'd12, 4'd1, 4'd14, 4'd4, 4'd7, 4'd11, 4'd13, 4'd0, 4'd15};

assign  {SBOX[2][0],SBOX[2][1],SBOX[2][2],SBOX[2][3],SBOX[2][4],SBOX[2][5],SBOX[2][6],SBOX[2][7],
        SBOX[2][8],SBOX[2][9],SBOX[2][10],SBOX[2][11],SBOX[2][12],SBOX[2][13],SBOX[2][14],SBOX[2][15]}
    =   {4'd11, 4'd3, 4'd5, 4'd8, 4'd2, 4'd15, 4'd10, 4'd13, 4'd14, 4'd1, 4'd7, 4'd4, 4'd12, 4'd9, 4'd6, 4'd0};

assign  {SBOX[3][0],SBOX[3][1],SBOX[3][2],SBOX[3][3],SBOX[3][4],SBOX[3][5],SBOX[3][6],SBOX[3][7],
        SBOX[3][8],SBOX[3][9],SBOX[3][10],SBOX[3][11],SBOX[3][12],SBOX[3][13],SBOX[3][14],SBOX[3][15]}
    =   {4'd12, 4'd8, 4'd2, 4'd1, 4'd13, 4'd4, 4'd15, 4'd6, 4'd7, 4'd0, 4'd10, 4'd5, 4'd3, 4'd14, 4'd9, 4'd11};

assign  {SBOX[4][0],SBOX[4][1],SBOX[4][2],SBOX[4][3],SBOX[4][4],SBOX[4][5],SBOX[4][6],SBOX[4][7],
        SBOX[4][8],SBOX[4][9],SBOX[4][10],SBOX[4][11],SBOX[4][12],SBOX[4][13],SBOX[4][14],SBOX[4][15]}
    =   {4'd7, 4'd15, 4'd5, 4'd10, 4'd8, 4'd1, 4'd6, 4'd13, 4'd0, 4'd9, 4'd3, 4'd14, 4'd11, 4'd4, 4'd2, 4'd12};

assign  {SBOX[5][0],SBOX[5][1],SBOX[5][2],SBOX[5][3],SBOX[5][4],SBOX[5][5],SBOX[5][6],SBOX[5][7],
        SBOX[5][8],SBOX[5][9],SBOX[5][10],SBOX[5][11],SBOX[5][12],SBOX[5][13],SBOX[5][14],SBOX[5][15]}
    =   {4'd5, 4'd13, 4'd15, 4'd6, 4'd9, 4'd2, 4'd12, 4'd10, 4'd11, 4'd7, 4'd8, 4'd1, 4'd4, 4'd3, 4'd14, 4'd0};

assign  {SBOX[6][0],SBOX[6][1],SBOX[6][2],SBOX[6][3],SBOX[6][4],SBOX[6][5],SBOX[6][6],SBOX[6][7],
        SBOX[6][8],SBOX[6][9],SBOX[6][10],SBOX[6][11],SBOX[6][12],SBOX[6][13],SBOX[6][14],SBOX[6][15]}
    =   {4'd8, 4'd14, 4'd2, 4'd5, 4'd6, 4'd9, 4'd1, 4'd12, 4'd15, 4'd4, 4'd11, 4'd0, 4'd13, 4'd10, 4'd3, 4'd7};

assign  {SBOX[7][0],SBOX[7][1],SBOX[7][2],SBOX[7][3],SBOX[7][4],SBOX[7][5],SBOX[7][6],SBOX[7][7],
        SBOX[7][8],SBOX[7][9],SBOX[7][10],SBOX[7][11],SBOX[7][12],SBOX[7][13],SBOX[7][14],SBOX[7][15]}
    =   {4'd1, 4'd7, 4'd14, 4'd13, 4'd0, 4'd5, 4'd8, 4'd3, 4'd4, 4'd15, 4'd10, 4'd6, 4'd9, 4'd12, 4'd11, 4'd2};

wire    [3:0]   msb_nibbles_s1 [7:0];
wire    [3:0]   lsb_nibbles_s1 [7:0];

wire    [3:0]   lsb_nib_sub_s1 [7:0];
wire    [3:0]   msb_nib_sub_s1 [7:0];

wire    [31:0]  stage2_msb, stage2_lsb;

generate
for(Gi=0; Gi<8; Gi=Gi+1)
begin: nib_sub
    assign  lsb_nibbles_s1[Gi]  =   data_s0[4*Gi+3  : 4*Gi];
    assign  msb_nibbles_s1[Gi]  =   data_s0[4*Gi+35 : 4*Gi+32];

    assign  lsb_nib_sub_s1[Gi]  =   SBOX[Gi][lsb_nibbles_s1[Gi]];
    assign  msb_nib_sub_s1[Gi]  =   SBOX[Gi][msb_nibbles_s1[Gi]];

    assign  stage2_lsb[4*Gi+3  : 4*Gi]  =   lsb_nib_sub_s1[Gi];
    assign  stage2_msb[4*Gi+3  : 4*Gi]  =   msb_nib_sub_s1[Gi];
end
endgenerate

wire    [31:0]  stage3_msb, stage3_lsb;

assign stage3_lsb   =   {stage2_lsb[20:0],stage2_lsb[31:21]};
assign stage3_msb   =   {stage2_msb[20:0],stage2_msb[31:21]};

always  @(posedge clock)
if(enable) begin
    op3_s1      <=  op3;
    data_s1     <=  {stage3_msb,stage3_lsb};
end

//wire    [31:0]   stage4_msb, stage4_lsb;

//assign  stage4_msb  =   stage3_msb ^ op3_s1[63:32];
//assign  stage4_lsb  =   stage3_lsb ^ op3_s1[31:0];

assign  result  =   data_s1 ^ op3_s1;
assign  def_res =   def_res_s1;

endmodule
`endif
