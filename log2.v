`ifndef LOG2_V
`define LOG2_V
`define WIDTH 32
 module log2
 	#(parameter W=`WIDTH)
 	(
 		input wire [W-1:0] N_in,
 		output reg [W-1:0] log2
  
 	);
	reg [W-1:0] N; 
	always @(*) begin
		N=N_in;
		log2=0;
		while(N>>1) begin
			N=N>>1;
			log2 = log2 + 1;
		end
	end
 endmodule  
`endif 
