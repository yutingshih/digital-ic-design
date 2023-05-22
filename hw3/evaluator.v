module Evaluator(
    input clk,
    input rst,
    input [4:0] din,
    input ivalid,
    output iready,
    output [6:0] dout,
    output ovalid,
    input oready
);

assign isNum = 5'h0 <= din && din <= 5'hf;
assign isOp = !isNum;
reg [6:0] src1, src2;
reg [4:0] op;
Token tok();

reg [1:0] state;
localparam IDLE = 2'd0;
localparam FETCH = 2'd1;
localparam POP = 2'd2;
localparam CALC = 2'd3;

always @(posedge clk or posedge rst) begin
    if (rst) state <= IDLE;
    else case (state)
        IDLE: if (ivalid) state <= FETCH;
        FETCH:
            if (!ivalid) state <= IDLE;
            else if (isNum) state <= FETCH;
            else state <= POP;
        POP: state <= CALC;
        CALC: state <= FETCH;
        default: state <= IDLE;
    endcase
end

Stack #(.WIDTH(7), .SIZE(16)) stack(
    .clk(clk),
    .rst(rst),
    .push((state == FETCH && isNum) || state == CALC),
    .pop((state == FETCH && isOp) || state == POP),
    .din(state == CALC ? alu.out[6:0] : {2'b0, din})
);

ALU #(.WIDTH(7)) alu(.src1(src1), .src2(src2), .op(op));

always @(posedge clk or posedge rst) begin
    if (rst) begin
        src1 <= 0;
        src2 <= 0;
        op <= tok.UNKNOWN;
    end else case (state)
        IDLE: begin
            src1 <= 0;
            src2 <= 0;
            op <= tok.UNKNOWN;
        end
        FETCH: if (isOp) begin
            src2 <= stack.dout;
            op <= din;
        end
        POP: src1 <= stack.dout;
    endcase
end

assign iready = state == FETCH && !stack.full;
//assign ovalid = !stack.empty;
assign ovalid = stack.size == 1;
assign dout = stack.dout;

endmodule
