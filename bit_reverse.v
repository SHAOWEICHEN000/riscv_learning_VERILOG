`ifndef BIT_REVERSE_V
`define BIT_REVERSE_V
`define WIDTH 32

module bit_reverse (
    input  wire [31:0] b,    // 要進行 bit reverse 的輸入值
    input  wire [31:0] m,    // 要反轉幾個 bit (例如 log2(N))
    output reg  [31:0] result
);

    integer i;
    reg [31:0]b1;

    always @(*) begin
        result = 0;
        for (i = 0; i < m; i = i + 1) begin
            b1=(b >> i) & 32'd1;
            result = result | (b1 << ((m - 1) - i));
        end
    end

endmodule
`endif
