`timescale 1ns/1ps
`include "complex.v"
`include "log2.v"
`include "pi.v"
`include "bit_reverse.v"
`include "fft.v"
`include "cos.v"
`include "sin.v"

module complex_tb;
    parameter NUM = 8;

    // 基本變數
    reg  signed [31:0] a_re, a_im, b_re, b_im;
    reg  [31:0] N;
    wire [31:0] log2;
    wire [31:0] pi;
    wire signed [31:0] add_re, add_im;
    wire signed [31:0] sub_re, sub_im;
    wire signed [63:0] mul_re, mul_im;
    reg  [31:0] b, m;
    wire [31:0] result;

    // Cos/Sin 測試
    reg signed [31:0] x;             // Q16.16
    wire signed [31:0] y_cos, y_sin; // Q16.16 輸出

    // FFT 測試
    reg clk = 0;
    reg rst;
    reg start;
    reg [31:0] x_Re[0:NUM-1];
    reg [31:0] x_Im[0:NUM-1];
    reg [31:0] N_fft;
    wire [31:0] FFT;
    wire done;

    // 時脈產生 (100 MHz)
    always #5 clk = ~clk;
	
    // === 模組例化 ===
    complex_add u_add(.a_re(a_re), .a_im(a_im), .b_re(b_re), .b_im(b_im), .c_re(add_re), .c_im(add_im));
    complex_sub u_sub(.a_re(a_re), .a_im(a_im), .b_re(b_re), .b_im(b_im), .c_re(sub_re), .c_im(sub_im));
    complex_mul u_mul(.a_re(a_re), .a_im(a_im), .b_re(b_re), .b_im(b_im), .c_re(mul_re), .c_im(mul_im));
    log2        u_log(.N_in(N), .log2(log2));
    pi          u_pi(.pi(pi));
    bit_reverse u_bit_reverse(.b(b), .m(m), .result(result));
    cos_fixed   u_cos(.x(x), .y(y_cos));
    sin_fixed   u_sin(.x(x), .y(y_sin));

    fft u_fft(
        .clk(clk), .rst(rst), .start(start),
        .x_Re(x_Re), .x_Im(x_Im), .N(N_fft),
        .FFT(FFT), .done(done)
    );

    // === 測試流程 ===
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, complex_tb);

        // === 複數基本運算測試 ===
        a_re = 	32'sd85197; a_im = 32'sd117964 ;   // 3 + j4
        b_re = 	32'sd91750 ; b_im = 32'sd131072 ;   // 1 + j2
        b = 32'd5; m = 32'd5;
        N = 32'd32;

        // === FFT 輸入資料 ===
        x_Re[0] = 32'sd65536;  x_Re[1] = 32'sd65536;
        x_Re[2] = 32'sd65536; x_Re[3] = 32'sd65536;
        x_Re[4] = 32'sd0;        x_Re[5] = 32'sd0;
        x_Re[6] = 32'sd0;        x_Re[7] = 32'sd0;

        x_Im[0] = 0<<16; x_Im[1] = 0<<16; x_Im[2] = 0<<16; x_Im[3] = 0<<16;
        x_Im[4] = 0<<16; x_Im[5] = 0<<16; x_Im[6] = 0<<16; x_Im[7] = 0<<16;

        // === 控制 FFT ===
        N_fft = 32'sd8;
        rst = 1; start = 0;
        #20 rst = 0;
        #40 start = 1;

        // === 測試 cos/sin ===
        x = 2.5*65536.0; // 約等於 pi/3 ≈ 1.57 rad ≈ Q16.16 = 0x19220

        wait(done); // 等 FFT 完成

        // === 顯示結果 ===
        $display("FFT result: %d", FFT);
        $display("ADD: (%0f , %0f)", add_re/65536.0, add_im/65536.0);
        $display("SUB: (%0f , %0f)", sub_re/65536.0, sub_im/65536.0);
      	$display("MUL: (%0f , %0f)", $itor(mul_re) / 65536.0,$itor(mul_im) / 65536.0);

        $display("log(%0d) = %0d", N, log2);
        $display("π (Q16.16) raw = %0d", pi);
        $display("π ≈ %f", pi / 65536.0);
        $display("bit reverse: %d", result);
        $display("cos(%f) ≈ %f", x / 65536.0, y_cos / 65536.0);
        $display("sin(%f) ≈ %f", x / 65536.0, y_sin / 65536.0);

        #100 $finish;
    end
endmodule
