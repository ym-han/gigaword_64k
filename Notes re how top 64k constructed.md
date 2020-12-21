# Notes about my construction of the top 64k words


The corpus apparently sometimes features unusual punctuation:

> unusual punctuation (such as
the underscore character, used in NYT_ENG and APW_ENG to represent an
"em-dash" character) has been left as-is, or converted to simple
equivalents (e.g. hyphens).

But I didn't bother trying to clean / normalize that kind of stuff, since we don't need to get the exact frequency distribution for the gigaword corpus. For the SR project, we only need something that is a good enough approximation to the most common 'standard' words in English.