def replace_slashes_with_dots():
    """
    Replaces all occurrences of '/' with '.' in the unaffected.txt file
    """
    with open("unaffected.txt", "r", encoding="utf-8") as input_file:
        lines = input_file.readlines()

    with open("unaffected.txt", "w", encoding="utf-8") as output_file:
        for line in lines:
            modified_line = line.replace("/", ".")
            output_file.write(modified_line)

def main():
    replace_slashes_with_dots()

if __name__ == "__main__":
    main()
