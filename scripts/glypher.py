# from bs4 import BeautifulSoup
import argparse
import os.path

import requests
import re


def write_to_file(text, file_path):
    f = open(file_path, "w")
    f.write('local M = {}\n')
    f.write('function M.GetGlyphs()\n')
    f.write('return {\n')
    for line in text.split('\n'):
        components = line.split(':')
        if len(components) == 2:
            key = components[0].strip(' "').replace("-", "_")
            # Extract the Unicode hex value, convert it, and format it as an actual Unicode character
            hex_value = components[1].strip().replace('"', '').replace(',', '')
            unicode_char = chr(int(hex_value, 16))
            f.write(f"\t{key} = \"{unicode_char}\",\n")
    f.write('}\n')
    f.write('end\n')
    f.write('return M')

    f.close()


def main(url, file_path):
    resp = requests.get(url)

    glyphs_js = ''

    # Approach 1, using BeautifulSoup
    # soup = BeautifulSoup(resp.text, 'html.parser')
    # for script in soup.find_all('script'):
    #     if 'const glyphs = {' in script.text:
    #         glyphs_js = script.text
    #         break
    #

    # Approach 2, native python no packages
    pattern = re.compile(r'\s*const glyphs = \{[\s\S]*?\}', re.MULTILINE)

    matches = pattern.findall(resp.text)

    if matches:
        glyphs_js = matches[0]

    if glyphs_js:
        write_to_file(glyphs_js, file_path)
    elif not os.path.exists(file_path):
        write_to_file(glyphs_js, file_path)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Extract glyphs from nerdfont and write them to file')
    parser.add_argument('-f', '--filename', default='glyphs.lua', help='Filename to write glyphs to')
    args = parser.parse_args()

    url = 'https://www.nerdfonts.com/cheat-sheet'
    main(url, args.filename)
