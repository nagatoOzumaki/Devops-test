import json
import requests
import csv
from io import StringIO

# Move the CSV URL outside of the function to avoid fetching it for every invocation
CSV_URL = "https://carbonwatch.kayrros.com/files/data.csv"

def fetch_latest_europe_co2_emission():
    # Fetch the CSV data from the URL
    response = requests.get(CSV_URL)
    
    # Check if the request was successful
    if response.status_code == 200:
        # Parse CSV data
        csv_data = response.text
        csv_reader = csv.DictReader(StringIO(csv_data))
        
        # Filter data for Europe and get the latest CO2 emission
        europe_data = [row for row in csv_reader if row['super_region'] == 'EU']
        if europe_data:
            latest_emission = europe_data[-1]['power']
            return latest_emission
    return None

def lambda_handler(event, context):
    # AWS Lambda handler function
    latest_emission = fetch_latest_europe_co2_emission()

    if latest_emission is not None:
        response = {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Latest CO2 Emission in Europe',
                'value': float(latest_emission),  # Convert to float if necessary
            })
        }
    else:
        response = {
            'statusCode': 500,
            'body': json.dumps({'error': 'Unable to fetch data'})
        }

    return response
