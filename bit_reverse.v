`ifndef BIT_REVERSE_V
`define BIT_REVERSE_V
`define WIDTH 32

module bit_reverse #(parameter w = `WIDTH)(
    input  wire [31:0] b,
    input  wire [31:0] m,
    output reg  [31:0] result
);

    integeri;  // 用 integer 比 reg signed 更標準

    always @(*) begin
        result = 0;
        for (i = 0; i < m; i = i + 1)
            result = result | ((b[i]) << ((m - 1) - i));
    end

endmodule
`endif
