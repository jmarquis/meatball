import os
import argparse
import markovify

source = ''

parser = argparse.ArgumentParser(description='Max length for sentence generator.')
parser.add_argument('maxlen')
args = parser.parse_args()

for filename in os.scandir('./sources'):
    with open(filename) as contents:
        text = contents.read()
        source = source + "\n" + text

text_model = markovify.Text(source, state_size=2)

print(text_model.make_short_sentence(int(args.maxlen)))
