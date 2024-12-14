`timescale 10ns / 1ns

`include "magma.v"

module top();

wire magma_done = MAGMA.done;
wire [63:0] data_out = MAGMA.data_out;

reg clk = 1'b0;
reg rst = 1'b0;

reg encr_decr = 1;

reg [63:0] data_in;

reg [255:0] key = 256'hdeda1eda1a1baba1beda1daaa42aa1303ded1c9ef1ed61da4a41bab3da1bed61; //256'hffeeddccbbaa99887766554433221100f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff;

reg m_start = 1'b0;

always @(posedge clk) 
    data_in <= (encr_decr == 1)? 64'hfedcba9876543210 : 64'h2be3e3aba70f6dd2; //64'h4ee901e5c2d8ca3d;

always #1 clk = ~clk;

initial begin
    #20   rst = ~rst;

    #10   m_start <= 1'b1;
    #2    m_start <= 1'b0;

    #350 encr_decr <= 0;

    #10   m_start <= 1'b1;
    #2    m_start <= 1'b0;

    #350 encr_decr <= 1;

    #10   m_start <= 1'b1;
    #2    m_start <= 1'b0;

end

magma MAGMA (
             .clk       ( clk        ),         //
             .reset_    ( rst        ),         //
             .start     ( m_start    ),         // старт
             .data_in   ( data_in    ),         // входные данные
             .key       ( key        ),         // 256-битный ключ
             .encr_decr ( encr_decr  ),         // выбор шифрования или расшифрования

             .data_out  (            ),         // шифр
             .done      (            )          // финиш
);


endmodule
