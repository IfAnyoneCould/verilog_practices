module test #(
    parameter int N = 10
) (
    input  logic clk,
    rst,
    output logic tick
);
  localparam int W = $clog2(N);
  logic [W-1:0] count;

  always_ff @(posedge clk) begin
    if (rst || count == W'(N - 1)) count <= '0;
    else count <= count + 1'b1;
  end

  assign tick = (count == W'(N - 1));
endmodule

