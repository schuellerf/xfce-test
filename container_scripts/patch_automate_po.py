#!/usr/bin/env python3

"""
This script expects to be run in a source directory where a 'po' folder exists

For each .po file there an according "automate" language po-file will be created

This is cruicial to find translations directly in the UI during execution!

Obviously this has to be called prior to compilation
"""
import re
import os


def patch(file, new_file):
    i=1
    with open(file, 'r', encoding='utf-8') as in_file, open(new_file, 'w', encoding='utf-8') as out_file:
        line_nr=0
        for line in in_file:
            line_nr = line_nr + 1
            msgid = re.search(r"^msgid \"(.*)\"", line)
            if msgid:
                text = msgid.group(1)
    
            text_append= re.search(r"^\"(.*)\"",line)
            if text_append:
                text += text_append.group(1)
            orig_line = line
            line = re.sub(r"^msgstr \"([^<]?.+)\"", r'msgstr "\1auto{}auto"'.format(line_nr), line)
            line = re.sub(r"^msgstr \"(<[^>]+>)(.+)(<[^>]+>)\"", r'msgstr "\1\2auto{}auto\3"'.format(line_nr), line)
    
            if line != orig_line and len(text) > 0:
                if orig_line.endswith('\\n"\n'):
                    line = line[:-2] + '\\n"\n'
                i += 1
            else:
                line = orig_line
            out_file.write(line)

po_dir = 'po'
for dirname, dirnames, filenames in os.walk(po_dir):
    for file in filenames:
        if "automate" in file: continue
        m = re.search(r"^(.*?)(_.*)?\.po$", file)
        if (m):
            post=m.group(2) or ""
            new_file = f"{m.group(1)}automate{post}.po"
            print(f"{file} -> {new_file}")
            patch(os.path.join(po_dir,file), os.path.join(po_dir,new_file))
        
