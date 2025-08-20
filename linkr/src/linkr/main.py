import click
import os

ANSI_COLORS = {
    "red": "\033[31m",
    "green": "\033[32m",
    "blue": "\033[34m",
    "yellow": "\033[33m",
    "reset": "\033[0m",
}

ANSI_COLORS_BOLD = {
    "red": "\033[1;31m",
    "green": "\033[1;32m",
    "blue": "\033[1;34m",
    "yellow": "\033[1;33m",
    "reset": "\033[0m",
}

class Flags():
    def __init__(self):
        self.force = False
        self.verbose = False

class LostbitPrinter():
    def __init__(self):
        pass
        
    def success(self, msg):
        print(f'{ANSI_COLORS_BOLD['green']}[^_^]:{ANSI_COLORS['reset']} {msg}')
        return

    def info(self, msg):
        print(f'{ANSI_COLORS_BOLD['blue']}[0_0]:{ANSI_COLORS['reset']} {msg}')
        return

    def warn(self, msg):
        print(f'{ANSI_COLORS_BOLD['yellow']}[-_-]:{ANSI_COLORS['reset']} {msg}')
        return

    def error(self, msg):
        print(f'{ANSI_COLORS_BOLD['red']}[>_<]:{ANSI_COLORS['reset']} {msg}')
        return

    def fatal(self, msg):
        print(f'{ANSI_COLORS_BOLD['red']}[x_x]:{ANSI_COLORS['reset']} {msg}')
        return

    def pad(self, msg):
        """Prints a padded message for depth of 1"""
        padding = 7 * ' '
        print(padding + msg)
        return

def gather_linkrfiles(dir):
    accumulator = []
    recurse_dir(dir, accumulator)

    return accumulator

def recurse_dir(dir, accum):
    """
    Recurse through dir gathering a list of all .linkrfile locations in accum
    """
    for file in os.scandir(dir):
        if file.is_dir():
            recurse_dir(file.path, accum)

        if file.name == '.linkrfile':
            accum.append(file.path)

def expand_path(linkrfile_path):
    """
    Expands linkrfile paths substitution syntax with the correct values
    see constants or README for more info
    """
    expanded_path = []
    for part in linkrfile_path.split('/'):
        if part == '!home' or part == '!HOME':
            expanded_path.append(HOME_DIR)
            continue
            
        if part == '!config' or part == '!CONFIG':
            expanded_path.append(CFG_DIR)
            continue

        if part == '!cfg' or part == '!CFG':
            expanded_path.append(CFG_DIR)
            continue

        else:
            # We prepend the dir separator here so we can call
            # join without /
            expanded_path.append(f'/{part}')

    return ''.join(expanded_path)

def parse_linkrfile(path):
    """
    Parse Linkrfile into a array of tuples, with each tuple
    representing a line in the file. An example linkrfile entry is:

    .bashrc !home/.bashrc

    The first part of an entry is a file relative to the linkfile
    location. This is the Link Target.

    The second part of an entry is the Link Location. Link Locations
    may contain keywords for path expansion. This is denoted by
    !keyword. For more information on keywords see README

    Lines that start with a # are comments and are ignored.
    Leading and trailing whitespace is ignored.
    """
    file_dir = path.split('/')[:-1]
    res = []

    with open(path) as f:
        for line in f:
            line = line.strip()
            if line[0] == '#':
                continue
            
            contents = line.split()

            if len(contents) < 2:
                lbprint.error(f"Failed to parse line in {path}")
                lbprint.pad(f"line: {line}")

            res.append((f'{'/'.join(file_dir)}/{contents[0]}',
                        expand_path(contents[1])))

    return res

def link_exists(link) -> bool:
    """
    Checks if a file or link exists at the link location provided by the link argument.
    Links is expected to be a tuple of (target, link_location), these must be path-like objects
    """
    target, link_location = link
    if os.path.exists(link_location):
        lbprint.info(f'File found at location: {link_location}')
        return True

    if os.path.exists(link_location) and os.path.islink(link_location):
        if os.path.realpath(link_location) == target:
            lbprint.info(f'Link already exists: {link_location} -> {target}')
            return True

    return False


def make_link(link):
    """
    Expects a Link tuple in the format (target, link_location).
    All paths must be Fully Qualified
    """
    target, link_location = link

    if target[0] != '/':
        lbprint.error(f'Found malformed link tuple: {link}')
        lbprint.pad(f'Target value is not a fully qualified path {target}')
        os.exit(1)

    if link_location[0] != '/':
        lbprint.error(f'Found malformed link tuple: {link}')
        lbprint.pad(f'Link Location value is not a fully qualified path {link_location}')
        os.exit(1)

    link_location_dir_list = link_location.split('/')[:-1]
    link_location_dir = '/'.join(link_location_dir_list)

    if link_exists(link):
        if flags.force:
            os.remove(link_location)
        else: 
            return

    if not os.path.exists(link_location_dir):
        os.mkdir(link_location_dir)

    try:
        os.symlink(target, link_location)
        lbprint.success(f'Link Created: {link_location} -> {target}')

    except Exception as e:
        lbprint.error(f'Failed to create link: {link_location} -> {target}')
        print(10 * '-')
        print(e)

def flatten_list(x):
    flat = []
    for y in x:
        for z in y:
            flat.append(z)
    return flat


flags = Flags()
lbprint = LostbitPrinter()
HOME_DIR = os.getenv('HOME')
CFG_DIR = os.path.expanduser('~/.config')

@click.command()
@click.argument('dir', type=click.Path(exists=True))
@click.option('-f', '--force', is_flag=True)
@click.option('-v', '--verbose', is_flag=True)
def main(dir, force, verbose):
    """a cute symlink manager.
    """
    if force:
        flags.force = True

    if verbose:
        flags.verbose = True

    dir = os.path.expanduser(dir)
    linkrfiles = gather_linkrfiles(dir)
    contents = []
    for file in linkrfiles:
        contents.append(parse_linkrfile(file))

    links = flatten_list(contents)

    for link in links:
        make_link(link)

if __name__ == '__main__':
    main()
