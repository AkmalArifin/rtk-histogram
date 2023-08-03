import os
import sys
import re

TOPDIR = os.path.abspath(os.getcwd())
RAWDIR = TOPDIR + "/raw"
CMBDIR = TOPDIR + "/cmb"

def combine_log(file_name, folder_name):

    # Open and read file
    dir = RAWDIR + '/' + folder_name + '/' + file_name
    file = open(dir, 'r', encoding="utf-8", errors="ignore")

    # Pass data to log
    log = []

    for line in file:
        parse_line = line.split(",")
        parse_line[-1] = parse_line[-1].replace('\n', '')
        to_int = [int(string) for string in parse_line]
        log.append(to_int)

    file.close()

    # Count highest index
    highest_count = 0
    cur_count = 1
    numjobs = 1
    for i in range(1, len(log)):
        prev_line = log[i-1]
        line = log[i]
        if (line[0] > prev_line[0]):
            cur_count += 1
        else:
            highest_count = max(highest_count, cur_count)
            cur_count = 1
            numjobs += 1

    highest_count = max(highest_count, cur_count)

    # create new log
    new_log = [[(i+1)*1000, 0] for i in range(highest_count)]

    # Create based on highest index
    for line in log:
        idx = int(line[0]/1000) - 1
        if (idx < highest_count):
            try:
                new_log[idx][1] += line[1]
            except:
                print(idx)
    
    sum = 0
    for line in new_log:
        sum += line[1]
    avg = sum/highest_count

    return [numjobs, avg]

folder_name = sys.argv[1]
pattern = r"\.log$"

results_log = []

for file_name in os.listdir(RAWDIR + '/' + folder_name):
    result = re.search(pattern, file_name)
    if (result):
        output = combine_log(file_name, folder_name)
        results_log.append(output)

results_log.sort()
for line in results_log:
    print(line)

# TODO: give an interface to input list of file that want to combined
