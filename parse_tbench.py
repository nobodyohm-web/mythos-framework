import urllib.request
import re
import json

html = urllib.request.urlopen("https://www.tbench.ai/leaderboard/terminal-bench/2.0").read().decode("utf-8")
# Look for the exact data array block
match = re.search(r'\[{"agent":"OpenHands","model":\["Claude 3.5 Sonnet"\].*?\}\]', html)

if match:
    data = json.loads(match.group(0))
    data.sort(key=lambda x: x['accuracy'], reverse=True)
    
    print(f"{'RANK':<4} | {'AGENT':<20} | {'MODEL':<20} | {'SCORE':<6}")
    print("-" * 60)
    
    for i, row in enumerate(data):
        print(f"{i+1:<4} | {row['agent'][:18]:<20} | {row['model'][0][:18]:<20} | {row['accuracy']:.1%}")
else:
    print("Could not parse data block")
