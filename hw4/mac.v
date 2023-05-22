module MAC #(parameter WIDTH = 16) (
    input clk,
    input rst,
    input en,
    input signed [WIDTH-1:0] src1,
    input signed [WIDTH-1:0] src2,
    input signed [WIDTH-1:0] init_val,
    output reg signed [WIDTH<<1:0] psum
);

    always @(posedge clk or posedge rst) begin
        if (rst) psum <= {WIDTH+1'b0, init_val};
        else if (en) psum <= {WIDTH+1'b0, src1} * {WIDTH+1'b0, src2} + {WIDTH+1'b0, psum};
        else psum <= psum;
    end

endmodule
