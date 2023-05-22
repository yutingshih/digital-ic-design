`timescale 1ns/10ps
module  ATCONV(
    input clk,
    input reset,
    output reg busy,
    input ready,
            
    output reg [11:0] iaddr,
    input signed [12:0] idata,
    
    output reg cwr,
    output reg [11:0] caddr_wr,
    output reg [12:0] cdata_wr,
    
    output reg crd,
    output reg [11:0] caddr_rd,
    input [12:0] cdata_rd,
    
    output reg csel
);

    Controller ctrl(.clk(clk), .rst(reset), .ready(ready));

    // Replicate Padding
    MMU mmu(.virt_row(ctrl.in_row), .virt_col(ctrl.in_col));
    
    // Convolution
    Constants const();
    reg [12:0] kern;
    always @(*) begin
        case (ctrl.kern_sel)
            0: kern = const.KERN0;
            1: kern = const.KERN1;
            2: kern = const.KERN2;
            3: kern = const.KERN3;
            4: kern = const.KERN4;
            5: kern = const.KERN5;
            6: kern = const.KERN6;
            7: kern = const.KERN7;
            8: kern = const.KERN8;
            default: kern = 'hx;
        endcase
    end
    
    MAC #(.WIDTH(13)) mac(
        .clk(clk),
        .rst(ctrl.mac_rst),
        .en(ctrl.mac_en),
        .src1(idata),
        .src2(kern),
        .init_val(const.BIAS)
    );

    // ReLU
    wire [12:0] wdata0 = mac.psum[12] ? 0 : mac.psum[12:0];

    reg [12:0] maxpool;
    wire [12:0] rdata1 = cdata_rd;
    wire [12:0] wdata1 = maxpool;

    always @(*) begin
        busy = ctrl.busy;
        crd = ctrl.read;
        cwr = ctrl.write;
        caddr_rd = ctrl.raddr;
        caddr_wr = ctrl.waddr;
        csel = ctrl.csel;
        iaddr = mmu.phys_addr;
    end

    always @(posedge clk) begin
        if (ctrl.read && ctrl.csel && rdata1 > maxpool)
            maxpool = rdata1;
        cdata_wr = ctrl.csel ? wdata1 : wdata0;
    end

endmodule
