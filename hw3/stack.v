module Stack #(parameter WIDTH = 4, SIZE = 16) (
        input clk,
        input rst,
        input push,
        input pop,
        input [WIDTH-1:0] din,
        output [WIDTH-1:0] dout,
        output [$clog2(SIZE)-1:0] size,
        output empty,
        output full
    );

    reg [WIDTH-1:0] mem [SIZE-1:0];
    reg [$clog2(SIZE)-1:0] sp;

    // output signals
    assign empty = sp == 0;
    assign full = sp == SIZE;
    assign dout = mem[sp - 1];
    assign size = sp;

    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sp <= 0;
            for (i = 0; i < SIZE; i = i + 1)
                mem[i] = 'bx;
        end begin
            if (push && !pop && !full) begin
                sp <= sp + 1;
                mem[sp] <= din;
            end else if (!push && pop && !empty) begin
                sp <= sp - 1;
                mem[sp - 1] <= 'bx;
            end else if (push && pop && !empty) begin
                mem[sp - 1] <= din;
            end else if (push && pop && empty) begin
                sp <= sp + 1;
                mem[sp] <= din;
            end
        end
    end

endmodule
