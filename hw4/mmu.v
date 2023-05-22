module MMU (
    input [$clog2(68)-1:0] virt_row,
    input [$clog2(68)-1:0] virt_col,
    output reg [11:0] phys_addr
);
    reg [$clog2(64)-1:0] phys_row;
    reg [$clog2(64)-1:0] phys_col;

    always @(*) begin
        if (virt_row < 3) phys_row = 0;
        else if (virt_row >= 65) phys_row = 63;
        else phys_row = virt_row - 2;

        if (virt_col < 3) phys_col = 0;
        else if (virt_col >= 65) phys_col = 63;
        else phys_col = virt_col - 2;

        phys_addr = (phys_row << 6) + phys_col;
    end

endmodule
