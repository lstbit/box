# Linkr

A cute symlink manager written in python


Linkr works by recursively parsing a directory for `.linkrfiles` and
then creating the links specified within them. Linkrfiles must be named `.linkrfile`.


A linkerfile is a very simple text file that contains Link pairs in the below format. 

```linkrfile
.bashrc !home/bashrc
```

- The first value on a line must point to a value in the same dir as the linkrfile.
- The second value must contain a fully qualified path to a link location.
  Keywords are supported for this value.
  
  
### Keywords
All a keyword is a constant that gets subsititued to a pre-determined value at parse time.

A table of keywords is below.

| Keyword | Expansion |
|---------|-----------|
| !home   | ~/home    |
| !config | ~/.config |
  
