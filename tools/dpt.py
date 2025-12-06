import os
import sys
import random

def prioritize_tests(input_file, output_dir, iterations):

    if not os.path.exists(input_file):
        sys.exit(1)


    with open(input_file, 'r') as f:
        lines = f.readlines()


    test_data = [line.strip().split() for line in lines]

    for iteration in range(1, iterations + 1):

        random.shuffle(test_data)


        test_data.sort(key=lambda x: int(x[-1]), reverse=True)


        output_file = os.path.join(output_dir, f"{iteration}.txt")


        with open(output_file, 'w') as f_out:
            for test_info in test_data:
                f_out.write(f"{test_info[0]}\n")

if __name__ == "__main__":
    if len(sys.argv) != 5:
        sys.exit(1)

    input_file = sys.argv[2]
    output_dir = sys.argv[3]
    iterations = int(sys.argv[4])


    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    prioritize_tests(input_file, output_dir, iterations)

