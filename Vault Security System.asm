#COA Mini Project
#Group/Section : BAXZ S1G2
#Group Members:
#1. Muhammad Hazieq Na'imullah bin Nor Affandy (B152510235)
#2. Muhammad Saifullah bin Hasnan (B152510295)
#3. Mohammad Nadzmi Aiman bin Mahazir (B152510211)
#4. Muhammad Farish Iskandar bin Zulkifli (B152510304)



.data
vault_codes: .word 0:10
buffer:      .space 16      

prompt_input:  .asciiz "\nEnter Vault Access Code "
colon:          .asciiz " (1-9999): "
err_msg:        .asciiz "Error: The code must be a number between 1 and 9999.\n"
dup_msg:        .asciiz "Error: This code already exists in the system. Try again.\n"

menu_head:     .asciiz "\n--- VAULT CONSOLE MENU ---\n"
menu_opt1:     .asciiz "1. Display Highest Access Code\n"
menu_opt2:     .asciiz "2. Count Even and Odd Codes\n"
menu_opt3:     .asciiz "3. Search for a Specific Code\n"
menu_opt4:     .asciiz "4. Sort Codes in Ascending Order\n"
menu_opt5:     .asciiz "5. Display Odd Codes Only\n"
menu_opt6:     .asciiz "6. Display Second Highest Code\n"
menu_opt7:     .asciiz "7. Sort Codes in Descending Order\n"
menu_opt8:     .asciiz "8. Exit Program\n"

menu_prompt:   .asciiz "Enter choice: "
menu_err:      .asciiz "Invalid Choice! Please enter a number 1-8.\n"

res_high:      .asciiz "The highest access code is: "
res_second:    .asciiz "The second highest access code is: "
res_even:      .asciiz "Even codes count: "
res_odd:       .asciiz "\nOdd codes count: "
res_search:    .asciiz "Enter code to search: "
found_msg:     .asciiz "Code FOUND in the system.\n"
not_found_msg: .asciiz "Code NOT FOUND.\n"
sort_msg:      .asciiz "Codes sorted in Ascending order: "
res_sort_desc: .asciiz "Codes sorted in Descending order: "
msg_odd_only:  .asciiz "\nList of Odd Access Codes: "
space:         .asciiz " "
exit_msg:      .asciiz "System Shutting Down... Goodbye."

.text
main:
    li $s7, 0           
    la $s6, vault_codes 

# ----------------- INPUT COLLECTION -----------------
input_loop:
    beq $s7, 10, menu_loop
    li $v0, 4
    la $a0, prompt_input
    syscall

    li $v0, 1
    addi $a0, $s7, 1
    syscall

    li $v0, 4
    la $a0, colon
    syscall

    li $v0, 8
    la $a0, buffer
    li $a1, 16
    syscall

    la $t5, buffer
    li $t2, 0           

validate_chars:
    lb $t6, 0($t5)
    beq $t6, 10, check_logic
    beq $t6, 0, check_logic
    blt $t6, 48, input_error
    bgt $t6, 57, input_error
    sub $t6, $t6, 48
    mul $t2, $t2, 10
    add $t2, $t2, $t6
    addi $t5, $t5, 1
    j validate_chars

check_logic:
    blt $t2, 1, input_error
    bgt $t2, 9999, input_error

    li $t0, 0           
dup_check_loop:
    beq $t0, $s7, store_data   
    sll $t3, $t0, 2
    add $t4, $s6, $t3
    lw $t8, 0($t4)
    beq $t8, $t2, duplicate_error
    addi $t0, $t0, 1
    j dup_check_loop

store_data:
    sll $t3, $s7, 2
    add $t4, $s6, $t3
    sw $t2, 0($t4)
    addi $s7, $s7, 1
    j input_loop

input_error:
    li $v0, 4
    la $a0, err_msg
    syscall
    j input_loop

duplicate_error:
    li $v0, 4
    la $a0, dup_msg
    syscall
    j input_loop

# ----------------- MENU -----------------
menu_loop:
    li $v0, 4
    la $a0, menu_head
    syscall
    la $a0, menu_opt1
    syscall
    la $a0, menu_opt2
    syscall
    la $a0, menu_opt3
    syscall
    la $a0, menu_opt4
    syscall
    la $a0, menu_opt5
    syscall
    la $a0, menu_opt6
    syscall
    la $a0, menu_opt7
    syscall
    la $a0, menu_opt8
    syscall
    la $a0, menu_prompt
    syscall

    li $v0, 8
    la $a0, buffer
    li $a1, 16
    syscall

    lb $t0, 0($a0)      
    lb $t1, 1($a0)      
    bne $t1, 10, menu_error

    beq $t0, 49, find_highest    # 1
    beq $t0, 50, count_even_odd  # 2
    beq $t0, 51, search_code     # 3
    beq $t0, 52, sort_ascending  # 4
    beq $t0, 53, disp_odd_only   # 5
    beq $t0, 54, find_second     # 6
    beq $t0, 55, sort_descending # 7
    beq $t0, 56, exit_prog       # 8

    j menu_error

