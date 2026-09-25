# Basys 3 Timed Moore FSM (Day 11)

A **three-state, synchronous Moore FSM** that cycles Basys 3 LEDs through a traffic-light-style exercise: **RED for 3 seconds → GREEN for 4 seconds → YELLOW for 2 seconds → repeat**. Built during an FPGA training exercise using **SystemVerilog and Vivado**. This is an educational demonstrator, not a real traffic-safety controller.

![Module hierarchy](docs/architecture.svg)

## Design summary

The user-built architecture has **three separate SystemVerilog source files**. `timed_fsm_top` connects a parameterized `tick_generator` to `timed_fsm_controller` with an **internal `logic tick`** signal. The timer's tick is an **output port**; the FSM's tick is an **input port**. No additional clock or register is introduced by the top-level connection. Both modules run on the same 100 MHz clock and share a synchronous active-high reset.

| State | LED | Duration | Transition condition |
|---|---|---:|---|
| `RED` | LD0 | 3 ticks (3 s on board) | `tick && elapsed == 2` → `GREEN` |
| `GREEN` | LD1 | 4 ticks (4 s on board) | `tick && elapsed == 3` → `YELLOW` |
| `YELLOW` | LD2 | 2 ticks (2 s on board) | `tick && elapsed == 1` → `RED` |

The elapsed counter holds when `tick=0`, increments for a non-transition tick, and resets on a state transition. **State change has priority over increment.** The registered `tick` is one 100 MHz clock cycle wide (10 ns on the board). The LED decoder is purely combinational and depends only on the current state (Moore behavior).

## Repository layout

```text
rtl/
  tick_generator.sv         Parameterized registered-pulse timer
  timed_fsm_controller.sv   Timed Moore FSM, state/elapsed logic, LED decoder
  timed_fsm_top.sv          Top-level module and port wiring
sim/
  timed_fsm_top_tb.sv       Waveform-focused testbench (CLK_FREQ_HZ=4)
  timed_fsm_selfcheck_tb.sv Optional extension with automatic checks
constraints/
  timed_fsm_basys3.xdc      Basys 3 pins and 10 ns clock
docs/
  architecture.svg / .png  Connection diagram
  evidence/                 Actual Vivado screenshots from the training run
  FPGA_Day11_Study_Review_Guide.pdf
```

**Provenance:** The original Vivado project was developed interactively. The committed RTL and corrected waveform testbench here reproduce the reviewed design from shared code and Vivado screenshots; compare against your working Vivado files if you need a byte-for-byte archival copy. The optional self-checking testbench was added as a follow-up exercise and was **not** part of the documented original verification run. The evidence images are actual screenshots shared during the exercise.

## Build and run in Vivado

1. Create an **RTL project**, select **Basys 3** (Artix-7 `xc7a35tcpg236-1`), and add the three files under `rtl/` as design sources.
2. Set `timed_fsm_top` as the **design top**. Add `constraints/timed_fsm_basys3.xdc` as a constraints file.
3. For simulation, add `sim/timed_fsm_top_tb.sv` as simulation sources and set it as simulation top. Its instance overrides `CLK_FREQ_HZ=4` and produces a tick every **4 × 10 ns = 40 ns**. This short interval is for simulation only, not a literal second.
4. Run behavioral simulation; display `clk`, `rst`, `tick`, `FSM.state`, `FSM.elapsed` and the three LED outputs. The recorded sequence has transition times near **145 ns, 305 ns, and 385 ns** with reset deasserted at **20 ns**. The first RED interval includes the initial registered-tick latency.
5. Synthesize **`timed_fsm_top`** using the default **`CLK_FREQ_HZ=100_000_000`** (not the testbench override). Run implementation, check timing, generate bitstream, and program the Basys 3.
6. Observe **LD0 3 s → LD1 4 s → LD2 2 s → repeat**. The center button resets the controller synchronously to RED on the next clock edge. These are onboard LED *positions*, not actual red/green/yellow-colored emitters.

**Do not select the testbench as the synthesis top.** The accelerated value `4` is in the testbench instance only; the hardware top retains the default `100_000_000` unless deliberately overridden.

## Actual Vivado verification evidence

| Evidence | Recorded result |
|---|---|
| [Elaborated hierarchy](docs/evidence/elaborated_hierarchy.png) | Generator → internal `tick` → FSM, common clock/reset |
| [Behavioral waveform](docs/evidence/behavioral_simulation.png) | Full RED → GREEN → YELLOW → RED cycle |
| [Synthesis utilization](docs/evidence/synthesis_utilization.png) | **33 FF, 26 LUT, 5 bonded IOB, 1 BUFGCTRL** |
| [Synthesis schematic](docs/evidence/onehot_fsm_schematic.png) | `FSM_onehot_state_reg[0..2]` confirms one-hot recoding |
| [Implementation timing](docs/evidence/implemented_timing_summary.png) | Setup WNS **+6.204 ns**, TNS **0**; hold WHS **+0.144 ns**; pulse width **+4.500 ns**; **0 failing endpoints** |
| Physical board | Student reported correct repeating LED sequence on Basys 3 |

**FF accounting:** `tick_generator`: 27-bit counter + 1 tick FF = **28**. FSM: 3 one-hot state FF + 2 elapsed FF = **5**. Total **33** (observed). These counts describe this Vivado synthesis run; other versions/settings can choose different implementations.

## Learning notes / cautions

- `always_comb` reads signals that are already in the **same module**, including internal nets; only a *separate* FSM module needs `tick` in its input port list.
- A registered tick is asserted just after a terminal-count edge; the FSM samples it on the **following** edge, not at the same edge.
- With `CLK_FREQ_HZ=4`, the generator asserts pulses after every four active clock cycles. Starting from reset release as in the supplied waveform TB, the third tick is **asserted on active edge 12** and **consumed on active edge 13** (RED → GREEN). Once running, the next phases have 16- and 8-cycle durations.
- The original source uses `COUNT_WIDTH=$clog2(CLK_FREQ_HZ)` and assumes `CLK_FREQ_HZ>=2`. If extending to a parameter of 1, guard the width with `max(1, $clog2(...))`.
- Mechanical button reset is connected directly here for this lab. For robust external-input handling, apply synchronization and release-conditioning as appropriate; raw reset-button deassertion near a rising edge is not a production reset strategy.
- A passing timing summary establishes the reported **constrained** timing checks, not exhaustive proof of every system-level functional requirement. Do not use this demonstrator to drive safety-critical equipment.



No license was selected for this educational repository. Add one if you want to define permissions for reuse.
