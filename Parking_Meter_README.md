# Parking Meter

Design Specification
1.	In the initial state, the seven-segment displays should be flashing 0000 with period 1 sec and duty cycle 50% (on for 0.5 sec and off for 0.5 sec).
2.	When any add button (add0, add1, add2 or add3) is pressed, the display adds to the corresponding time and starts counting down.
3.	When less than 180 seconds remain, the display should flash with a period of 2 seconds and 50% duty cycle. You should have alternate counts on the display like 180, blank,178, blank,176,…).
    Make sure you blink such that even values show up and odd values are blanked out.
4.	When the time has expired, the display should flash 0000 with period 1 sec and duty cycle 50% (on for 0.5 sec and off for 0.5 sec).
5.	If add4 is then pushed, the display should read 300 seconds and begin counting down (at 1 Hz).
    When the timer counts down to 180 seconds and add2 is pushed, the display should then read 300 seconds (120 + 180) and continue counting down.
    If rst1 goes high, then the display gets reset to 15 seconds and starts flashing accordingly while counting down.
6.	The max value of time will be 9999 and any attempt to increment beyond 9999, should result in the counter latching to 9999 and counting down from there.
7.	Use input clock(clk) frequency as 100 Hz
8.	Include a global input reset (rst) which takes the FSM to the initial state.
9.	Do not account for multiple inputs being pressed at the same time.
