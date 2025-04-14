import requests

URL = "https://content.guardianapis.com/search?q=debates"

apikey = "REDACTED"
test_apykey = "test"

response = requests.get(URL+"&api-key="+test_apykey)

print(response)

data = response.json()

print(data)