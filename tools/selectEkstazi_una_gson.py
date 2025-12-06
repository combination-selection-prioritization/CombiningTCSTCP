def filter_non_org():
    """
    Filters lines containing 'Non' in positions 12-26 and writes 
    specific portions from 'com' to unaffected.txt
    """
    with open("select.txt", "r", encoding="utf-8") as input_file:
        lines = input_file.readlines()

    with open("unaffected.txt", "w", encoding="utf-8") as output_file:
        for line in lines:
            segment = line[12:26]
            
            if "Non" in segment:
                com_index = line.find("com")
                if com_index != -1:
                    output_file.write(line[com_index:(len(line)-6)].rstrip('\n') + "\n")

def main():
    filter_non_org()

if __name__ == "__main__":
    main()
