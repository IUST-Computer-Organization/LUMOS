# LUMOS RISC-V
> Light Utilization with Multicycle Operational Stages (LUMOS) RISC-V Processor Core

LUMOS is a multicycle RISC-V processor that implements a subset of RV32I instruction set, designed for educational use in computer organization classes at Iran University of Science and Technology. It allows for modular design projects, enabling students to gain hands-on experience with processor architecture.

LUMOS executes instructions in multiple stages, such as instruction fetch, fetch_wait, fetch_done, decode, execute, memory access, and etc. This approach allows for more complex operations and better utilization of processor resources compared to single-cycle designs. This processor does not support the entire RV32I instruction set, which is the base integer instruction set of RISC-V. Instead, it focuses on a subset of instructions that are essential for educational purposes and demonstrating the principles of computer architecture.

The processor is designed with modularity in mind, allowing students to work on various components of the processor. As part of their course projects, students will design different execution units, such as FPUs, control units, memory interfaces, and other modules that are integral to the processor's functionality.

This processor core is synthesizable in the 45nm technology node. LUMOS has gone through the RTL-to-GDS flow using Synopsys Design Compiler and Cadence Encounter. At this node, the core can achieve a frequency of 500Mhz while occupying 12000 um2 of area and consuming around 3mWatts of power.

<!-- ![Alt text](https://github.com/IUST-Computer-Organization/LUMOS/blob/main/LUMOS.png "The LUMOS microprocessor synthesized with Design Compiler and placed and routed by Cadence Encounter" =300x300)  -->

<picture>
    <img 
        alt="The LUMOS microprocessor synthesized with Design Compiler and placed and routed by Cadence Encounter" 
        src="https://github.com/IUST-Computer-Organization/LUMOS/blob/main/LUMOS.png" 
        width="550" 
        height="550" 
        style="vertical-align:middle"
    > 
</picture> 