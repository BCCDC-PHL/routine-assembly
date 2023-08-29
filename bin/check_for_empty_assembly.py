#!/usr/bin/env python3

import argparse
import os

def main(args):
    input_num_bytes = os.path.getsize(args.assembly)
    if input_num_bytes == 0:
        with open(args.assembly, 'w') as f:
            f.write('>' + args.sample_id + '_1\nN\n')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--assembly', help='Input assembly to check', required=True)
    parser.add_argument('--sample-id', help='Sample ID to write to header if empty assembly is found', required=True)
    args = parser.parse_args()
    main(args)
