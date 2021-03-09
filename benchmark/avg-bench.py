#!/usr/bin/env python3

from sys import argv
from subprocess import run
from re import compile, findall, DOTALL
from itertools import product
from multiprocessing import Pool, cpu_count


def valid_bench_names():
    """
    Return a list with all the possible benchmark names in lower case.
    """
    return map(lambda t: t[0] + t[1],
               product(['bst-', 'avl-'], ['unsafe', 'fullextern', 'extern', 'intern']))


def is_valid_bench_name(bench_name):
    """
    Returns True if and only if the given benchmark name is a valid benchmark name.
    """
    valid_names = valid_bench_names()

    return bench_name.lower() in valid_names


USAGE_MESSAGE = """
  Usage: python3 avg-bench.py [BENCH NAME] [N] [DEBUG]
  where:
  
  * BENCH NAME (case insensitive) is necessary and must be one of:
  - bst-unsafe, avl-unsafe
  - bst-fullextern, avl-fullextern
  - bst-extern, avl-extern
  - bst-intern, avl-intern,
  - all.
  * N (optional) is a positive integer number which indicates
  how many times to repeat the benchmark (the results
  are averaged). It defaults to 5.
  * DEBUG (optional) is either True or False (case insensitive)
  and enables debug printing. Defaults to False.
  """


def exit_with_usage_msg():
    """
    Print the usage message and exit the interpreter.
    """
    print(USAGE_MESSAGE)
    exit()


def sanitize_arguments():
    """
    Sanitize the command line arguments.
    Ignore any extra arguments provided.
    """
    debug = False

    if (len(argv) < 2):
        exit_with_usage_msg()

    elif (len(argv) >= 2):
        bench_name = argv[1].strip().lower()
        if ((not is_valid_bench_name(bench_name)) and bench_name != "all"):
            exit_with_usage_msg()

        if (len(argv) > 2):
            n = argv[2].strip()
            if (not n.isdigit()):
                exit_with_usage_msg()
            else:
                n = int(n)

            if (len(argv) > 3):
                debug = argv[3].strip().lower()
                if (debug == "true"):
                    debug = True
                elif (debug != "false"):
                    exit_with_usage_msg()

        else:
            n = 5

    return bench_name, n, debug


def get_running_times(result, debug):
    """
    Parse the text results from the benchmark in order to extract the running times.
    Return a dictionary with keys 'INSERT', 'DELETE' and 'LOOKUP', and arrays as values.
    """
    print(result)
    get_insert_times_re = compile(r"INSERT\n(.*)\nDELETE", DOTALL)
    get_delete_times_re = compile(r"DELETE\n(.*)\nLOOKUP", DOTALL)
    get_lookup_times_re = compile(r"LOOKUP\n(.*)", DOTALL)
    insert_times = get_insert_times_re.findall(result)[0]
    delete_times = get_delete_times_re.findall(result)[0]
    lookup_times = get_lookup_times_re.findall(result)[0]
    if (debug):
        print("***get_running_times***", insert_times, delete_times, lookup_times, sep="\n")
    get_insert_times_re = compile(r"N=[\w|^]{1,4}: (\d*\.\d*)s")
    get_delete_times_re = compile(r"N=[\w|^]{1,4}: (\d*\.\d*)s")
    get_lookup_times_re = compile(r"N=[\w|^]{1,4}: (\d*\.\d*)s")
    insert_times = get_insert_times_re.findall(insert_times)
    delete_times = get_delete_times_re.findall(delete_times)
    lookup_times = get_lookup_times_re.findall(lookup_times)
    if (debug):
        print("***get_running_times***", insert_times, delete_times, lookup_times, sep="\n")
    insert_times = list(map(float, insert_times))
    delete_times = list(map(float, delete_times))
    lookup_times = list(map(float, lookup_times))
    if (debug):
        print("***get_running_times***", insert_times, delete_times, lookup_times, sep="\n")
    return {
        'INSERT': insert_times,
        'DELETE': delete_times,
        'LOOKUP': lookup_times
    }


def get_average_times(times):
    """
    Recives a list of dictionaries from get_running_times and computes the average
    for each function position wise.
    """
    return {
        'INSERT': [float('{:0.3e}'.format(sum(y) / len(times))) for y in zip(*[x['INSERT'] for x in times])],
        'DELETE': [float('{:0.3e}'.format(sum(y) / len(times))) for y in zip(*[x['DELETE'] for x in times])],
        'LOOKUP': [float('{:0.3e}'.format(sum(y) / len(times))) for y in zip(*[x['LOOKUP'] for x in times])]
    }


def run_benchmark(bench_name, bench_num, debug):
    """
    It executes the named benchmark using an exclusive builddir
    (the default is dist/)
    """
    result = run(f"cabal bench {bench_name.lower()} --builddir dist{bench_num}",
                 shell=True, capture_output=True, text=True)
    if (debug):
        print("***run_benchmark***", result, sep="\n")
    return get_running_times(result.stdout, debug)


def execute_benchmarks(bench_name, n, debug):
    """
    This function repeatedly executes (in parallel) the named benchmark
    and returns the average running times.


    @param bench_name: the name of the benchmark to execute. Possible choices are
    [bst|avl]-[unsafe|fullextern|extern|intern]. For instance, 'bst-extern'.

    @param n: the amount of times the benchmark is executed.

    @param debug: boolean which tells if debug printing is needed.

    @returns: the running times as a dictionary with three entries.
    Each entry has the running times of a different operation.
    The keys are the names of each operation: 'INSERT', 'DELETE', 'LOOKUP'.
    It also saves the results to a file.
    """
    with Pool(cpu_count()) as p:
        results = p.starmap(
            run_benchmark, [(bench_name, str(i), debug) for i in range(n)])
        results = get_average_times(results)
        if (debug):
            print("***execute_benchmarks***", results, sep="\n")
        save_results_to_file(f"benchmark/{bench_name}.txt", results)
        return results


def execute_all_benchmarks(n, debug):
    """
    This function repeatedly executes (in parallel) all the benchmarks
    and returns the average running times.

    @param n: the amount of times the benchmark is executed.

    @param debug: boolean which tells if debug printing is needed.

    @returns: None. It writes the results to different files. The name of
    each file is related to the benchmark name; the contents are those
    from the function execute_benchmarks.
    """
    for bench_name in valid_bench_names():
        results = execute_benchmarks(bench_name, n, debug)
        if (debug):
            print("***execute_all_benchmarks***", results, sep="\n")


def save_results_to_file(file_name, results):
    """
    Save the results of the function execute_benchmarks to a file
    with the following format:
      INSERT
      ...
      DELETE
      ...
      LOOKUP
      ...
    """
    with open(file_name, "w") as f:
        for op in results.keys():
            f.write(op + "\n")
            f.writelines(map(lambda n: str(n) + "\n", results[op]))


if __name__ == '__main__':
    bench_name, n, debug = sanitize_arguments()

    if (bench_name == "all"):
        execute_all_benchmarks(n, debug)
    else:
        results = execute_benchmarks(bench_name, n, debug)
        if (debug):
            print("main", results)
