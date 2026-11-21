# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb._gpi_triggers import RisingEdge, FallingEdge
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # check vga timings
    dut._log.info("Waiting hsync rise")
    await RisingEdge(dut.hsync) # hsync, give it time to not be in the middle of a signal high or low
    dut._log.info("Waiting hsync fall")
    await FallingEdge(dut.hsync)
    clock_count = 0
    while True:
        dut._log.info("Waiting clock rise")
        await RisingEdge(dut.clk)
        if dut.hsync.value == 1:
            dut._log.info("Breaking because hsync 1")
            break
        clock_count += 1
        dut._log.info(f"Clock count {clock_count}")

    assert clock_count == 96
    dut._log.info("Waiting vsync rise")
    await RisingEdge(dut.vsync)  # vsync
    dut._log.info("Waiting vsync fall")
    await FallingEdge(dut.vsync)
    clock_count = 0
    while True:
        dut._log.info("Waiting hsync fall")
        await FallingEdge(dut.hsync)
        if dut.vsync.value == 1:
            dut._log.info("breaking because vsync is 1")
            break
        clock_count += 1
        dut._log.info(f"clock count {clock_count}")

    assert clock_count == 2


