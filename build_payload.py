import json
import sys

data = json.loads("""{"CodePipeline.job":{"data":{"actionConfiguration":{"configuration":{"UserParameters":"GGININ"}}}}}""")
data['CodePipeline.job']['data']['actionConfiguration']['configuration']['UserParameters'] = sys.stdin.read()

print(data)