menu_error:
    li $v0, 4
    la $a0, menu_err
    syscall
    j menu_loop

# ----------------- Feature 1: Display the highest value -----------------
find_highest:
    lw $s0, 0($s6)          # $s0 = initial max; load the first element (index 0)
    li $t0, 1               # $t0 = loop index; start at 1 (since we already loaded 0)

high_loop:
    beq $t0, 10, print_high # If index == 10, we've checked all elements
    
    # --- Memory Access ---
    sll $t3, $t0, 2         # $t3 = index * 4 (byte offset)
    add $t4, $s6, $t3       # $t4 = base address + offset
    lw $t2, 0($t4)          # $t2 = current element to compare

    # --- Comparison Logic ---
    # If current ($t2) <= current max ($s0), skip the update
    ble $t2, $s0, skip_max  
    
    # If we are here, current ($t2) is larger than $s0
    move $s0, $t2           # Update $s0 with the new highest value

skip_max:
    addi $t0, $t0, 1        # Increment index
    j high_loop             # Repeat for next element

# --- Display Result ---
print_high:
    li $v0, 4               # Syscall to print string
    la $a0, res_high        # "The highest value is: "
    syscall

    li $v0, 1               # Syscall to print integer
    move $a0, $s0           # Move the highest value to $a0 for printing
    syscall

    j menu_loop             # Return to the main menu

# ----------------- Feature 2: Counting the total of odd and even numbers -----------------
count_even_odd:
    li $v1, 0               # $v1 = Even counter (initialized to 0)
    li $s2, 0               # $s2 = Odd counter (initialized to 0)
    li $t0, 0               # $t0 = Loop index (0 to 9)

eo_loop:
    beq $t0, 10, print_eo   # If index == 10, we've checked the whole array
    
    # --- Memory Access ---
    sll $t3, $t0, 2         # $t3 = index * 4 (byte offset)
    add $t4, $s6, $t3       # $t4 = base address + offset
    lw $t2, 0($t4)          # $t2 = current array element

    # --- Parity Check Logic ---
    # The 'andi' instruction masks all bits except the last one.
    # If the last bit is 0, the number is even. If 1, it's odd.
    andi $t5, $t2, 1        # $t5 = $t2 AND 1
    beq $t5, 0, is_even     # If result is 0, jump to even logic
    
    # --- Odd Logic ---
    addi $s2, $s2, 1        # Increment odd counter ($s2)
    j eo_next               # Skip to next iteration

is_even:
    # --- Even Logic ---
    addi $v1, $v1, 1        # Increment even counter ($v1)

eo_next:
    addi $t0, $t0, 1        # Increment loop index
    j eo_loop               # Repeat for next element

# --- Display Results ---
print_eo:
    # Print Even Count
    li $v0, 4               # Print string syscall
    la $a0, res_even        # "Even numbers: "
    syscall
    li $v0, 1               # Print integer syscall
    move $a0, $v1           # Move count from $v1 to $a0 for printing
    syscall

    # Print Odd Count
    li $v0, 4               # Print string syscall
    la $a0, res_odd         # "\nOdd numbers: "
    syscall
    li $v0, 1               # Print integer syscall
    move $a0, $s2           # Move count from $s2 to $a0 for printing
    syscall

    j menu_loop             # Return to the program menu

# ----------------- Feature 3: Searching a specific code -----------------
search_code:
    # --- Input Collection ---
    li $v0, 4               # Syscall to print string
    la $a0, res_search      # Load "Enter number to search: " prompt
    syscall

    li $v0, 8               # Syscall to read string
    la $a0, buffer          # Address where input will be stored
    li $a1, 16              # Buffer size limit (16 bytes)
    syscall

    la $t5, buffer          # $t5 = pointer to the start of the input buffer
    li $s3, 0               # $s3 = will hold the converted integer (result)

# --- String to Integer (atoi) Conversion & Validation ---
validate_search_input:
    lb $t6, 0($t5)          # Load current character byte from buffer
    beq $t6, 10, start_search # If character is '\n' (Newline), conversion is done
    beq $t6, 0, start_search  # If character is '\0' (Null), conversion is done

    # Check if character is a digit (ASCII 48-57)
    blt $t6, 48, search_letter_error # If char < '0', it's an error
    bgt $t6, 57, search_letter_error # If char > '9', it's an error

    # Mathematical conversion: result = (result * 10) + (char - 48)
    sub $t6, $t6, 48        # Convert ASCII character to actual digit (e.g., '5' -> 5)
    mul $s3, $s3, 10        # Shift existing result left by one decimal place
    add $s3, $s3, $t6        # Add the new digit to the result
    addi $t5, $t5, 1        # Move buffer pointer to next character
    j validate_search_input

