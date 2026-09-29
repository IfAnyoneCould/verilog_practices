module counter_tb #(
    parameter int W = 8
);

  localparam logic [W-1:0] MAX = '1;

  logic clk = 0, rst, en, up, load;
  logic [W-1:0] q, d;
  logic wrap;

  counter #(.W(W)) dut (.*);

  always #5 clk = ~clk;

  logic [W-1:0] exp_q;
  logic exp_wrap;
  int errors = 0, total = 0;

  initial begin
    rst = 1;
    en = 0;
    up = 0;
    load = 0;
    d = '0;
    exp_q = '0;

    repeat (2) @(posedge clk);
    @(negedge clk) rst = 0;

    repeat (1000) begin
      @(negedge clk) en = ($urandom_range(0, 3) != 0);
      up = 1'($urandom_range(0, 1));
      d = W'($urandom);
      load = ($urandom_range(0, 9) == 0);
      rst = ($urandom_range(0, 49) == 0);

      #1;
      exp_wrap = en && !load && !rst && (up ? (exp_q == MAX) : (exp_q == '0));
      total++;

      if (exp_q !== q || exp_wrap !== wrap) begin
        errors++;
        $display("FAIL rst=%b load=%b en=%b up=%b: got q=%0d w=%b, expected q=%0d w=%b", rst, load,
                 en, up, q, wrap, exp_q, exp_wrap);
      end

      @(posedge clk);
      if (rst) exp_q = '0;
      else if (load) exp_q = d;
      else if (en) begin
        if (up) exp_q = exp_q + W'(1);
        else exp_q = exp_q - W'(1);
      end

    end
    if (errors == 0) $display("PASS: 1000/1000");
    else $display("FAILED: %0d errors out of 1000", errors);
    $finish;
  end
endmodule
