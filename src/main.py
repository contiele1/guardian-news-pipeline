import requests
import pprint

URL = "https://content.guardianapis.com/search"

apikey = "REDACTED"

params = {"q":"chess",
          "api-key":"test"}

response = requests.get(url=URL,params=params)

print(response)
#print(response.__attrs__)


data = response.json()
# pprint.pp(data)
pprint.pp(data['response']['results'][0])