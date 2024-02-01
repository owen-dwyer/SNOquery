import requests
import json
import pandas as pd
import time

HEADERS = {'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36'}

# Run a specified ECL query on the server defined in config.py
def run_ecl_query(id, max, uri, searchafter=None):
    try:

        request_string = uri+'/concepts?ecl='+id+'&limit='+str(max)
        if searchafter is not None:
            request_string = request_string +'&searchAfter=' + str(searchafter)

        r = requests.get(request_string, headers=HEADERS)



        r.raise_for_status()

        return r.json()
    except requests.exceptions.HTTPError as e:
        print('[!] '+ str(e.response.status_code))
        print('[!]  '+ e.response.text)


def run_ecl_queries(queries, max, uri):
    try:
        sess = requests.Session()
        adapter = requests.adapters.HTTPAdapter(max_retries = 20)
        sess.mount('http://', adapter)
    except:
        print('Could not establish session')


    results = []

    for id in queries:
        try:
            r = sess.get(uri+'/concepts?ecl='+id+'&limit='+ str(max), headers=HEADERS)
            r.raise_for_status()

            results.append(r.json())
        except requests.exceptions.HTTPError as e:
            print('[!] '+ str(e.response.status_code))
            print('[!]  '+ e.response.text)
            results.append(e.response.text)

        time.sleep(1.5)

    return results

# Processes a SNOMED mapping file and returns separate maps for ICD and OPCS
def load_mapping(path, REFSET_ID_ICD, REFSET_ID_OPCS):
    mapping = pd.read_csv(path, on_bad_lines='skip', sep='\t')

    mapping = mapping[['refsetId','referencedComponentId','mapGroup','mapPriority','mapTarget']]
    mapping = mapping[ mapping['mapTarget'].str[0] != '#' ]

    # Get the subsets of the mapping that map to ICD and OPCS respectively
    # i.e. where refsetId == (ID representing ICD/SNOMED, defined in config.py)
    mapping_icd = mapping[ mapping['refsetId']== REFSET_ID_ICD ] 
    mapping_opcs = mapping[ mapping['refsetId']== REFSET_ID_OPCS ]

    return mapping_icd, mapping_opcs

def get_snomed_editions(SNOMED_SERVER):
    try:
        r = requests.get(SNOMED_SERVER+'codesystems', headers=HEADERS)
        r.raise_for_status()

        return r.json()
    except requests.exceptions.HTTPError as e:
        print('[!] '+ str(e.response.status_code))
        print('[!]  '+ e.response.text)

def get_snomed_edition_versions(SNOMED_SERVER, edition):
    try:
        r = requests.get(SNOMED_SERVER+'codesystems/'+edition+'/versions', headers=HEADERS)
        r.raise_for_status()

        return r.json()
    except requests.exceptions.HTTPError as e:
        print('[!] '+ str(e.response.status_code))
        print('[!]  '+ e.response.text)