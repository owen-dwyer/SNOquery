import requests
import pandas as pd

HEADERS = {'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36'}



class Server:
    """
    A remote SNOMED server.
    """
    def __init__(self, uri):
        self.server_uri = uri
        self.branch_uri = None
        # future: allow branch to be passed as a parameter and automatically filled if known
        # if no branch specified, print warning message + advice on getting branches

    def get_response_return_object(self, response, return_type):
        if return_type=='json':
            return response.json()
        elif return_type=='df':
            return pd.DataFrame( response.json()['items'] )
        else:
            print("Error: return_type should be either 'json' (for raw JSON) or 'df' (for pandas DataFrame)")


    def get_snomed_editions(self, return_type='df'):
        """
        Get the SNOMED editions available at the server.
        """
        try:
            r = requests.get(self.server_uri+'codesystems', headers=HEADERS)
            r.raise_for_status()

        except requests.exceptions.HTTPError as e:
            print_error(e)

        if return_type=='json':
            return r.json()
        elif return_type=='df':
            return pd.DataFrame( r.json()['items'] )
        else:
            print("Error: return_type should be either 'json' (for raw JSON) or 'df' (for pandas DataFrame)")

    def get_snomed_versions(self, edition, return_type='df'):
        """
        Get available SNOMED versions for a given edition
        """
        try:
            r = requests.get(self.server_uri+'codesystems/'+edition+'/versions', headers=HEADERS)
            r.raise_for_status()

        except requests.exceptions.HTTPError as e:
            print_error(e)

        return self.get_response_return_object(r, return_type)
    
    def set_branch(self, branch):
        self.branch_uri = self.server_uri + branch


    def run_ecl_query(self, id, max, uri, searchafter=None):
        try:

            request_string = self.branch_uri+'/concepts?ecl='+id+'&limit='+str(max)
            if searchafter is not None:
                request_string = request_string +'&searchAfter=' + str(searchafter)

            r = requests.get(request_string, headers=HEADERS)

            r.raise_for_status()

            return r.json()
        except requests.exceptions.HTTPError as e:
            print('[!] '+ str(e.response.status_code))
            print('[!]  '+ e.response.text)


    def query(self, query_text, max_concepts = 10000):
        # Run the query against the SNOMED server

        # Server can't return any more than 10000 concepts at a time;
        # so if there are more than 10000 result concepts, we repeat the query until they're all retrieved.

        total_concepts = 0 
        concepts_retrieved = 0 # Number of concepts retrieved
        query_results_sets = []

        complete = False
        searchafter = None

        while complete==False:

            # Run the query
            query_results = self.run_ecl_query(query_text, max_concepts, self.branch_uri, searchafter)
            print(query_results)

            total_concepts = query_results['total'] # Get the total number of returned concepts
            concepts_retrieved = concepts_retrieved + max_concepts # Update counter
            query_results_sets.append(query_results) # Added retrieved concepts to output set

            print('Retrieved '+ str(len( query_results['items'] )) +' concepts')

            # If number of retrieved concepts < total number of possible concepts, loop again
            if concepts_retrieved >= total_concepts:
                complete=True
            else:
                searchafter = query_results['searchAfter']

        query_results_df = pd.concat( [pd.DataFrame(i['items']) for i in query_results_sets] )
        return query_results_df



        
# parses results as Pandas dataframes
