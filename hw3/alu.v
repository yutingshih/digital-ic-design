module ALU #(parameter WIDTH = 4) (
    input [WIDTH-1:0] src1,
    input [WIDTH-1:0] src2,
    input [4:0] op,
    output reg [WIDTH+WIDTH-1:0] out
);

Token tok();

always @(*) begin
    case (op)
        tok.ADD: out = src1 + src2;
        tok.SUB: out = src1 - src2;
        tok.MUL: out = src1 * src2;
        default: out = 'bx;
    endcase
end

endmodule
