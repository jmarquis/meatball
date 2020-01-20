import os
import argparse
import random
import markovify

source = ''

parser = argparse.ArgumentParser(description='Max length for sentence generator.')
parser.add_argument('maxlen')
args = parser.parse_args()

for filename in os.scandir('./sources'):
    with open(filename) as contents:
        text = contents.read()
        source = source + "\n" + text

state_size = random.randint(1, 3)
text_model = markovify.Text(source, state_size=state_size)

print(text_model.make_short_sentence(int(args.maxlen)))
