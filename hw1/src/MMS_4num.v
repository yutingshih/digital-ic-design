module MMS_4num(result, select, number0, number1, number2, number3);

    input        select;
    input  [7:0] number0;
    input  [7:0] number1;
    input  [7:0] number2;
    input  [7:0] number3;
    output [7:0] result;

    wire [7:0] res0, res1;
    assign res0 = (number0 < number1) ^ select ? number1 : number0;
    assign res1 = (number2 < number3) ^ select ? number3 : number2;
    assign result = (res0 < res1) ^ select ? res1 : res0;

endmodule
