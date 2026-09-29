module tb_test;
  localparam int N = 10;
  logic clk = 0, rst, tick;
  int cycles = 0, last_tick = -1, errors = 0;

  test #(.N(N)) dut (.*);
  always #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_test);
    rst = 1;
    repeat (3) @(posedge clk);
    rst = 0;
    repeat (100) begin
      @(posedge clk);
      #1 cycles++;
      if (tick) begin
        if (last_tick >= 0 && cycles - last_tick != N) begin
          errors++;
          $display("FAIL: gap %0d at cycle %0d", cycles - last_tick, cycles);
        end
        last_tick = cycles;
      end
    end
    $display(errors == 0 && last_tick >= 0 ? "PASS" : "FAIL");
    $finish;
  end
endmodule
