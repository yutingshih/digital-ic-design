module Controller(
    input clk,
    input rst,
    input ready,
    output busy,
    output reg [6:0] in_row,
    output reg [6:0] in_col,
    output read,
    output write,
    output reg [11:0] raddr,
    output reg [11:0] waddr,
    output csel,
    output mac_rst,
    output mac_en,
    output reg [3:0] kern_sel
);

    reg [5:0] base_row = 0;
    reg [5:0] base_col = 0;
    reg [6:0] offset_row = 0;
    reg [6:0] offset_col = 0;

    localparam IDLE = 4'hf;
    localparam MAC0 = 4'h0;
    localparam MAC1 = 4'h1;
    localparam MAC2 = 4'h2;
    localparam MAC3 = 4'h3;
    localparam MAC4 = 4'h4;
    localparam MAC5 = 4'h5;
    localparam MAC6 = 4'h6;
    localparam MAC7 = 4'h7;
    localparam MAC8 = 4'h8;
    localparam BIAS = 4'h9;
    reg [3:0] conv_state = IDLE;

    localparam NOP = 3'h0;  // neither read nor write
    localparam TMP = 3'h1;  // neither read nor write
    localparam WR0 = 3'h2;  // write to layer 0 memory
    localparam RD1 = 3'h3;  // read from layer 1 memory
    localparam WR1 = 3'h4;  // write to layer 1 memory
    reg [2:0] io_state = NOP;

    // conv_state transition
    always @(posedge clk or posedge rst) begin
        if (rst) conv_state <= IDLE;
        else case (conv_state)
            IDLE: if (ready) conv_state <= BIAS;
            BIAS: conv_state <= MAC0;
            MAC0: conv_state <= MAC1;
            MAC1: conv_state <= MAC2;
            MAC2: conv_state <= MAC3;
            MAC3: conv_state <= MAC4;
            MAC4: conv_state <= MAC5;
            MAC5: conv_state <= MAC6;
            MAC6: conv_state <= MAC7;
            MAC7: conv_state <= MAC8;
            MAC8: conv_state <= (base_row == 63 && base_col == 63) ? IDLE : BIAS;
            default: conv_state <= IDLE;
        endcase
    end

    // io_state transition
    always @(posedge clk or posedge rst) begin
        if (rst) io_state <= NOP;
        else case (io_state)
            NOP: if (conv_state == MAC8) io_state <= TMP;
            TMP: io_state <= WR0;
            WR0: io_state <= RD1;
            RD1: io_state <= WR1;
            WR1: io_state <= NOP;
            default: io_state <= NOP;
        endcase
    end

    assign busy = conv_state != IDLE || io_state != NOP;
    assign mac_en = conv_state < BIAS;  // MAC0 ~ MAC8
    assign mac_rst = conv_state == BIAS || conv_state == IDLE;

    assign read = io_state == RD1;
    assign write = io_state == WR0 || io_state == WR1;
    assign csel = io_state == RD1 || io_state == WR1;

    always @(*) begin
        case (conv_state)
            // IDLE: begin
            //     offset_row = 'hx;
            //     offset_col = 'hx;
            //     kern_sel = 4'hf;
            // end
            // BIAS: begin
            //     offset_row = 'hx;
            //     offset_col = 'hx;
            //     kern_sel = 4'hf;
            // end
            MAC0: begin
                offset_row = 0;
                offset_col = 0;
                kern_sel = 0;
            end
            MAC1: begin
                offset_row = 0;
                offset_col = 2;
                kern_sel = 1;
            end
            MAC2: begin
                offset_row = 0;
                offset_col = 4;
                kern_sel = 2;
            end
            MAC3: begin
                offset_row = 2;
                offset_col = 0;
                kern_sel = 3;
            end
            MAC4: begin
                offset_row = 2;
                offset_col = 2;
                kern_sel = 4;
            end
            MAC5: begin
                offset_row = 2;
                offset_col = 4;
                kern_sel = 5;
            end
            MAC6: begin
                offset_row = 4;
                offset_col = 0;
                kern_sel = 6;
            end
            MAC7: begin
                offset_row = 4;
                offset_col = 2;
                kern_sel = 7;
            end
            MAC8: begin
                offset_row = 4;
                offset_col = 4;
                kern_sel = 8;
            end
            default: begin
                offset_row = 'hx;
                offset_col = 'hx;
                kern_sel = 4'hf;
            end
        endcase

        in_row = {1'b0, base_row} + offset_row;
        in_col = {1'b0, base_col} + offset_col;

        case (io_state)
            // NOP: begin
            //     raddr = 'hx;
            //     waddr = 'hx;
            // end
            // TMP: begin
            //     raddr = 'hx;
            //     waddr = 'hx;
            // end
            WR0: begin
                raddr = 'hx;
                // waddr = (base_row << 6) + base_col;
                waddr = {base_row, base_col};
            end
            RD1: begin
                // raddr = ((base_row >> 1) << 5) + (base_col >> 1);
                raddr = {2'b0, base_row[5:1], base_col[5:1]};
                waddr = 'hx;
            end
            WR1: begin
                raddr = 'hx;
                // waddr = ((base_row >> 1) << 5) + (base_col >> 1);
                waddr = {2'b0, base_row[5:1], base_col[5:1]};
            end
            default: begin
                raddr = 'hx;
                waddr = 'hx;
            end
        endcase
    end

    always @(posedge clk) begin
        if (io_state == WR0)
            {base_row, base_col} <= {base_row, base_col} + 1;
    end

endmodule