search_letter_error:
    li $v0, 4               # Syscall to print error
    la $a0, err_msg         # "Invalid input! Please enter numbers only."
    syscall
    j menu_loop             # Return to main menu

# --- Linear Search Logic ---
start_search:
    li $t0, 0               # $t0 = index counter (0 to 9)


search_loop:
    beq $t0, 10, not_found  # If we've checked all 10 elements, it's not there
    
    # Calculate address: address = base ($s6) + (index * 4)
    sll $t3, $t0, 2         # $t3 = index * 4 (offset)
    add $t4, $s6, $t3       # $t4 = memory address of current element
    lw $t2, 0($t4)          # $t2 = value stored in array[index]

    beq $t2, $s3, found     # If array value matches our search value ($s3), we found it!
    
    addi $t0, $t0, 1        # Increment index
    j search_loop           # Check next element

# --- Result Handling ---
found:
    li $v0, 4               # Syscall to print string
    la $a0, found_msg       # "Value found in the array!"
    syscall
    j menu_loop

not_found:
    li $v0, 4               # Syscall to print string
    la $a0, not_found_msg   # "Value not found."
    syscall
    j menu_loop

# ----------------- Feature 4: Sort the codes in ascending order -----------------
sort_ascending:
    li $t0, 0               # $t0 = outer loop counter (i)
          
outer_sort:
    beq $t0, 9, display_sorted  # If i == 9, sorting is complete (for 10 elements)
    li $t1, 0               # $t1 = inner loop counter (j)

inner_sort:
    # Optimization: Calculate (n - 1 - i) to avoid redundant comparisons
    li $t7, 9               # $t7 = total elements - 1
    sub $t7, $t7, $t0       # $t7 = 9 - i
    beq $t1, $t7, next_outer # If j == (9 - i), end of this pass; go to outer loop

    # Calculate memory addresses for array[j] and array[j+1]
    sll $t2, $t1, 2         # $t2 = j * 4 (convert index to byte offset)
    add $t3, $s6, $t2       # $t3 = base address ($s6) + offset; points to array[j]
    lw $t4, 0($t3)          # $t4 = array[j]
    lw $t5, 4($t3)          # $t5 = array[j+1]

    # Comparison and Conditional Swap
    ble $t4, $t5, skip_swap # If array[j] <= array[j+1], order is correct; don't swap
    sw $t5, 0($t3)          # Store smaller value in array[j]
    sw $t4, 4($t3)          # Store larger value in array[j+1]

skip_swap:
    addi $t1, $t1, 1        # j++
    j inner_sort            # Repeat inner loop

next_outer:
    addi $t0, $t0, 1        # i++
    j outer_sort            # Repeat outer loop

# --- Printing Results ---

display_sorted:
    li $v0, 4               # Syscall to print string
    la $a0, sort_msg        # Load "Sorted array: " message
    syscall

    li $t0, 0               # Reset counter to 0 for printing
display_loop:
    beq $t0, 10, menu_loop  # If we've printed 10 elements, return to menu
    
    sll $t1, $t0, 2         # $t1 = index * 4 (byte offset)
    add $t2, $s6, $t1       # $t2 = address of current element
    lw $a0, 0($t2)          # $a0 = value to print
    
    li $v0, 1               # Syscall to print integer
    syscall

    li $v0, 4               # Syscall to print string (space)
    la $a0, space           # Load address of " "
    syscall

    addi $t0, $t0, 1        # Increment print counter
    j display_loop          # Repeat printing loop

# ---------- Feature 5: Display Odd Codes ----------
disp_odd_only:
    li $v0, 4
    la $a0, msg_odd_only    # Print "List of Odd Access Codes: "
    syscall

    li $t0, 0               # Initialize loop counter (i = 0)

odd_loop:
    beq $t0, 10, finish_odd # If i == 10, exit loop
    
    # Calculate Array Address
    sll $t1, $t0, 2         # Offset = i * 4
    add $t2, $s6, $t1       # Address = Base + Offset
    lw  $a0, 0($t2)         # Load vault_codes[i] into $a0

    # Check if Odd
    andi $t3, $a0, 1        # Bitwise AND: checks the last bit
                            # If result is 1, number is ODD.
                            # If result is 0, number is EVEN.
    
    beq $t3, $zero, skip_print 

    # Print Odd Number
    li $v0, 1               # syscall to print integer
    syscall                 # Print the number in $a0

    # Print Space
    li $v0, 4
    la $a0, space           # Print " "
    syscall

