# Overview #
Token lets you create a data file, then access it with one or more
cryptographic tokens. This basic use case is a per use data file, with
one or more cryptographic tokens to look up its content.

# Structure #
Token works with a directory layout, storing two kinds of things:
* data files
* tokens that reference those data files

`root` is any root directory of your choosing.

```
root/
  data/
  token/
```

## Sample Usage ##

Here is the basic rundown on how to use the thing, for more information,
just `token --help`.

```
#yep you need node
npm install -g git://github.com/wballard/token.git

#set up the directory structure
token --directory sample init
#set up an initial data file, and set it some content, token will read
#stdin and put the data in the right place
echo "Hi there!" | token --directory sample data user@a.com
#create a token, stuff it in a variable so we can see it
export TOKEN=$(token --directory sample create user@a.com)
echo $TOKEN
#now, use your token to fetch your data
token --directory sample decode $TOKEN
#behold, Hi there!
```

# Implementation #
Token sets up a series of simple simlinks to create tokens, allowing you
to have as many or as few as you like. This ends up using the file
system as a multiple key hash table to point at your data.

Becuase it is _just files_ you can always change, edit, or modify as you
see fit with your editor or command line. For example, explicitly
revoking a token with `rm`, or changing the data referenced by a token
with `vim`.
