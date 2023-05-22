module Parser(
    input clk,
    input rst,
    input [7:0] din,
    input ivalid,
    output iready,
    output [4:0] dout,
    output ovalid,
    input oready
);

reg [4:0] compressed;
Token tok();

Queue #(.WIDTH(5), .SIZE(16)) infix(
    .clk(clk),
    .rst(rst),
    .enq(iready && ivalid),
    .deq(oready && ovalid),
    .din(compressed),
    .dout(dout)
);

assign iready = !infix.full;
assign ovalid = !infix.empty;

always @(din) begin
    case (din)
        8'd48: compressed = 5'd0;
        8'd49: compressed = 5'd1;
        8'd50: compressed = 5'd2;
        8'd51: compressed = 5'd3;
        8'd52: compressed = 5'd4;
        8'd53: compressed = 5'd5;
        8'd54: compressed = 5'd6;
        8'd55: compressed = 5'd7;
        8'd56: compressed = 5'd8;
        8'd57: compressed = 5'd9;
        8'd97: compressed = 5'd10;
        8'd98: compressed = 5'd11;
        8'd99: compressed = 5'd12;
        8'd100: compressed = 5'd13;
        8'd101: compressed = 5'd14;
        8'd102: compressed = 5'd15;
        8'd40: compressed = tok.LEFT;
        8'd41: compressed = tok.RIGHT;
        8'd42: compressed = tok.MUL;
        8'd43: compressed = tok.ADD;
        8'd45: compressed = tok.SUB;
        8'd61: compressed = tok.EVAL;
        default: compressed = 'bx;
    endcase
end

endmodule
