module Converter(
    input clk,
    input rst,
    input [4:0] din,
    input ivalid,
    output iready,
    output [4:0] dout,
    output ovalid,
    input oready
);

wire isNum = 5'h0 <= din && din <= 5'hf;
Token tok();

reg [2:0] fn;
localparam NOP = 3'h0;
localparam FWD = 3'h1;
localparam PUSH = 3'h2;
localparam POP = 3'h3;
localparam DROP = 3'h4;
localparam XCHG = 3'h5;
localparam DEQ = 3'h6;

always @(din or ivalid or stack.dout or stack.empty) begin
    if (!ivalid) fn = stack.empty || stack.dout == tok.LEFT ? NOP : POP;
    else if (isNum) fn = FWD;
    else case (din)
        tok.ADD: fn = stack.empty || stack.dout == tok.LEFT ? PUSH : stack.dout == tok.MUL ? POP : XCHG;
        tok.SUB: fn = stack.empty || stack.dout == tok.LEFT ? PUSH : stack.dout == tok.MUL ? POP : XCHG;
        tok.MUL: fn = stack.empty || stack.dout != tok.MUL ? PUSH : XCHG;
        tok.LEFT: fn = PUSH;
        tok.RIGHT: fn = stack.empty ? DEQ : stack.dout == tok.LEFT ? DROP : POP;
        tok.EVAL: fn = stack.empty ? DEQ : stack.dout == tok.LEFT ? DROP : POP;
        default: fn = NOP;
    endcase
end

//assign iready = (postfix.enq && !postfix.full) || (stack.push && !stack.full);
assign iready = fn != NOP && fn != POP;
assign ovalid = !postfix.empty;

Stack #(.WIDTH(5), .SIZE(16)) stack(
    .clk(clk),
    .rst(rst),
    .push(fn == PUSH || fn == XCHG),
    .pop(fn == POP || fn == DROP || fn == XCHG),
    .din(din)
);

Queue #(.WIDTH(5), .SIZE(16)) postfix(
    .clk(clk),
    .rst(rst),
    .enq(fn == FWD || fn == POP || fn == XCHG),
    .deq(oready && ovalid),
    .din(fn == FWD ? din : stack.dout),
    .dout(dout)
);

endmodule
