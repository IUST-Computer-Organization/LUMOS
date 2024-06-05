import sys

file_name = sys.argv[1]
firmware_name = "Firmware" + ".hex"

with open(file_name, "r") as file:
    lines = file.readlines()

modified_lines = [line.split()[1][2:] +'\n' for line in lines]

final_hex_code = [elem for elem in modified_lines if elem != '\n\n']

with open(firmware_name, "w") as file:
    file.writelines(final_hex_code)
