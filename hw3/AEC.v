module AEC(
    input clk,
    input rst,
    input ready,
    input [7:0] ascii_in,
    output valid,
    output [6:0] result
);

reg [7:0] testcase;
reg [7:0] in_r;
wire last = in_r == 8'd61; // ASCII code of "=" is 61

reg [2:0] state;
localparam IDLE = 3'd0;
localparam INPUT = 3'd1;
localparam PARSE = 3'd2;
localparam CONVERT = 3'd3;
localparam EVALUATE = 3'd4;
localparam OUTPUT = 3'd5;

Parser parser(
    .clk(clk),
    .rst(rst || state == OUTPUT),
    .din(in_r),
    .ivalid(state == INPUT),
    .oready(converter.iready)
);

Converter converter(
    .clk(clk),
    .rst(rst || state == IDLE),
    .din(parser.dout),
    .ivalid(parser.ovalid),
    .oready(evaluator.iready)
);

Evaluator evaluator(
    .clk(clk),
    .rst(rst || state == IDLE),
    .din(converter.dout),
    .ivalid(converter.ovalid),
    .oready(!rst)
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        testcase <= 1;
    end
    else begin
        in_r <= ascii_in;
        case (state)
            IDLE: if (ready && parser.iready) state <= INPUT;
            INPUT: if (last) state <= PARSE;
            PARSE: if (!parser.ovalid) state <= CONVERT;
            CONVERT: if (!converter.ovalid) state <= EVALUATE;
            EVALUATE: if (evaluator.ovalid) state <= OUTPUT;
            OUTPUT: begin
                testcase <= testcase + 1;
                state <= IDLE;
            end
            default: state <= IDLE;
        endcase
    end
end

assign valid = state == OUTPUT;
assign result = evaluator.dout;

endmodule
