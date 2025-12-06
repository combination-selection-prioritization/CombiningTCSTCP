import sys

def process_file(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    with open(file_path, 'w') as file:
        for line in lines:
            org_index = line.find('com.')
            if org_index != -1:
                file.write(line[org_index:].strip() + '\n')

if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(1)

    file_path = sys.argv[1]
    process_file(file_path)

