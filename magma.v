module magma (
    input wire          clk,           //
    input wire          reset_,        //
    input wire          start,         // старт
    input wire [63:0]   data_in,       // входные данные
    input wire [255:0]  key,           // 256-битный ключ
    output reg [63:0]   data_out,      // шифр
    output reg          done           // финиш
);

    // Внутренние регистры и провода
    reg  [31:0] left, right;           // Левый и правый 32-битные блоки
    wire [31:0] round_keys [0:31];     // Раундовые ключи
    reg  [5:0]  round;                 // номер текущего раунда (0-31)
    reg  [31:0] temp, s_result;        //
    //wire [31:0] sbox_output;         // выход S-блоков
    reg work;                          // статус работы блока

    // провода S-блоков
    //wire [31 : 0] apply_sbox;
    //wire [3  : 0] nibble [7 : 0];

    // инициализация S-блоков
    wire [3:0] SBOX [0:7][0:15];

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

        genvar i;
        generate
            for (i = 0; i < 32; i = i + 1) begin : gen_round_keys
                if (i < 24) begin
                    assign round_keys[i] = key[255 - (i % 8) * 32 -: 32];
                end else begin
                    assign round_keys[i] = key[255 - (7 - i % 8) * 32 -: 32];
                end
            end
        endgenerate

        always @(posedge clk or negedge reset_)
		      if (~reset_)
					work <= 1'b0;
				else
					work <= (start)? 1'b1 :
							  (done )? 1'b0 :
							  work;

        always @(posedge clk or negedge reset_) begin
            if (~reset_) begin
                left  <= 0;
                right <= 0;
                round <= 0;
                done  <= 0;
            end else if (work) begin
                if (round == 0) begin
                    left  <= data_in[63:32];
                    right <= data_in[31:0];
                    round <= 1;
                    done  <= 0;
                end else if (round <= 32) begin
                    temp <= right + round_keys[round - 1];

                    s_result <= {SBOX[7][temp[28+:4]], SBOX[6][temp[24+:4]],
                                 SBOX[5][temp[20+:4]], SBOX[4][temp[16+:4]],
                                 SBOX[3][temp[12+:4]], SBOX[2][temp[8+:4]],
                                 SBOX[1][temp[4+:4]],  SBOX[0][temp[0+:4]]};

                    s_result <= {s_result[21:0], s_result[31:22]}; // циклический сдвиг на 11 бит
                    right <= left ^ s_result;
                    left <= right;
                    round <= round + 1;
                end else begin
                    data_out <= {right, left};
                    done <= 1;
                end
            end
        end

endmodule
