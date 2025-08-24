#!/usr/bin/env python3

import os
import shutil
import subprocess

from pathlib import Path, PurePath
from subprocess import CalledProcessError
from itertools import product
from typing import List


box_dir = '/home/bit/box'
iosevka_dir = '/home/bit/dev/oss/iosevka'
nerdfont_dir = '/home/bit/dev/oss/nerd-fonts-font-patcher'
build_dir = box_dir + '/penrose-fonts/build'

fonts = [
    'penrose-mono',
    'penrose-sans',
    'penrose-term',
]

families = [
    'Light',
    'Regular',
    'Bold',
    'ExtraBold',
    'Heavy',
    'LightItalic',
    'RegularItalic',
    'BoldItalic',
    'ExtraBoldItalic',
    'HeavyItalic',
]

def copy_iosevka_build_plans():
    build_file = box_dir + '/penrose-fonts/private-build-plans.toml'
    target = iosevka_dir + '/private-build-plans.toml'
    shutil.copyfile(build_file, target)

def construct_iosevka_build_cmd(font: str) -> List[str]:
    return ['npm', 'run', 'build', '--', f'contents::{font}', '--jCmd=6']

def construct_patch_cmd(font: str, out_dir: str) -> List[str]:
    font_patcher_path = '/home/bit/dev/oss/nerd-fonts-font-patcher/font-patcher'
    return ['fontforge', '-script', font_patcher_path, font, '-out', out_dir, '--careful', '-c', '--mono']

def copy_iosevka_fonts():
    os.chdir(iosevka_dir)
    os.makedirs(build_dir)

    for font in fonts:
        if font == 'penrose-sans':
            continue

        iosevka_font_dir = Path(iosevka_dir + f'/dist/{font}/TTF')
        font_output_dir = Path(build_dir + f'/{font}')
        print(f'copying artefacts from font: {font}')
        os.mkdir(font_output_dir)

        for file in iosevka_font_dir.iterdir():
            file_name = str(file).split('/').pop()
            origin_file = Path.joinpath(iosevka_font_dir, file_name)
            target_file = Path.joinpath(font_output_dir, file_name)
            shutil.copy(origin_file, target_file)
    

def build_fonts():
    print('copying build files to iosevka dir')
    print('attempting builds')

    os.chdir(iosevka_dir)
    for font in fonts:
        build_cmd = construct_iosevka_build_cmd(font)

        print(f'building: {font}')
        try:
            subprocess.run(build_cmd)

        except CalledProcessError:
            print(f'Failed to build font: {font}')

    print('copying iosevka build artefacts')
    copy_iosevka_fonts()

def patch_fonts():
    full_font_list = [f'{font}-{family}' for font, family in product(fonts, families)]
    
    nerd_font_output_dir = build_dir + '/nerd-fonts'
    os.mkdir(nerd_font_output_dir)

    for font in fonts:
        if font == 'penrose-sans':
            continue

        pre_patch_font_dir = build_dir + f'/{font}'
        font_output_dir = nerd_font_output_dir + '/' + font
        os.mkdir(font_output_dir)
        for family in families:
            full_font_name = font + '-' + family + '.ttf'
            input_font = pre_patch_font_dir + f'/{full_font_name}'
            cmd = construct_patch_cmd(input_font, font_output_dir)

            
            print(f'patching: {font}')
            try:
                subprocess.run(cmd)

            except CalledProcessError:
                print(f'Failed to patch font: {font}')

    pass

def main():
       build_fonts()
       patch_fonts()
        

if __name__ == '__main__':
    main()
