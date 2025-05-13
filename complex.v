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
	// ------------------------ complex_mul ------------------------
	module complex_mul #(parameter W = 32)(
	    input  signed [W-1:0] a_re, a_im,
	    input  signed [W-1:0] b_re, b_im,
	    output signed [W-1:0] c_re,
	    output signed [W-1:0] c_im
	);
	    // 乘完先保持 64bit 精度
	wire signed [63:0] p_re = a_re * b_re - a_im * b_im;
	wire signed [63:0] p_im = a_re * b_im + a_im * b_re;
	
    	    // Q16.16 → 回到原位寬，這裡做四捨五入
	wire signed [63:0] p_re_rnd = p_re + 32'sd32768;   // +0.5
    	wire signed [63:0] p_im_rnd = p_im + 32'sd32768;

    	assign c_re = p_re_rnd[47:16];  // >>16（取 31..16）
    	assign c_im = p_im_rnd[47:16];
endmodule


	`endif
