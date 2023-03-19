module MMS_8num(result, select, number0, number1, number2, number3, number4, number5, number6, number7);

    input        select;
    input  [7:0] number0;
    input  [7:0] number1;
    input  [7:0] number2;
    input  [7:0] number3;
    input  [7:0] number4;
    input  [7:0] number5;
    input  [7:0] number6;
    input  [7:0] number7;
    output [7:0] result;

    wire [7:0] res0, res1;
    MMS_4num mms4_1(res0, select, number0, number1, number2, number3);
    MMS_4num mms4_2(res1, select, number4, number5, number6, number7);
    assign result = (res0 < res1) ^ select ? res1 : res0;

endmodule
