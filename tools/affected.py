import sys

def filter_test_lines(file_path):
    try:
        with open(file_path, 'r') as file:
            lines = file.readlines()

        filtered_lines = [line.strip() for line in lines if 'Test' in line]

        with open(file_path, 'w') as file:
            file.write('\n'.join(filtered_lines))

    except FileNotFoundError:
        print("")
    except Exception as e:
        print("")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(1)

    file_path = sys.argv[1]
    filter_test_lines(file_path)

