module Queue #(parameter WIDTH = 4, SIZE = 16) (
        input clk,
        input rst,
        input enq,
        input deq,
        input [WIDTH-1:0] din,
        output [WIDTH-1:0] dout,
        output empty,
        output full
    );

    localparam REALSIZE = SIZE + 1;  // real size = number of elements + 1
    reg [WIDTH-1:0] mem [REALSIZE-1:0];
    reg [$clog2(REALSIZE):0] head, tail;

    // output signals
    assign empty = head == tail;
    assign full = (tail + 1) % REALSIZE == head;
    assign dout = mem[head];

    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            head <= 0;
            tail <= 0;
            for (i = 0; i < REALSIZE; i = i + 1)
                mem[i] = 'bx;
        end else begin
            if (enq && !full) begin
                tail <= (tail + 1) % REALSIZE;
                mem[tail] <= din;
            end
            if (deq && !empty) begin
                head <= (head + 1) % REALSIZE;
                mem[head] <= 'bx;
            end
        end
    end

endmodule
