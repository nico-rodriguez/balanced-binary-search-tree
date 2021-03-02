#!/usr/bin/env python3

from sys import argv
from subprocess import run
from re import compile, findall
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
  Usage: python3 avg-bench.py [BENCH NAME] [N]
  where BENCH NAME is necessary and must be one of:
  - bst-unsafe, avl-unsafe
  - bst-fullextern, avl-fullextern
  - bst-extern, avl-extern
  - bst-intern, avl-intern
  and N is a positive integer number which indicates
  how many times to repeat the benchmark (the results
  are averaged). It defaults to 5.
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
    if (len(argv) < 2):
        exit_with_usage_msg()
    elif (len(argv) >= 2):
        bench_name = argv[1].strip()
        if (not is_valid_bench_name(bench_name)):
            exit_with_usage_msg()
        if (len(argv) > 2):
            n = argv[2].strip()
            if (not n.isdigit()):
                exit_with_usage_msg()
            else:
                n = int(n)
        else:
            n = 5

    return bench_name, n


def get_running_times(result):
    """
    Parse the text results from the benchmark in order to extract the running times.
    Return a dictionary with keys 'INSERT', 'DELETE' and 'LOOKUP', and arrays as values.
    """
    get_times_re = compile('N=[\w|^]{1,4}: (\d*\.\d*)s')
    times = get_times_re.findall(result)
    times = list(map(float, times))
    return {
        'INSERT': times[0:10],
        'DELETE': times[10:20],
        'LOOKUP': times[20:30]
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


def run_benchmark(bench_name, bench_num):
    """
    It executes the named benchmark using an exclusive builddir
    (the default is dist/)
    """
    result = run(f"cabal bench {bench_name.lower()} --builddir dist{bench_num}",
                 shell=True, capture_output=True, text=True)
    return get_running_times(result.stdout)


def execute_benchmarks(bench_name, n):
    """
    This function repeatedly executes (in parallel) the named benchmark
    and returns the average running times.

    @param bench_name: the name of the benchmark to execute. Possible choices are
    [bst|avl]-[unsafe|fullextern|extern|intern]. For instance, 'bst-extern'.
    @param n: the amount of times the benchmark is executed.
    @returns: the running times as a dictionary with three entries. Each entry has
    the running times of a different operation. The keys are the names of each
    operation: 'INSERT', 'DELETE', 'LOOKUP'.
    """
    with Pool(cpu_count()) as p:
        results = p.starmap(
            run_benchmark, [(bench_name, str(i)) for i in range(n)])
        return get_average_times(results)


if __name__ == '__main__':
    bench_name, n = sanitize_arguments()

    results = execute_benchmarks(bench_name, n)

    print(results)
