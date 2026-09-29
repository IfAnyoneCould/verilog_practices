module alu4_tb;
  logic [3:0] a, b;
  logic [2:0] op;

  logic [3:0] result;
  logic carry, zero;

  alu4 dut (
      .a(a),
      .b(b),
      .op(op),
      .result(result),
      .carry(carry),
      .zero(zero)
  );

  logic [3:0] exp_result;
  logic exp_carry;
  int errors = 0, total = 0;

  initial begin
    $dumpfile("alu4_tb.vcd");
    for (int k = 0; k < 8; k++) begin
      for (int i = 0; i < 16; i++) begin
        for (int j = 0; j < 16; j++) begin
          a  = 4'(i);
          b  = 4'(j);
          op = 3'(k);
          #1;
          exp_carry  = 0;
          exp_result = 0;
          case (k)
            0: {exp_carry, exp_result} = 5'(i + j);
            1: {exp_carry, exp_result} = 5'(i - j);
            2: exp_result = 4'(i & j);
            3: exp_result = 4'(i | j);
            4: exp_result = 4'(i ^ j);
            5: exp_result = 4'(~i);
            6: exp_result = 4'(i << 1);
            7: exp_result = 4'(i >> 1);
            default: ;
          endcase

          total++;

          if (result !== exp_result || carry !== exp_carry || zero !== (exp_result == 0)) begin
            errors++;
            $display("FAIL op=%0d a=%0d b=%0d: got r=%0d c=%b z=%b, expected r=%0d c=%b", k, i, j,
                     result, carry, zero, exp_result, exp_carry);
          end
        end
      end
    end
    if (errors == 0) $display("PASS: %0d/%0d", total, total);
    else $display("FAILED: %0d errors out of %0d", errors, total);
    $finish;
  end

endmodule
