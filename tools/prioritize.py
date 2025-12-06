# import math
import os
# import pickle
import sys
from copy import deepcopy

from fast import fast_pw, fast_, loadTestSuite
from functions import read_file, save_file
from constants import *
# import metric

import fast_parser

# Multiprocessing tools
import multiprocessing
from multiprocessing import Pool
# from functools import partial
# from contextlib import contextmanager


usage = """USAGE: python prioritize.py <working_dir> <results_dir> <repetitions> <benchmark>
OPTIONS:
  <working_dir>: project directory to prioritize.
    Must contain a .fast subdirectory created by fast_parser.py.
  <results_dir>: directory to store prioritized test suites.
  <repetitions>: number of prioritization to compute.
    options: positive integer value, e.g. 30.
  <benchmark>: only used for testing purposes. Default: False.
  
NOTE:
  STR, I-TSD are BB prioritization only.
  ART-D, ART-F, GT, GA, GA-S are WB prioritization only."""

working_dir = '.'
output_dir = '.'
method = str_fast_pw

test_suite = {}
id_map = {}
total_time = {}

def bboxPrioritization(iteration):
    global working_dir
    global output_dir
    global id_map

    # Standard FAST parameters
    r, b = 1, 10
    
    if method == str_fast_pw:
        stime, ptime, prioritization = fast_pw(
                r, b, test_suite)
    else:
        def one_(x): return 1
        stime, ptime, prioritization = fast_(
                one_, r, b, test_suite)
            

    # writePrioritizedOutput(output_dir, prioritization, iteration)
    out_path = os.path.join(output_dir, str(iteration)+".txt")
    save_file(out_path, map(lambda p: id_map[p], prioritization))
    # out_path = os.path.join(output_dir, str(iteration)+"_ids.txt")
    # save_file(out_path, map(lambda p: "{}".format(p), prioritization))

    return stime + ptime


if __name__ == "__main__":

    # if len(sys.argv) == 5:
    #     benchmark = sys.argv[4]
    # else:
    #     benchmark = "false"
    if len(sys.argv) > 4 and len(sys.argv) <= 6:
        num_iterations = int(sys.argv[4])
    else:
        num_iterations = 30
    if len(sys.argv) > 3 and len(sys.argv) <= 6:
        what_to_prioritize = sys.argv[1]
        working_dir = sys.argv[2]
        results_dir = sys.argv[3]
    else:
        exit(1)

    fast_dir = os.path.join(working_dir,'.fast')

    if what_to_prioritize == "all":
        suite = str_fast_pw
        tests_path = "all_tests.txt"
    elif what_to_prioritize == "selected":
        suite = str_comb_s
        tests_path = "affected_tests.txt"
    else:
        exit(1)

    # ====
    path = os.path.join(results_dir, tests_path)
    if os.path.exists(path):
        tests = read_file(path)
        test_suite, id_map = loadTestSuite(tests, input_dir=fast_dir)

        # FAST-pw on entire test suite
        output_dir = os.path.join(results_dir, suite)
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
        num_cores = multiprocessing.cpu_count()
        with Pool(num_cores) as pool:
            running_time = pool.map(bboxPrioritization, range(1, num_iterations + 1))

        total_time = deepcopy(running_time)
    else:
        exit(1)

   
