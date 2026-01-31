module top(
    input clk,
    input UART_rxd,
    output UART_txd,
    output [3:0] D0_AN,   
    output [7:0] D0_SEG,  
    output [3:0] D1_AN,   
    output [7:0] D1_SEG,
    output led
);
    wire [7:0] rx_data;
    wire rx_done;
    reg [7:0] tx_data_reg;
    reg tx_start_reg;
    wire tx_busy;

    // Memory is now 10 bits wide: 
    // [7:0] = Data Value, [8] = High Nibble Case, [9] = Low Nibble Case
    reg [9:0] registers [0:255];
    
    reg [3:0] state = 0;
    reg [3:0] return_state = 0;
    localparam IDLE=0, GET_ADDR1=1, GET_ADDR2=2, GET_DATA1=3, GET_DATA2=4, 
               EXECUTE=5, TX_D=6, TX_SPACE=7, TX_HEX1=8, TX_HEX2=9, TX_NL=10, WAIT_UART=11;

    reg [7:0] addr_reg = 8'h00; 
    reg [7:0] val_display = 8'h00; 
    reg [7:0] data_reg = 8'h00;
    reg [1:0] case_flags = 2'b00; // Stores the case of the typed letters
    reg [1:0] stored_cases = 2'b00; // Cases retrieved from memory
    reg mode_write;

    // Blink Logic
    reg [25:0] blink_timer = 0;
    always @(posedge clk) begin
        if (state == EXECUTE && mode_write) blink_timer <= 60_000_000;
        else if (blink_timer > 0) blink_timer <= blink_timer - 1;
    end
    assign led = (blink_timer > 45_000_000) || (blink_timer > 15_000_000 && blink_timer <= 30_000_000);

    // ASCII to HEX with Case Tracking
    function [3:0] to_hex(input [7:0] ascii);
        if (ascii >= "0" && ascii <= "9") to_hex = ascii[3:0];
        else if (ascii >= "A" && ascii <= "F") to_hex = ascii - 8'h37;
        else if (ascii >= "a" && ascii <= "f") to_hex = ascii - 8'h57;
        else to_hex = 0;
    endfunction

    // HEX to ASCII with Case Awareness
    function [7:0] to_ascii(input [3:0] hex, input is_upper);
        if (hex < 10) to_ascii = {4'h3, hex};
        else to_ascii = is_upper ? (hex + 8'h37) : (hex + 8'h57);
    endfunction

    always @(posedge clk) begin
        tx_start_reg <= 0;
        
        if (rx_done && (rx_data == "W" || rx_data == "w" || rx_data == "R" || rx_data == "r")) begin
            mode_write <= (rx_data == "W" || rx_data == "w");
            addr_reg <= 8'h00; val_display <= 8'h00; 
            state <= GET_ADDR1;
        end 
        else begin
            case (state)
                IDLE: ;
                GET_ADDR1: if (rx_done && rx_data != 8'h20) begin addr_reg[7:4] <= to_hex(rx_data); state <= GET_ADDR2; end
                GET_ADDR2: if (rx_done && rx_data != 8'h20) begin addr_reg[3:0] <= to_hex(rx_data); state <= mode_write ? GET_DATA1 : EXECUTE; end
                
                GET_DATA1: if (rx_done && rx_data != 8'h20) begin 
                    data_reg[7:4] <= to_hex(rx_data); 
                    val_display[7:4] <= to_hex(rx_data);
                    case_flags[1] <= (rx_data >= "A" && rx_data <= "F"); // Store if it was Upper
                    state <= GET_DATA2; 
                end
                GET_DATA2: if (rx_done && rx_data != 8'h20) begin 
                    data_reg[3:0] <= to_hex(rx_data); 
                    val_display[3:0] <= to_hex(rx_data);
                    case_flags[0] <= (rx_data >= "A" && rx_data <= "F"); // Store if it was Upper
                    state <= EXECUTE; 
                end

                EXECUTE: begin
                    if (mode_write) begin
                        registers[addr_reg] <= {case_flags, data_reg}; // Save value + case
                        state <= IDLE;
                    end else begin
                        {stored_cases, val_display} <= registers[addr_reg]; // Load value + case
                        state <= TX_D;
                    end
                end

                TX_D:     begin tx_data_reg <= "D"; tx_start_reg <= 1; state <= WAIT_UART; return_state <= TX_SPACE; end
                TX_SPACE: begin tx_data_reg <= " "; tx_start_reg <= 1; state <= WAIT_UART; return_state <= TX_HEX1;  end
                TX_HEX1:  begin tx_data_reg <= to_ascii(val_display[7:4], stored_cases[1]); tx_start_reg <= 1; state <= WAIT_UART; return_state <= TX_HEX2; end
                TX_HEX2:  begin tx_data_reg <= to_ascii(val_display[3:0], stored_cases[0]); tx_start_reg <= 1; state <= WAIT_UART; return_state <= TX_NL;   end
                TX_NL:    begin tx_data_reg <= 8'h0A; tx_start_reg <= 1; state <= WAIT_UART; return_state <= IDLE; end
                WAIT_UART: if (!tx_busy && !tx_start_reg) state <= return_state;
            endcase
        end
    end

    uart_rx receiver (.clk(clk), .rx(UART_rxd), .data_out(rx_data), .rx_done(rx_done));
    uart_tx transmitter (.clk(clk), .tx_data(tx_data_reg), .tx_start(tx_start_reg), .tx(UART_txd), .tx_busy(tx_busy));
    seven_seg display_mod (.clk(clk), .addr(addr_reg), .data(val_display), .D0_AN(D0_AN), .D0_SEG(D0_SEG), .D1_AN(D1_AN), .D1_SEG(D1_SEG));
endmodule