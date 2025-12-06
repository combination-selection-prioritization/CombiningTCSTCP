import sys

def clean_and_update_coverage(all_tests_file, file_names_file, coverage_tests_file):

    with open(file_names_file, 'r') as file_names:
        file_names_cleaned = [line.replace('./repos/temp/.ekstazi/', '').strip() for line in file_names]

    with open(file_names_file, 'w') as file_names:
        file_names.write('\n'.join(file_names_cleaned))


    missing_lines = compare_files(all_tests_file, file_names_file)


    with open(coverage_tests_file, 'a') as coverage_tests:
        for line in missing_lines:
            coverage_tests.write(f"{line.strip()} 0\n")

def compare_files(file1, file2):
    with open(file1, 'r') as f1:
        content1 = set(line.strip() for line in f1.readlines())

    with open(file2, 'r') as f2:
        content2 = set(line.strip() for line in f2.readlines())

    difference = content1 - content2

    if difference:
        return difference
    else:
        return set()

if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(1)

    all_tests_file = sys.argv[1]
    file_names_file = sys.argv[2]
    coverage_tests_file = sys.argv[3]

    clean_and_update_coverage(all_tests_file, file_names_file, coverage_tests_file)
