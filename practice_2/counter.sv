module counter #(
    parameter int W = 8
) (
    input logic clk,
    input logic rst,
    input logic en,
    input logic up,
    input logic load,
    input logic [W-1:0] d,
    output logic [W-1:0] q,
    output logic wrap
);

  assign wrap = en && !load && !rst && (up ? (q == '1) : (q == '0));

  always_ff @(posedge clk) begin

    if (rst) q <= '0;
    else if (load) q <= d;
    else if (en) begin
      if (up) q <= q + W'(1);
      else q <= q - W'(1);
    end
  end
endmodule
