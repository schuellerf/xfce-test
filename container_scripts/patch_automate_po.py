#!/usr/bin/env python
import re
i=0
with open("po/en_GB.po", 'r') as in_file, open("po/automate.po", 'w') as out_file:
    for line in in_file:
        orig_line = line
        line = re.sub(r"msgstr \"([^<].+)\"", r'msgstr "\1auto{}auto"'.format(i), line)
        line = re.sub(r"msgstr \"(<[^>]+>)(.+)(<[^>]+>)\"", r'msgstr "\1\2auto{}auto\3"'.format(i), line)
        if line != orig_line:
            i += 1
        out_file.write(line)
