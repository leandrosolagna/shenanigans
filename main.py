#!/usr/bin/env python

import argparse

parser = argparse.ArgumentParser()

parser.add_argument("-j", "--job",
                    metavar='N',
                    type=int,
                    help="Job number, N is the number of the job")
parser.add_argument("-l", "--list",
                    action="store_true", 
                    help="list the jobs from jenkins")
parser.add_argument("-L", "--log", 
                    action="store_true", 
                    help="Show the log from the job")
parser.add_argument("-v", "--verbose", 
                    action="store_true",
                    help="verbose mode")
parser.add_argument("--version", 
                    action='version',
                    help="show program's version and exit")

args = parser.parse_args()
if args.verbosity:
    print("verbosity turned on")

parser = argparse.ArgumentParser()
args = parser.parse_args()
