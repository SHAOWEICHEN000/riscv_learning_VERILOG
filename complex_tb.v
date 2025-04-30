`timescale 1ns/1ps
`include "complex.v"
`include "log2.v"
`include"pi.v"
module complex_tb;

    // === 測試向量 (32-bit 定點示例) =========================
    reg  signed [31:0] a_re, a_im, b_re, b_im;
    reg  [31:0] N;
    wire [31:0]log2;
    wire [31:0]pi;
    wire signed [31:0] add_re, add_im;
    wire signed [31:0] sub_re, sub_im;
    wire signed [63:0] mul_re, mul_im;   // 乘法輸出 2×WIDTH
    
    // === 例化模組 =========================================
    complex_add u_add(.a_re(a_re), .a_im(a_im),
                      .b_re(b_re), .b_im(b_im),
                      .c_re(add_re), .c_im(add_im));
    complex_sub u_sub(.a_re(a_re), .a_im(a_im),
                      .b_re(b_re), .b_im(b_im),
                      .c_re(sub_re), .c_im(sub_im));
    complex_mul u_mul(.a_re(a_re), .a_im(a_im),
                      .b_re(b_re), .b_im(b_im),
                      .c_re(mul_re), .c_im(mul_im));
    log2        u_log(.N_in(N),.log2(log2));	
    pi          u_pi(.pi(pi));
    // === 測試流程 =========================================
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, complex_tb);
        a_re = 32'sd3;   a_im = 32'sd4;    // 3 + j4
        b_re = 32'sd1;   b_im = 32'sd2;    // 1 + j2
        N=32'sd32;
        #5;   // 等待組合邏輯穩定
        $display("ADD: (%0d , %0d)", add_re, add_im);     // 4 , 6
        $display("SUB: (%0d , %0d)", sub_re, sub_im);     // 2 , 2
        $display("MUL: (%0d , %0d)", mul_re, mul_im);     // -5 , 10
 	$display("log(%0d)=%0d",N,log2);		  //log2(32)=5
$display("π (Q16.16) raw = %0d", pi);
$display("π ≈ %f", pi / 65536.0);

        #5 $finish;
    end
endmodule
