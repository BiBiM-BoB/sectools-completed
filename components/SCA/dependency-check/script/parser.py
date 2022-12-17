import json
import sys

def parser(file_path:str, parsed_path):
    with open(file_path, 'r') as f:
        data = json.load(f)

    results = data['dependencies']

    for r in results:
        evidence = r['evidenceCollected']
        if not evidence['vendorEvidence']:
            del r['evidenceCollected']['vendorEvidence']
        if not evidence['productEvidence']:
            del r['evidenceCollected']['productEvidence']
        if not evidence['versionEvidence']:
            del r['evidenceCollected']['versionEvidence']

    results = [item for item in results if item['evidenceCollected']]

    for r in results:
        if('evidenceCollected' in r):
            del r['evidenceCollected']
        
    with open(parsed_path, 'w') as outfile:
        json.dump(results, outfile, indent=4)

if __name__ == '__main__':
    # argv[1] : created report path
    # argv[2] : cleaned report path
    parser(sys.argv[1], sys.argv[2])
