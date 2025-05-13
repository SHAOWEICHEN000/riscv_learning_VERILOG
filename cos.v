`ifndef COS_V
`define COS_V

module cos_fixed #(
    parameter ITER = 7 // 建議不要超過 100，避免溢位和過度延遲
)(
    input  wire signed [31:0] x,   // Q16.16 弧度輸入
    output reg  signed [31:0] y    // Q16.16 cos(x)
);

    integer i;
    reg signed [63:0] term;
    reg signed [63:0] num;         // 分子 x^n
    reg signed [63:0] factorial;   // 分母 n!
    reg signed [63:0] one;         // 1.0 (Q16.16)
    reg signed [63:0] sum;
    reg sign;

    always @(*) begin
        one = 64'sd1 << 16;
        sum = one;      // y = 1
        sign = 1'b1;    // 第一個項是 -x²/2!
        num = (x * x) >> 16;  // x²
        factorial = 64'd2;
        //$display(" x_input=%0f",  x);
        for (i = 1; i < ITER; i = i + 1) begin
            term = num / factorial;

            if (sign)
                sum = sum - term;
            else
                sum = sum + term;

            // 更新下一項：num = num * x² (Q16.16)
            num = (num * ((x * x) >>> 16)) >>> 16;

            // 更新 factorial：n *= (2i+1)(2i+2)
            factorial = factorial * (2 * i + 1);
            factorial = factorial * (2 * i + 2);

            sign = ~sign;
        end

        y = sum[31:0];  // 轉回 Q16.16 結果
    end

endmodule

`endif
