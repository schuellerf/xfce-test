#!/usr/bin/env python
import re
i=1
with open("po/en_GB.po", 'r') as in_file, open("po/automate.po", 'w') as out_file:
    for line in in_file:

        msgid = re.search(r"^msgid \"(.*)\"", line)
        if msgid:
            text = msgid.group(1)

        text_append= re.search(r"^\"(.*)\"",line)
        if text_append:
            text += text_append.group(1)
        orig_line = line
        line = re.sub(r"^msgstr \"([^<]?.*)\"", r'msgstr "\1auto{}auto"'.format(i), line)
        line = re.sub(r"^msgstr \"(<[^>]+>)(.+)(<[^>]+>)\"", r'msgstr "\1\2auto{}auto\3"'.format(i), line)
        if line != orig_line and len(text) > 0:
            i += 1
        else:
            line = orig_line
        out_file.write(line)
