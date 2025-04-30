`ifndef PI_V
`define PI_V
`define WIDTH 32

	module pi 
		#(parameter w=`WIDTH)
		(
			output reg[w-1:0] pi
		);
		
		reg signed [31:0]sign;//sign need array
		reg signed [31:0] i;
		reg signed [31:0] iter;
		reg signed [31:0] domin;
	
		initial begin
			sign=1;
			i=0;
			iter=2000;
			pi = (1 << 16);  // 正確，表示 1.0 in Q16.16
			domin=1;
			while(i <iter) begin
				domin=domin+2;
				sign=-sign;
				pi=pi+sign*((1<<<16)/domin);
				i=i+1;
			end
			pi=pi*4;
		end
	endmodule
`endif
