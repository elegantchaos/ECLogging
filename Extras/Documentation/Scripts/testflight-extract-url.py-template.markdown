 Python script to extract the URL from the json results returned by TestFlight

### testflight-extract-url.py:
    #!/usr/bin/env python
    
    ## Python script to extract the URL from the json results returned by TestFlight
    
    import json
    import sys
    
    result = json.load(sys.stdin)
    url = result['config_url']
    
    print url
