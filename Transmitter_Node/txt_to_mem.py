# Converts a normal text file into a .mem file containing ASCII values in hexadecimal format.
#
# To run and convert an input txt file (input.txt) to a .mem file (data.mem), the command is:
# python txt_to_mem.py input.txt data.mem

import sys
from pathlib import Path


def txt_to_mem_ascii(input_file, output_file):
    input_path = Path(input_file)

    if not input_path.exists():
        print(f"Error: {input_file} not found")
        return

    # Read entire text file
    with open(input_file, "r", encoding="utf-8") as f:
        text = f.read()

    # Convert each character to ASCII hex
    with open(output_file, "w") as f:
        for char in text:
            ascii_hex = format(ord(char), '02X')
            f.write(ascii_hex + "\n")


if __name__ == "__main__":
    txt_to_mem_ascii(sys.argv[1], sys.argv[2])
