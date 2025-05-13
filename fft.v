//=============================
// fft.v
//=============================
`ifndef FFT_V
`define FFT_V
`timescale 1ns/1ps

`include "complex.v"
`include "log2.v"
`include "pi.v"
`include "bit_reverse.v"
`include "sin.v"
`include "cos.v"

`define WIDTH 32

module fft #(parameter w=`WIDTH) (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [31:0] x_Re[0:7],
    input wire [31:0] x_Im[0:7],
    input wire [31:0] N,
    output reg [31:0] FFT,
    output reg done
);
    integer k, i, j, b;
    reg signed [31:0] Theta_T,Theta_T1, phi_T_Re, phi_T_Im, T_Re, T_Im, temp_Re, temp_Im;
    reg signed [31:0] x_Re_reg[0:7];
    reg signed [31:0] x_Im_reg[0:7];
    reg signed [31:0] pi_D;
    	

    integer ii,a, m, n;

    wire  signed[31:0] y_cos1, y_sin1;
    wire signed [31:0] add_Re, add_Im, sub_Re, sub_Im;
    wire  signed[31:0] mul1_Re, mul1_Im, mul2_Re, mul2_Im;
    wire signed [31:0] log2_out, pi_out, bit_reverse_out;

    reg [3:0] state;
    localparam IDLE=0, LOAD=1, CALC=2, DONE=3;

    complex_add u_add(.a_re(x_Re_reg[j]), .a_im(x_Im_reg[j]),
                      .b_re(x_Re_reg[b]), .b_im(x_Im_reg[b]),
                      .c_re(add_Re), .c_im(add_Im));
    complex_sub u_sub(.a_re(x_Re_reg[j]), .a_im(x_Im_reg[j]),
                      .b_re(x_Re_reg[b]), .b_im(x_Im_reg[b]),
                      .c_re(sub_Re), .c_im(sub_Im));
    complex_mul u_mul1(.a_re(T_Re), .a_im(T_Im),
                       .b_re(phi_T_Re), .b_im(phi_T_Im),
                       .c_re(mul1_Re), .c_im(mul1_Im));
    complex_mul u_mul2(.a_re(temp_Re), .a_im(temp_Im),
                       .b_re(T_Re), .b_im(T_Im),
                       .c_re(mul2_Re), .c_im(mul2_Im));
    log2 u_log(.N_in(N), .log2(log2_out));
    pi u_pi(.pi(pi_out));
    bit_reverse u_bit_reverse(.b(b), .m(m), .result(bit_reverse_out));
    cos_fixed u_cos1(.x(Theta_T), .y(y_cos1));
    sin_fixed u_sin2(.x(Theta_T), .y(y_sin1));

    always @(posedge clk or posedge rst) begin
        if (rst) begin
             done <= 0;
             FFT <= 0;
             state <= IDLE;
             pi_D = 0;
             m=0;
             Theta_T =0;
             Theta_T1 =0;
             phi_T_Re=0;
             phi_T_Im=0;	
             T_Re=1;
             T_Im=0;
        end else begin
            case (state)
                IDLE: if (start) begin
                	 state <= LOAD;
			 	
             		end
                LOAD: begin
                    for (ii = 0; ii < 8; ii = ii + 1) begin
                        x_Re_reg[ii] = x_Re[ii];
                        x_Im_reg[ii] = x_Im[ii];
                        //$display(" input_x_Re=%0f",  x_Re_reg[ii] );
                       // $display(" input_x_Im=%0f",  x_Im_reg[ii] );
                    end
                    state <= CALC;
                end

                CALC: begin
                    k = N;
                     	//$display("start");
                     	//$display("statte=%0d",state);
                    while (k > 1) begin
                    	
                    	//$display("pi_out=%0f", pi_out/65536.0	);
                        //$display("N=%0f", N );
                        
                       
		
                        n = k;
                        k = k >> 1;
                        pi_D=pi_out;
                        //$display("pi_D=%0f", pi_D/65536.0);
                        Theta_T= (pi_out) *2.0/ N;
		        #10
                        //$display("Theta_T = %0f", Theta_T / 65536.0);
	    		
                        phi_T_Re = y_cos1;
                        phi_T_Im = -y_sin1;
                        //$display(" phi_T_Re=%0f",  phi_T_Re/65536.0);
                        //$display(" phi_T_Im=%0f",  phi_T_Im/65536.0);
                        T_Re=32'sd65536;//65536.0
                        T_Im=32'sd0;
                        //$display(" T_Re2=%0f",  T_Re);
			//$display(" T_Im2=%0f",  T_Im);
                        for (i = 0; i < k; i = i + 1) begin
                            for (j = i; j < N; j = j + n) begin
                                b = j + k;
                                #10
                                temp_Re = sub_Re;
                                temp_Im = sub_Im;
                                
                   		//$display("sub temp_Re=%0f,temp_Im=%0f", temp_Re/65536.0,temp_Im/65536.0);
		      		
		      		#10
                                x_Re_reg[j] = add_Re;
                                x_Im_reg[j] = add_Im;
                                
                   		//$display("add x_Re_reg[%0d]=%0f,x_Im_reg[%0d]=%0f",j,   x_Re_reg[j]/65536.0,j,x_Im_reg[j]/65536.0);
		      		
		      		#10
                                x_Re_reg[b] = mul2_Re;
                                #10
                                x_Im_reg[b] = mul2_Im;
                                
                   		//$display("mul x_Re_reg[%0d]=%0f,x_Im_reg[%0d]=%0f",b,   x_Re_reg[b]/65536.0,b,x_Im_reg[b]/65536.0);
		      	
                            end
                            T_Re = mul1_Re;                            
                            T_Im = mul1_Im;
                            //$display(" fin_Re=%0f,fin_Im=%0f",   T_Re/65536.0,T_Im/65536.0);
			   
                        end
                        m = log2_out;
                        #10
                        //$display(" m=%0f", m);
                        for (a = 0; a < N; a = a + 1) begin
                            b=a;
                        #10
                            b = bit_reverse_out;
                            	
		    	    
                        #10
                            if (b > a) begin
                                temp_Re = x_Re_reg[a];                                
                                temp_Im = x_Im_reg[a];                                
                                x_Re_reg[a] = x_Re_reg[b];
                                x_Im_reg[a] = x_Im_reg[b];                                
                                x_Re_reg[b] = temp_Re;                              
                                x_Im_reg[b] = temp_Im;
                            end
                        end
                    end
                    for(i=0;i<N;i++) begin
                    $display(" final: x_Re_reg[%0d]=%0f,x_Im_reg[%0d]=%0f",i,   x_Re_reg[i]/65536.0,i,x_Im_reg[i]/65536.0);
		
		    end
		    #10
                    FFT <= x_Re_reg[0];
                    done <= 1;
                    state <= DONE;
                end

                DONE: ; // 保持狀態直到重置
            endcase
        end
    end
endmodule

`endif
