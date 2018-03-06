import csv
import sys

if len(sys.argv) < 2:
  print('You have to provide the path of CSV file!')
  sys.exit(1)

csvfile = open(sys.argv[1], 'r')
reader = csv.reader(csvfile)
all_content_list = list(reader)

"""

['timeStamp', 'elapsed', 'label', 'responseCode', 'responseMessage', 'threadName', 'dataType', 'success', 'failureMessage', 'bytes', 'sentBytes', 'grpThreads', 'allThreads', 'Latency', 'IdleTime', 'Connect']

['1520310348810', '31618', 'Page Load Time Test', '200', 'Number of samples in transaction : 135, number of failing samples : 0', 'Thread Group 1-1', '', 'true', '', '13070141', '87230', '1', '1', '16374', '460', '5546']

"""

total_data_row = all_content_list[-1]

print('All of the elements in {0} takes {1} seconds and {2:3.2f} MBytes to read.'.format(total_data_row[2], int(total_data_row[1]) / 1000, float(total_data_row[9]) / (1024 * 1024)))

