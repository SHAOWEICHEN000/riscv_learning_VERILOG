`ifndef SIN_V
`define SIN_V

module sin_fixed #(
    parameter ITER = 30  // 可選項數，建議不要超過 100
)(
    input  wire signed [31:0] x,   // Q16.16 格式輸入
    output reg  signed [31:0] y    // Q16.16 格式輸出 sin(x)
);

    integer i;
    reg signed [63:0] term;
    reg signed [63:0] num;         // x^n（分子）
    reg signed [63:0] factorial;   // n!（分母）
    reg signed [63:0] sum;
    reg sign;

    always @(*) begin
        sum = x;         // sin(x) = x - x³/3! + x⁵/5! - ...
        sign = 1'b1;     // 下一項是 -x³/3!
        num = (x * x) >>> 16;       // x²
        num = (num * x) >>> 16;     // x³
        factorial = 64'd6;          // 3!

        for (i = 1; i < ITER; i = i + 1) begin
            term = num / factorial;

            if (sign)
                sum = sum - term;
            else
                sum = sum + term;

            // num = num * x²
            num = (num * ((x * x) >>> 16)) >>> 16;

            // factorial *= (2i+2)(2i+3)
            factorial = factorial * (2 * i + 2);
            factorial = factorial * (2 * i + 3);

            sign = ~sign;
        end

        y = sum[31:0];  // 回傳 Q16.16 格式
    end

endmodule

`endif
	
