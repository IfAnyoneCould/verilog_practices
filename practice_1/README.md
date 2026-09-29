# Project 1: ALU + 7-Segment Decoder

## Files

| File | What it is | Your job |
|---|---|---|
| `alu_pkg.sv` | Op encoding shared by design and testbench | Nothing (read it) |
| `alu.sv` | The ALU design. ADD is done as a worked example | Implement the TODOs |
| `seg7.sv` | Hex to 7-segment decoder. Digit 0 is done | Fill in 1 through F |
| `tb_alu.sv` | Self-checking ALU testbench with a reference model | Add model cases per op |
| `tb_seg7.sv` | Decoder testbench that draws each digit in ASCII | Fill in `expected[]` |
| `Makefile` | Lint, simulate, view waves, synthesize | Run it |

Start by running `make sim-alu`. ADD is already implemented and modeled, so it
should print PASS. That confirms your toolchain works before you write any code.

The testbenches build with `-Wno-fatal` because simulation-only code triggers
style warnings (like the clock BLKSEQ warning). The design files are held to
full `-Wall` by `make lint`.

## Spec

`W` is the data width. All ops are combinational (no clock).

| Op | Code | `y` | `carry` | `overflow` |
|---|---|---|---|---|
| ADD | 0 | `a + b` (low W bits) | carry-out of the unsigned add | signed overflow |
| SUB | 1 | `a - b` (low W bits) | carry-out of `a + ~b + 1` (1 means `a >= b` unsigned, i.e. no borrow) | signed overflow |
| AND | 2 | `a & b` | 0 | 0 |
| OR  | 3 | `a \| b` | 0 | 0 |
| XOR | 4 | `a ^ b` | 0 | 0 |
| SLL | 5 | `a` shifted left by `b[$clog2(W)-1:0]`, zero fill | 0 | 0 |
| SRL | 6 | `a` shifted right by `b[$clog2(W)-1:0]`, zero fill | 0 | 0 |
| SLT | 7 | 1 if `a < b` as signed numbers, else 0 | 0 | 0 |

For every op: `zero = (y == 0)` and `negative = y[W-1]`.

Signed overflow means the true mathematical result (treating `a` and `b` as
two's complement numbers) doesn't fit in W bits. For W=8 the signed range is
-128 to 127, so 127 + 1 overflows and so does -128 - 1.

For shifts, only the low `$clog2(W)` bits of `b` count. Upper bits of `b` are
ignored. If W isn't a power of two, the shift amount can exceed W-1, and the
result is then 0.

## Milestones

Do these in order, and run the tests after each one.

1. **Toolchain check.** `make sim-alu` passes with ADD only. Open the waves
   with `make waves-alu` and find a case where `carry` goes high.
2. **Logic ops.** Implement AND, OR, XOR in `alu.sv` and in the model.
   Test with `make sim-alu OPS=29` (bits 0, 2, 3, 4 = ADD, AND, OR, XOR).
3. **Subtraction.** Implement SUB and its carry and overflow. This is the
   hardest milestone. Write down the overflow rule on paper first, and test
   it by hand against a few 4-bit examples. Test with `OPS=31`.
4. **Shifts.** Implement SLL and SRL. Test with `OPS=127`.
5. **SLT.** Implement it. Test everything with `OPS=255`.
6. **Widths.** Run `make sim-alu OPS=255 W=4`, then `W=16`, then `W=32`.
   W=4 and W=8 are exhaustive; 16 and 32 use edge cases plus random tests.
7. **Lint.** `make lint` must report no warnings.
8. **Decoder.** Fill in `seg7.sv` and `expected[]` in `tb_seg7.sv`.
   `make sim-seg7` draws each digit so you can check your patterns by eye.
9. **Synthesis.** Run `make synth` and `make synth-seg7`. Answer the questions
   below.

To use Icarus instead of Verilator for a quick run:

```
iverilog -g2012 -o sim alu_pkg.sv alu.sv tb_alu.sv && vvp sim
```

Icarus doesn't take `-G` from the Makefile, so edit the parameter defaults at
the top of `tb_alu.sv` to change W or OP_MASK.

## Synthesis questions

Write your answers in a `NOTES.md` file.

1. How many cells does the ALU use at W=8? At W=16 and W=32? Does it grow
   linearly with W? Which parts wouldn't grow linearly?
2. Comment out one op at a time and re-synthesize. Which op costs the most
   cells? Why?
3. Delete the default assignments at the top of `always_comb` and
   re-synthesize. What does Yosys report? Put the defaults back.
4. Run `yosys -p "read_verilog -sv seg7.sv; synth -top seg7; show"` and look
   at the decoder as a circuit. Roughly how many gates does it take?

## Rubric (100 points)

Baseline, required before scoring: `make lint` is clean, no latches in
synthesis, all testbenches self-check and print PASS.

| Criterion | Pts | Full marks looks like |
|---|---|---|
| Functional correctness | 30 | All 8 ops and 4 flags correct, including signed overflow edge cases (127+1, -128-1 at W=8) |
| Exhaustive testing | 25 | Model covers every op independently of the design; exhaustive at W<=8, edge + random at W=16, 32 |
| No latches / full case coverage | 15 | Defaults at the top, `default` in every case, Yosys shows no latch cells |
| Parameterization | 15 | Passes `OPS=255` at W=4, 8, 16, and 32 with no code changes |
| Synthesis review | 15 | `NOTES.md` answers all four synthesis questions with numbers |

## Hints (read only if stuck)

<details>
<summary>SUB carry</summary>

Do it exactly like ADD, but add `{1'b0, ~b}` and a carry-in of 1:
`{carry, y} = {1'b0, a} + {1'b0, ~b} + 1'b1`. Use `1'b1`, not a bare `1`: unsized literals are 32 bits wide, and lint will flag the width mismatch.
</details>

<details>
<summary>SUB overflow</summary>

Subtraction can only overflow when `a` and `b` have *different* signs.
Then check whether the result's sign matches `a`'s sign.
</details>

<details>
<summary>Model for SUB</summary>

For the signed part, `longint'($signed(ma)) - longint'($signed(mb))` gives the
true result; compare it to `smax` and `smin` like ADD does. For the carry,
compute `longint'(ma) + longint'(W'(~mb)) + 1` and take bit W.
</details>

<details>
<summary>SLT</summary>

`y = {{(W-1){1'b0}}, ($signed(a) < $signed(b))};` builds a W-bit result
from a 1-bit comparison. Without `$signed`, the comparison is unsigned.
</details>
