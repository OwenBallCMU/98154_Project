# I2C Peripheral Device

Owen Ball
18-224/624 Spring 2023 Final Tapeout Project

## Overview

An I2C peripheral device with 20 8-bit registers. The device has one read only register
set to the value of 8 parallel inputs. The value of one register is outputted as a
parallel output. The device also features two PWM outputs controlled using the registers.

## How it Works

(deeper description of your project's internal operations, along with any diagrams. large parts of this can likely be copied from your project design plan and/or RTL checkpoint submission)

To add images, upload them into the repo and use the following format to embed them in markdown:


## Inputs/Outputs

This design takes in a clock, active high reset, and has the following IO:
![](media/IO.png)

The inputs consist of the SCL line, the SDA line, and 8 input pins. These pins
directly map to the read-only register 0x00 as shown in the register map below.

The first output is SDA_N, which is the inverted SDA output of the chip, which
should then be connected to the gate of an NMOS to pull the SDA line to ground.
The chip also has two PWM outputs. The functionality of these pins will be discussed in
the PWM section. The last set of outputs is the 8-bit value stored in register 0x01 on the device.

In order for proper function of the I2C line, the input clock should be approximately 10 to 15 times
the frequency of the bus. To operate at the standard I2C clock speed of 100kHz, a clock of at least
1MHz should be used.

![](media/registers.png)

## Hardware Peripherals

Both the Ice40 FPGA and the ASIC do not support leaving outputs high impedance. As a result, 
in order to drive the SDA line, the SDA_N output of the chip must be fed into an NMOS with a pull-up resistor. The drain of the NMOS 
should then be connected to SDA. Thus when SDA_N is high, SDA is pulled to ground and otherwise, is pulled to 3.3V. The resistor value should be
somewhere in the range of 2kOhm to 10kOhm, with the NMOS being capable of switching fast enough for the desired I2C speed
and being able to overpower the SDA pull up resistors. Note that this chip does not perform clock stretching and as such, has
no need to drive the SCL line.
(if you have any external hardware peripherals such as buttons, LEDs, sensors, etc, please explain them here. otherwise, remove this section)

## Design Testing / Bringup

(explain how to test your design; if relevant, give examples of inputs and expected outputs)

(if you would like your design to be tested after integration but before tapeout, provide a Python script that uses the Debug Interface posted on canvas and explain here how to run the testing script)

## Media

(optionally include any photos or videos of your design in action)

## (anything else)

If there is anything else you would like to document about your project such as background information, design space exploration, future ideas, verification details, references, etc etc. please add it here. This template is meant to be a guideline, not an exact format that you're required to follow.
