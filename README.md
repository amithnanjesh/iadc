# iADC (Dual-Slope / Integrating ADC)

This repository collects my iADC project work (analog modeling, digital RTL, and lab validation) in one place.

## Repository layout
- `docs/`    : project reports and documentation (PDFs)
- `analog/`  : analog figures (plots/diagrams) and supporting material
- `digital/` : VHDL RTL + testbench + simulation scripts
- `lab/`     : lab automation / analysis scripts and supporting files

## How to use this repo
1. Start with `docs/` to understand the ADC concept, blocks, and results.
2. Use `digital/` to run/inspect the VHDL control logic and testbench.
3. Use `lab/` to see the measurement automation and post-processing flow.
4. Use `analog/` for figures (plots/diagrams) referenced by the docs.

## Documents (start here)
- `docs/ADC_Sem1_SPICE_MacroModel_Report.pdf`  
  Sem 1: ADC macro-modeling (switch, integrator, comparator), simulations, and key results.

- `docs/sem2_analog_design_summary.pdf`  
  Sem 2: Analog design summary and results.

- `docs/sem2_analog_integrator_afe.pdf`  
  Sem 2: Integrator / AFE deliverable (design details and verification results).

- `docs/sem2_tapeout_checklist_public.pdf`  
  Sem 2: Tapeout checklist / sign-off summary (high-level).

- `docs/Sem2_Digital_Verification_Report.pdf`  
  Digital: VHDL block description, timing diagrams, and verification results.

- `docs/Sem3_Lab_Verification_Report.pdf`  
  Sem 3: Lab verification (static and dynamic performance validation and debugging).

## Lab folder contents
The `lab/` folder contains Python scripts for measurement automation and post-processing.
It also includes example inputs/config files to help run the scripts on a similar setup.

## Digital folder contents
The `digital/` folder focuses on the source code and simulation setup (RTL + TB).
Generated implementation outputs (e.g., layout/synthesis artifacts) are not tracked here.
