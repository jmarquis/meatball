import os
import markovify

source = ''

for filename in os.scandir('./sources'):
    with open(filename) as contents:
        text = contents.read()
        source = source + "\n" + text

text_model = markovify.Text(source, state_size=2)

print(text_model.make_short_sentence(280))
