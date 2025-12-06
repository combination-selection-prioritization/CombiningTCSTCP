from collections import defaultdict
from collections import OrderedDict
from struct import pack, unpack
import os
import random
import sys
import time
import pickle
from glob import glob
from copy import deepcopy

import lsh


def loadTestSuite(selected, input_dir):
    lsh_files = glob(os.path.join(input_dir, "*.lsh"))
    TS = OrderedDict()
    tcID = 1
    IDmap = {}
    for lshf in lsh_files:
        tcstr, _ = os.path.splitext(os.path.basename(lshf))

        if tcstr in selected:
            with open(lshf, 'rb') as f:
                TS[tcID] = pickle.load(f)
            IDmap[tcID] = tcstr
            tcID += 1

    return TS, IDmap

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


# lsh + pairwise comparison with candidate set
def fast_pw(r, b, test_suite):
    """INPUT
    (str)input_file: path of input file
    (int)r: number of rows
    (int)b: number of bands

    OUTPUT
    (list)P: prioritized test suite
    """
    n = r * b  # number of hash functions

    hashes = [lsh.hashFamily(i) for i in range(n)]

    mh_t = time.process_time()
    tcs_minhashes = deepcopy(test_suite)
    mh_time = time.process_time() - mh_t
    ptime_start = time.process_time()

    tcs = set(tcs_minhashes.keys())

    BASE = 0.5
    SIZE = int(len(tcs)*BASE) + 1

    bucket = lsh.LSHBucket(tcs_minhashes.items(), b, r, n)

    prioritized_tcs = [0]

    # First TC
    selected_tcs_minhash = lsh.tcMinhashing((0, set()), hashes)
    first_tc = random.choice(list(tcs_minhashes.keys()))
    for i in range(n):
        if tcs_minhashes[first_tc][i] < selected_tcs_minhash[i]:
            selected_tcs_minhash[i] = tcs_minhashes[first_tc][i]
    prioritized_tcs.append(first_tc)
    tcs -= set([first_tc])
    del tcs_minhashes[first_tc]

    iteration, total = 0, float(len(tcs_minhashes))
    while len(tcs_minhashes) > 0:
        iteration += 1
        if iteration % 100 == 0:
            sys.stdout.write("  Progress: {}%\r".format(
                round(100*iteration/total, 2)))
            sys.stdout.flush()

        if len(tcs_minhashes) < SIZE:
            bucket = lsh.LSHBucket(tcs_minhashes.items(), b, r, n)
            SIZE = int(SIZE*BASE) + 1

        sim_cand = lsh.LSHCandidates(bucket, (0, selected_tcs_minhash),
                                     b, r, n)
        filtered_sim_cand = sim_cand.difference(prioritized_tcs)
        candidates = tcs - filtered_sim_cand

        if len(candidates) == 0:
            selected_tcs_minhash = lsh.tcMinhashing((0, set()), hashes)
            sim_cand = lsh.LSHCandidates(bucket, (0, selected_tcs_minhash),
                                         b, r, n)
            filtered_sim_cand = sim_cand.difference(prioritized_tcs)
            candidates = tcs - filtered_sim_cand
            if len(candidates) == 0:
                candidates = tcs_minhashes.keys()

        selected_tc, max_dist = random.choice(tuple(candidates)), -1
        for candidate in tcs_minhashes:
            if candidate in candidates:
                dist = lsh.jDistanceEstimate(
                    selected_tcs_minhash, tcs_minhashes[candidate])
                if dist > max_dist:
                    selected_tc, max_dist = candidate, dist

        for i in range(n):
            if tcs_minhashes[selected_tc][i] < selected_tcs_minhash[i]:
                selected_tcs_minhash[i] = tcs_minhashes[selected_tc][i]

        prioritized_tcs.append(selected_tc)
        tcs -= set([selected_tc])
        del tcs_minhashes[selected_tc]

    ptime = time.process_time() - ptime_start

    return mh_time, ptime, prioritized_tcs[1:]


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


def fast_(selsize, r, b, test_suite):
    """INPUT
    (str)input_file: path of input file
    (fun)selsize: size of candidate set
    (int)r: number of rows
    (int)b: number of bands

    OUTPUT
    (list)P: prioritized test suite
    """
    n = r * b  # number of hash functions

    hashes = [lsh.hashFamily(i) for i in range(n)]

    mh_t = time.process_time()
    tcs_minhashes = deepcopy(test_suite)
    mh_time = time.process_time() - mh_t
    ptime_start = time.process_time()

    tcs = set(tcs_minhashes.keys())

    BASE = 0.5
    SIZE = int(len(tcs)*BASE) + 1

    bucket = lsh.LSHBucket(tcs_minhashes.items(), b, r, n)

    prioritized_tcs = [0]

    # First TC
    selected_tcs_minhash = lsh.tcMinhashing((0, set()), hashes)
    first_tc = random.choice(list(tcs_minhashes.keys()))
    for i in range(n):
        if tcs_minhashes[first_tc][i] < selected_tcs_minhash[i]:
            selected_tcs_minhash[i] = tcs_minhashes[first_tc][i]
    prioritized_tcs.append(first_tc)
    tcs -= set([first_tc])
    del tcs_minhashes[first_tc]

    iteration, total = 0, float(len(tcs_minhashes))
    while len(tcs_minhashes) > 0:
        iteration += 1
        if iteration % 100 == 0:
            sys.stdout.write("  Progress: {}%\r".format(
                round(100*iteration/total, 2)))
            sys.stdout.flush()

        if len(tcs_minhashes) < SIZE:
            bucket = lsh.LSHBucket(tcs_minhashes.items(), b, r, n)
            SIZE = int(SIZE*BASE) + 1

        sim_cand = lsh.LSHCandidates(bucket, (0, selected_tcs_minhash),
                                     b, r, n)
        filtered_sim_cand = sim_cand.difference(prioritized_tcs)
        candidates = tcs - filtered_sim_cand

        if len(candidates) == 0:
            selected_tcs_minhash = lsh.tcMinhashing((0, set()), hashes)
            sim_cand = lsh.LSHCandidates(bucket, (0, selected_tcs_minhash),
                                         b, r, n)
            filtered_sim_cand = sim_cand.difference(prioritized_tcs)
            candidates = tcs - filtered_sim_cand
            if len(candidates) == 0:
                candidates = tcs_minhashes.keys()

        to_sel = min(selsize(len(candidates)), len(candidates))
        selected_tc_set = random.sample(tuple(candidates), to_sel)

        for selected_tc in selected_tc_set:
            for i in range(n):
                if tcs_minhashes[selected_tc][i] < selected_tcs_minhash[i]:
                    selected_tcs_minhash[i] = tcs_minhashes[selected_tc][i]

            prioritized_tcs.append(selected_tc)
            tcs -= set([selected_tc])
            del tcs_minhashes[selected_tc]

    ptime = time.process_time() - ptime_start

    return mh_time, ptime, prioritized_tcs[1:]
