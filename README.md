# Multi-Cycle RISC-V Processor (Verilog)

This repository contains the implementation of a multi-cycle RISC-V processor designed using Verilog HDL. The processor supports a subset of the RISC-V RV32I instruction set architecture, including three custom instructions. The design is modular, efficient, and suitable for educational and experimental purposes.

### 🚀 Project Overview
- **Processor Type:** Multi-Cycle (Three main stages: Fetch, Decode, Execute/Writeback)
- **Supported Instructions:** A subset of RISC-V RV32I and three custom instructions:
  - **LIS (Load Increment Store):** Reads a value from memory, increments it by a specified value, and stores it back.
  - **LLM (Load Load Multiply):** Reads two values from memory, multiplies them, and stores the result in a register.
  - **KS (Kirby Sort):** Sorts a specified range of register values and stores the sorted values in another range.
- **Memory Addressing:** Byte-addressable with a 32-bit address space.
- **Register File:** 32 registers, each 32 bits wide.

### 📌 How It Works
The multi-cycle processor operates in three main stages:
1. **Fetch:** The instruction is fetched from memory using the program counter (PC).
2. **Decode:** The instruction is decoded, and operands are read from the register file.
3. **Execute/Writeback:** The instruction is executed, and the result is written back to the destination register or memory.

Each instruction type has a specific execution pattern:
- Standard instructions complete in one cycle.
- Custom instructions (LIS, LLM, KS) may require multiple cycles for execution.

### 📌 Supported Instructions and Custom Operations
- **Standard Instructions:** ADD, SUB, AND, OR, XOR, SLT, SLL, SRL, etc.
- **Custom Instructions:**
  - **LIS (Load Increment Store):** Reads a value from a calculated memory address, increments it, and stores it back.
  - **LLM (Load Load Multiply):** Reads two values from memory, multiplies them, and stores the result in a register.
  - **KS (Kirby Sort):** Sorts the values in a specified range of registers and stores them in another range.

### 📌 Custom Instruction Details
1. **LIS (Load Increment Store):**
   - Reads a value from the address (rs1 + imm), adds the increment value, and stores the result back at the same address.

2. **LLM (Load Load Multiply):**
   - Reads two values from memory (rs1 + imm) and (rs1 + imm + 4).
   - Multiplies these two values and stores the result in the destination register (rd).

3. **KS (Kirby Sort):**
   - Reads a specified range of registers, sorts them, and writes the sorted values starting from the destination register (rd).

### ⚙️ Verilog Modules
- **`islemci.v`** - Main multi-cycle processor module (standard instructions).
- **`islemci_yusf.v`** - Extended processor module with three custom instructions (LIS, LLM, KS).
- **`anabellek.v`** - Memory module used for instruction and data storage.

### ✅ How to Use
1. Load the Verilog modules (`islemci.v`, `islemci_yusf.v`, `anabellek.v`) into your Verilog simulation environment (e.g., Xilinx Vivado).
2. Set the desired module (`islemci.v` or `islemci_yusf.v`) as the top module.
3. Compile and run the simulation.
4. Observe the instruction execution and results through the console output or waveform view.

### ✅ Simulation and Testing
- The processor is tested using a dedicated testbench.
- Custom instructions are verified through specific test scenarios.
- Memory and register values can be observed during simulation to validate the correct operation of each instruction.

### ✅ Performance Optimization
- The multi-cycle design can be optimized by reducing the number of cycles for certain instructions.
- The KS (Kirby Sort) instruction can be further optimized using a more efficient sorting algorithm.

### ✅ Known Challenges and Solutions
- **Multi-Cycle Execution Management:** Ensured that each instruction is properly controlled using a state machine.
- **Custom Instruction Handling:** Special states were added to the state machine for LIS, LLM, and KS instructions.
- **Timing Control:** Careful management of read/write operations to avoid conflicts.
