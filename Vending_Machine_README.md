# Vending Machine

Design Specification
1.	The machine has 20 different snacks and each snack has a two digit code (00 ~ 19).
2.	There are maximum 10 units of item per slot.
3.	A counter for every slot keeps track of the number of units remaining in that slot.
4.	Purchase only 1 item at a time and accepts card only

Different States of the Vending Machine
1.	Reset : When reset = 1, all item counters and outputs are set to 0. The machine goes to the idle state when reset becomes 0.
2.	Idle : This is a state where the machine waits for a new transaction to begin. All outputs are set to 0, and the machine waits in this state until CARD_IN goes high.
  	       The idle state is the initial state of this FSM.
3.	Re-load: All snack counters are set to 10. A re-load can only be done when the machine is idle.
             A new transaction cannot begin when the machine is re-loading.
4.	Transact:  When card is inserted (CARD_IN = 1)  - wait for item selection
    a.	 If selection is valid (i.e. the code is a number between 00 and 19 and there are a non-zero number of items corresponding to that code left in the machine) ,
         display the $ amount of the selection and wait for the VALID_TRAN signal
          i.	If VALID_TRAN = 1 :  VEND selected item
          ii.	If the VALID_TRAN signal does not go high within 5 clock cycles, the transaction failed. Set the ‘FAILED_TRAN’ bit to high, and go to the idle state. 
    b.	If the selection is invalid, set the ‘INVALID_SEL’ bit to high and go to the idle state.
5.	Vend: decrement counter of corresponding item by one (since item is vented),
          set VEND to 1, and Wait for door-open signal to go HIGH and then LOW to begin a new transaction (go to idle state).
          If the door does not open for 5 clock cycles, go to the idle state.
6. Selecting Item: The same register (ITEM_CODE<3:0>)  is used to enter the 2 digit item code sequentially.
                   The item_code is read only when key_press = 1. Wait upto 5 clock cycles for each digit.
                   If no digit is entered, or if a digit is entered and there is no second digit for 5 clock cycles, go to the idle state.

Item Value: 00 ~ 03  == $1, 04~07 == $2, 08~11 == $7, 12~15 == $4, 16,17 == $5, 18,19 == $6
