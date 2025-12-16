# iADC (Dual-Slope / Integrating ADC)

This repository collects my iADC project work (analog modeling, digital RTL, and lab validation) in one place.

## Repository layout
- `docs/`    : project reports and documentation (PDFs)
- `analog/`  : analog-related figures (PNG) and supporting material
- `digital/` : VHDL RTL + testbench + simulation scripts
- `lab/`     : lab automation / analysis scripts and supporting files

## How to use this repo
1. Start with `docs/` to understand the ADC concept, blocks, and results.
2. Use `digital/` to run/inspect the VHDL control logic and testbench.
3. Use `lab/` to see the measurement automation and post-processing flow.
4. Use `analog/` for supporting figures referenced by the docs.

## Digital folder contents
The `digital/` folder focuses on the source code and simulation setup (RTL + TB).
Generated implementation outputs (e.g., layout/synthesis artifacts) are not tracked here.
