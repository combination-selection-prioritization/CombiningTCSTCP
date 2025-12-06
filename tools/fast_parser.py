from collections import defaultdict
import os
import re
import sys
import pickle
from hashlib import md5
from glob import glob
import lsh

from functions import fully_qualified_name

def parse_coverage_info(input_file):
    tc = ""

    with open(input_file) as fin:
        tc = re.sub("\s+", " ", fin.read()).strip()

    if tc == "":
        print (" ----->", "empty coverage:", input_file)
    return tc

def store_md5(md5_path, computed_md5):
    # Generate MD5 hash
    with open(md5_path, 'w') as f_md5:
        f_md5.write(computed_md5)

def compute_lsh(tc, lsh_path):
    r, b = 1, 10
    n = r * b
    hash_functions = [lsh.hashFamily(i) for i in range(n)]

    # Generate LSH hash
    with open(lsh_path, 'wb') as f_lsh:
        shingle = lsh.kShingle(tc, 5)
        minhash = lsh.tcMinhashing(shingle, hash_functions)
        pickle.dump(minhash, f_lsh)

def parseTests(working_dir):

    # Find all files that match the JUnit test pattern
    test_files = glob(os.path.join(working_dir,'**/*Test*.java'), recursive=True)
    # Create FAST hidden dir
    fast_dir = os.path.join(working_dir,'.fast')
    if not os.path.exists(fast_dir):
        os.mkdir(fast_dir)

    tcID = 1
    for test_file in test_files:
        # Extract the code from the test file
        tc = parse_coverage_info(test_file)
        f_name = fully_qualified_name(test_file)

        if (tc == '') or (f_name == ''):
            continue

        md5_path = os.path.join(fast_dir, f_name+'.md5')
        lsh_path = os.path.join(fast_dir, f_name+'.lsh')

        computed_md5 = md5(tc.encode('utf-8')).hexdigest()
        stored_md5 = ""
        if (os.path.isfile(md5_path)):
            # Read MD5 hash from file
            with open(md5_path, 'r') as f_md5:
                stored_md5 = f_md5.read()
        
        if stored_md5 != computed_md5:
            # file was added or changed since last revision
            store_md5(md5_path, computed_md5)
            compute_lsh(tc, lsh_path)

        tcID += 1

if __name__ == '__main__':

    working_dir = '.'
    if len(sys.argv) == 2:
        working_dir = sys.argv[1]
    
    parseTests(working_dir)
    