skip_print:
    addi $t0, $t0, 1        # i++
    j odd_loop              # Repeat loop

finish_odd:
    li $v0, 11              # Print newline character for cleanliness
    li $a0, 10
    syscall
    j menu_loop             # Return to main menu

# ----------------- Feature 6: Display the second highest value -----------------
find_second:
    # --- Pass 1: Find the Absolute Maximum ($s0) ---
    lw $s0, 0($s6)          # $s0 = max; assume first element is largest
    li $t0, 1               # Start loop from index 1
find_max_loop:
    beq $t0, 10, start_second # If checked 10 items, move to finding second max
    sll $t3, $t0, 2         # Offset (index * 4)
    add $t4, $s6, $t3       # Element address
    lw $t2, 0($t4)          # Load array[i]
    ble $t2, $s0, skip1     # If current <= max, don't update
    move $s0, $t2           # New absolute max found
skip1:
    addi $t0, $t0, 1
    j find_max_loop

# --- Preparation for Pass 2 ---
start_second:
    lw $s1, 0($s6)          # $s1 = second max; temporarily load first element
    beq $s1, $s0, init_second # If first element IS the max, we need a better starting point
    j second_scan
init_second:
    li $s1, -2147483648     # Initialize to smallest possible integer if first element was max
                            # (Note: li $s1, 0 also works if array is all positive)

# --- Pass 2: Find the Highest Value that is less than $s0 ---
second_scan:
    li $t0, 0               # Reset index to 0
sec_loop:
    beq $t0, 10, print_second # If checked all, go to print
    sll $t3, $t0, 2
    add $t4, $s6, $t3
    lw $t2, 0($t4)          # Load array[i]

    beq $t2, $s0, skip2     # CRITICAL: If current element is the absolute max, ignore it
    ble $t2, $s1, skip2     # If current element is <= current second max, ignore it
    move $s1, $t2           # New second max found
skip2:
    addi $t0, $t0, 1
    j sec_loop

# --- Display Result ---
print_second:
    li $v0, 4
    la $a0, res_second      # "The second highest value is: "
    syscall
    li $v0, 1
    move $a0, $s1           # Print the value in $s1
    syscall
    j menu_loop

# ----------------- Feature 7: Sorting the codes in descending order --------------------
sort_descending:
    li $t0, 0               # $t0 = outer loop counter (i)
          
outer_desc:
    beq $t0, 9, display_desc # If i == 9, sorting is complete
    li $t1, 0               # $t1 = inner loop counter (j)

inner_desc:
    li $t7, 9               # $t7 = total elements - 1
    sub $t7, $t7, $t0       # Optimization: $t7 = 9 - i
    beq $t1, $t7, next_outer_desc # End of pass; go to outer loop

    # --- Address Calculation ---
    sll $t2, $t1, 2         # $t2 = j * 4 (offset)
    add $t3, $s6, $t2       # $t3 = base address + offset (points to array[j])
    lw $t4, 0($t3)          # $t4 = array[j]
    lw $t5, 4($t3)          # $t5 = array[j+1]

    # --- Descending Comparison ---
    # In ascending sort, we used 'ble'. 
    # Here, 'bge' means "if array[j] >= array[j+1], skip the swap."
    # This ensures larger numbers move toward the front (index 0).
    bge $t4, $t5, skip_swap_desc 
    
    # Swap elements
    sw $t5, 0($t3)          # Smaller value moved right
    sw $t4, 4($t3)          # Larger value moved left
    
skip_swap_desc:
    addi $t1, $t1, 1        # j++
    j inner_desc            # Repeat inner loop

next_outer_desc:
    addi $t0, $t0, 1        # i++
    j outer_desc            # Repeat outer loop

# --- Printing Results ---
display_desc:
    li $v0, 4               # Syscall: print string
    la $a0, res_sort_desc   # "Sorted Descending: "
    syscall
    
    li $t0, 0               # Reset index for printing
desc_display_loop:
    beq $t0, 10, menu_loop  # Print 10 elements then return to menu
    
    sll $t1, $t0, 2
    add $t2, $s6, $t1
    lw $a0, 0($t2)          # Load value for syscall
    
    li $v0, 1               # Syscall: print integer
    syscall
    
    li $v0, 4               # Syscall: print space
    la $a0, space
    syscall
    
    addi $t0, $t0, 1        # increment index
    j desc_display_loop

# ----------------- Feature 8: Exit the system -----------------
exit_prog:
    # --- Display Goodbye Message ---
    li $v0, 4               # Load syscall code 4 (print string)
    la $a0, exit_msg        # Load the address of your "Exiting program..." string
    syscall                 # Execute the print

    # --- Terminate Program ---
    li $v0, 10              # Load syscall code 10 (exit)
    syscall                 # Tell the system to stop
