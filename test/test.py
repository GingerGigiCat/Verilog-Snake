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

    await RisingEdge(dut.user_project.hsync) # hsync, give it time to not be in the middle of a signal high or low
    await FallingEdge(dut.user_project.hsync)
    clock_count = 0
    while True:
        await RisingEdge(dut.clk)
        if dut.user_project.hsync.value == 1:
            break
        clock_count += 1

    assert clock_count == 96

    await RisingEdge(dut.user_project.vsync)  # vsync
    await FallingEdge(dut.user_project.vsync)
    clock_count = 0
    while True:
        await FallingEdge(dut.user_project.hsync)
        if dut.user_project.vsync.value == 1:
            break
        clock_count += 1

    assert clock_count == 2


