module seven_seg(
    input clk,
    input [15:0] addr, // Changed to 16-bit
    input [15:0] data, // Changed to 16-bit
    output reg [3:0] D0_AN, output reg [7:0] D0_SEG,
    output reg [3:0] D1_AN, output reg [7:0] D1_SEG
);
    reg [18:0] counter = 0;
    always @(posedge clk) counter <= counter + 1;
    wire [1:0] sel = counter[18:17]; 
    
    reg [3:0] hex0, hex1;

    always @(*) begin
        D0_AN = 4'b1111; D1_AN = 4'b1111;
        D0_AN[sel] = 0;  D1_AN[sel] = 0;
        
        case(sel)
            0: begin hex0 = addr[3:0];   hex1 = data[3:0];   end
            1: begin hex0 = addr[7:4];   hex1 = data[7:4];   end
            2: begin hex0 = addr[11:8];  hex1 = data[11:8];  end
            3: begin hex0 = addr[15:12]; hex1 = data[15:12]; end
        endcase
    end

    function [7:0] decode(input [3:0] h);
        case(h)
            4'h0: decode = 8'hC0; 4'h1: decode = 8'hF9; 4'h2: decode = 8'hA4; 4'h3: decode = 8'hB0;
            4'h4: decode = 8'h99; 4'h5: decode = 8'h92; 4'h6: decode = 8'h82; 4'h7: decode = 8'hF8;
            4'h8: decode = 8'h80; 4'h9: decode = 8'h90; 4'hA: decode = 8'h88; 4'hB: decode = 8'h83;
            4'hC: decode = 8'hC6; 4'hD: decode = 8'hA1; 4'hE: decode = 8'h86; 4'hF: decode = 8'h8E;
            default: decode = 8'hFF;
        endcase
    endfunction

    always @(*) begin
        D0_SEG = decode(hex0);
        D1_SEG = decode(hex1);
    end
endmodule