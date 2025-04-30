	// =====================================================
	// complex.v  (Verilog-2001)
	//   - complex_add : (a_re + jb_im) + (c_re + jd_im)
	//   - complex_mul : (a + jb) × (c + jd)
	// -----------------------------------------------------
	// ★ 整數定點示例：   WIDTH = 16 → Q15.0
	//   要用浮點(IP)時，把乘法換成 fp_multiplier 即可
	// =====================================================

	`ifndef COMPLEX_V
	`define COMPLEX_V

	// ---------- 可調參數 -----------------
	`define WIDTH 32               // 單一實、虛部位寬

	// ---------- 加法 ---------------------
	module complex_add
	#(parameter W=`WIDTH)
	(
	    input  signed [W-1:0] a_re, a_im,
	    input  signed [W-1:0] b_re, b_im,
	    output signed [W-1:0] c_re, c_im
	);
	    assign c_re = a_re + b_re;
	    assign c_im = a_im + b_im;
	endmodule

	//-----------sub-----------------------
	module complex_sub
	#(parameter W=`WIDTH)
	(
	    input  signed [W-1:0] a_re, a_im,
	    input  signed [W-1:0] b_re, b_im,
	    output signed [W-1:0] c_re, c_im
	);
	    assign c_re = a_re -b_re;
	    assign c_im = a_im - b_im;
	endmodule
	// ---------- 乘法 ---------------------
	// re = ar*br - ai*bi
	// im = ar*bi + ai*br
	module complex_mul
	#(parameter W=`WIDTH)
	(
	    input  signed [W-1:0] a_re, a_im,
	    input  signed [W-1:0] b_re, b_im,
	    output signed [2*W-1:0] c_re, // 乘法後位寬加倍
	    output signed [2*W-1:0] c_im
	);
	    wire signed [2*W-1:0] p1 = a_re * b_re;
	    wire signed [2*W-1:0] p2 = a_im * b_im;
	    wire signed [2*W-1:0] p3 = a_re * b_im;
	    wire signed [2*W-1:0] p4 = a_im * b_re;

	    assign c_re = p1 - p2;
	    assign c_im = p3 + p4;
	endmodule

	`endif
