def filter_org_com_domains():
    """
    Filters lines containing 'org' in positions 0-9 or 'com.' in positions 0-10
    and writes from position 6 to temp.txt
    """
    with open("select.txt", "r", encoding="utf-8") as input_file:
        lines = input_file.readlines()

    with open("temp.txt", "w", encoding="utf-8") as output_file:
        for line in lines:
            if "org" in line[0:9] or "com." in line[0:10]:
                output_file.write(line[6:len(line)])

def main():
    filter_org_com_domains()

if __name__ == "__main__":
    main()
