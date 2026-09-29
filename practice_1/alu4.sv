module alu4 (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic [2:0] op,
    output logic [3:0] result,
    output logic       carry,
    output logic       zero
);
  assign zero = result == 4'b0;
  always_comb begin
    carry  = 1'b0;
    result = 4'b0;
    case (op)
      3'b000:  {carry, result} = {1'b0, a} + {1'b0, b};
      3'b001: begin
        {carry, result} = {1'b0, a} + {1'b0, ~b} + 1'b1;
        carry = ~carry;
      end
      3'b010:  result = a & b;
      3'b011:  result = a | b;
      3'b100:  result = a ^ b;
      3'b101:  result = ~a;
      3'b110:  result = a << 1;
      3'b111:  result = a >> 1;
      default: ;
    endcase
  end
endmodule
