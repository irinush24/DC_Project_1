# Verilog ALU Implementation

A Verilog based project in which we implement the following functions:

## Arithmetic Operations
* Addition
* Subtraction
* Multiplication
* Division

## Bitwise Logical Operations
* AND
* OR
* XOR
* LEFT SHIFT
* RIGHT SHIFT

## Input and Output Signals
* Two 8-bit input operands (A and B) that provide the values to be processed.
* Control signals to select the operation the ALU should perform.
* 8-bit output result representing the outcome of the selected operation.

## Status Flags
Status flags to indicate the state of the result:
* **Zero (Z):** Set if the result is zero.
* **Negative (N):** Set if the result is negative (most significant bit = 1).
* **Overflow (V):** Set if a signed arithmetic overflow occurs.
