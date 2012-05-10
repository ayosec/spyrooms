# Installation

There is no installation. Just run `spyrooms.rb` after configure it.

# Configuration

Create a file `.campfire` in your home directory. This file, in YAML format, has two keys:

* `domain`, with the domain name of your company (like https://DOMAIN.campfirenow.com/)
* `token`, the API authentication token to make the requests. It can be retrieved from https://DOMAIN.campfirenow.com/member/edit

For example,

```bash
$ cat ~/.campfire 
token: xxxxxxxxxxxxxyyyyyyyyyyyyyzzzzzzzzzzzzzz
domain: mycompany
```

# Usage 

Just type

```bash
$ ruby ./spyrooms.rb
```

And it will load all your rooms and print their transcripts. By default, it shows the transcripts for the current day. If you want to show a different day just add `date=YYYY/MM/DD` as an argument, like

```bash
$ ruby ./spyrooms.rb date=2012/01/30
```

