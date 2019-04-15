#!/usr/bin/env python
import re
i=0
with open("po/en_GB.po", 'r') as in_file, open("po/automate.po", 'w') as out_file:
    for line in in_file:
        line = re.sub(r"msgstr \"([^<].+)\"", r'msgstr "auto{}auto\1"'.format(i), line)
        line = re.sub(r"msgstr \"(<[^>]+>)(.+)\"", r'msgstr "\1auto{}auto\2"'.format(i), line)
        i+=1
        out_file.write(line)
