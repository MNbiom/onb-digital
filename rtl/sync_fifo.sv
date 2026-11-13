`timescale 1ns / 1ps

module sync_fifo #(
    parameter int unsigned DATA_WIDTH          = 8,
    parameter int unsigned DEPTH               = 16,
    parameter int unsigned ALMOST_FULL_THRESH  = 14,
    parameter int unsigned ALMOST_EMPTY_THRESH = 2
) (
    input  logic                    clk,
    input  logic                    rst_n,

    // Write interface
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    output logic                    full,
    output logic                    almost_full,

    // Read interface
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    empty,
    output logic                    almost_empty,

    // Diagnostics / occupancy
    output logic [$clog2(DEPTH):0]  occupancy
);

    // TODO:
    // 1. Declare the RAM memory array: logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    // 2. Implement write (wr_ptr) and read (rd_ptr) pointers.
    // 3. Implement synchronous registered read on rd_data when rd_en is asserted.
    // 4. Implement an occupancy counter.
    // 5. Calculate flags: empty, full, almost_empty, almost_full.
    // 6. Handle simultaneous read and write.

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    logic [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;

    assign empty = (occupancy == 0) ? 1 : 0;
    assign full = (occupancy == DEPTH) ? 1 : 0;

    assign almost_empty = (occupancy <= ALMOST_EMPTY_THRESH) ? 1 : 0;
    assign almost_full  = (occupancy >= ALMOST_FULL_THRESH) ? 1 : 0;

    assign do_read  = rd_en && !empty;
    assign do_write = wr_en && (!full || do_read);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            occupancy <= 0;
        end else begin
            if (do_write) begin
                mem[wr_ptr] <= wr_data;
                if (wr_ptr == DEPTH-1) wr_ptr <= 0;
                else wr_ptr <= wr_ptr + 1;
            end
            if (do_read) begin
                rd_data <= mem[rd_ptr];
                if (rd_ptr == DEPTH-1) rd_ptr <= 0; 
                else rd_ptr <= rd_ptr + 1;
            end
            case ({do_write, do_read})
                2'b10: occupancy <= occupancy + 1;
                2'b01: occupancy <= occupancy - 1;
            endcase
        end
    end

endmodule

