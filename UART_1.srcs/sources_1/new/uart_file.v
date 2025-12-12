



module uart_rx #(
    parameter CLK_FREQ = 100000000, // Arty A7 Clock 100MHz
    parameter BAUD_RATE = 9600      // Standard Baud Rate
)(
    input  wire       clk,
    input  wire       rst_n,        // Active low reset
    input  wire       rx_serial,    // Serial input (from USB-UART)
    output reg  [7:0] rx_byte,      // The received 8-bit data
    output reg        rx_dv         // Data Valid pulse
);

    // Calculate clocks per bit
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // States
    localparam STATE_IDLE  = 3'b000;
    localparam STATE_START = 3'b001;
    localparam STATE_DATA  = 3'b010;
    localparam STATE_STOP  = 3'b011;
    localparam STATE_CLEANUP = 3'b100;

    reg [2:0]  state = STATE_IDLE;
    reg [13:0] clk_count = 0;
    reg [2:0]  bit_index = 0; // To count 0-7 data bits

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
            rx_dv <= 0;
            rx_byte <= 0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                // Wait for the start bit (falling edge)
                STATE_IDLE: begin
                    rx_dv <= 0;
                    clk_count <= 0;
                    bit_index <= 0;
                    if (rx_serial == 1'b0) begin // Start bit detected
                        state <= STATE_START;
                    end
                end

                // Check middle of start bit to ensure it's not a glitch
                STATE_START: begin
                    if (clk_count == (CLKS_PER_BIT-1)/2) begin
                        if (rx_serial == 1'b0) begin
                            clk_count <= 0;
                            state <= STATE_DATA;
                        end else begin
                            state <= STATE_IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                // Sample bits 0 through 7
                STATE_DATA: begin
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_byte[bit_index] <= rx_serial; // Sample data
                       
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state <= STATE_STOP;
                        end
                    end
                end

                // Wait for Stop bit
                STATE_STOP: begin
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        rx_dv <= 1; // Assert Data Valid
                        clk_count <= 0;
                        state <= STATE_CLEANUP;
                    end
                end

                // Return to Idle
                STATE_CLEANUP: begin
                    state <= STATE_IDLE;
                    rx_dv <= 0;
                end
               
                default: state <= STATE_IDLE;
            endcase
        end
    end
endmodule




module top(
    input        clk,           // 100MHz System Clock
    input        rst_n,         // Reset Button (Active Low)
    input        uart_txd_in,   // FPGA RX pin (connected to USB TX)
   
    // Outputs
    output [3:0] led,           // Standard Green LEDs
    output       led0_b,        // RGB 0 Blue component
    output       led1_b,        // RGB 1 Blue component
    output       led2_b,        // RGB 2 Blue component
    output       led3_b         // RGB 3 Blue component
);

    wire [7:0] rx_data;
    wire       rx_dv;
   
    // Register to hold the last received character for display
    reg [7:0] display_data;

    // Instantiate the UART Receiver
    uart_rx #(
        .CLK_FREQ(100000000),
        .BAUD_RATE(9600)
    ) receiver_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(uart_txd_in),
        .rx_byte(rx_data),
        .rx_dv(rx_dv)
    );

    // Update LEDs only when new data is fully received
    always @(posedge clk) begin
        if (!rst_n) begin
            display_data <= 8'b0;
        end else if (rx_dv) begin
            display_data <= rx_data;
        end
    end

    // Assign Lower 4 bits to Green LEDs
    assign led = display_data[3:0];

    // Assign Upper 4 bits to Blue RGB components
    // Note: RGB LEDs on Arty are active high (PWM capable but Digital 1 works)
    assign led0_b = display_data[4];
    assign led1_b = display_data[5];
    assign led2_b = display_data[6];
    assign led3_b = display_data[7];

endmodule