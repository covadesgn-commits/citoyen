import requests
import time
import json

URL = "https://pjdgpkxccokvgqopibml.supabase.co/auth/v1/signup"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqZGdwa3hjY29rdmdxb3BpYm1sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzNDU1NDYsImV4cCI6MjA4ODkyMTU0Nn0.2hVSKwsUIOcV_kzEpyOGpI-lvyzrr4RYElc-BB-x4So"

headers = {
    "apikey": KEY,
    "Authorization": f"Bearer {KEY}",
    "Content-Type": "application/json"
}

ts = int(time.time())

profiles = [
    {
        "email": f"citoyen_{ts}@test.com",
        "password": "password123",
        "data": {
            "role": "citoyen",
            "first_name": "Jean",
            "last_name": "Dupont",
            "contact_phone": f"101{ts}",
            "location_address": "Rue du Citoyen"
        }
    },
    {
        "email": f"pme_{ts}@test.com",
        "password": "password123",
        "data": {
            "role": "pme",
            "business_name": "Super PME",
            "ifu": "IFU123456",
            "rccm": "RCCM-789",
            "contact_phone": f"102{ts}",
            "location_address": "Avenue PME"
        }
    },
    {
        "email": f"ztt_{ts}@test.com",
        "password": "password123",
        "data": {
            "role": "ztt",
            "center_name": "Centre ZTT Nord",
            "contact_phone": f"103{ts}",
            "location_address": "Zone Industrielle"
        }
    },
    {
        "email": f"usine_{ts}@test.com",
        "password": "password123",
        "data": {
            "role": "usine",
            "factory_name": "Usine Recyclage SA",
            "contact_phone": f"104{ts}",
            "location_address": "Route de l Usine"
        }
    },
    {
        "email": f"mairie_{ts}@test.com",
        "password": "password123",
        "data": {
            "role": "mairie",
            "commune": "Commune Centrale",
            "contact_phone": f"105{ts}"
        }
    }
]

for p in profiles:
    print(f"Testing {p['data']['role']}...")
    res = requests.post(URL, headers=headers, json=p)
    print(f"Status: {res.status_code}")
    print(res.text)
    print("-" * 40)
    time.sleep(1)
