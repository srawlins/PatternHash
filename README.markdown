PatternHash
===========

PatternHash inherits Hash, and adds new matching ideas. Hashes match using #eql
on a key. So my_hash[my_key] will compare my_key with every key in the hash
using #eql, until it finds a match. A PatternHash will check if a submitted
String key also succeeds against =~'ing a Pattern key. Then it does various
things depending on the value. Let's explore:

Examples
--------

All Hash functionality is maintained

<pre><code>hashish = PatternHash.new({1 => 2, 2 => 3, 3 => 5, 4 => 7})
hashish[2]  #=> 3
hashish[0]  #=> nil</code></pre>