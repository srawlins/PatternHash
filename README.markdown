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

Keys that match will return an association, the matched Pattern (key), then the
corresponding value.

<pre><code>crash = PatternHash.new({/^\d*5$/ => 5, /^\d*2468$/ => 2, /^0x[0-9a-f]+$/ => :hex, /^0b[01]+$/ => :bin})
crash["123"]                         #=> nil
crash["12345"]                       #=> [/^\d*5$/, 5]
crash["987654"]                      #=> [/^\d*2468$/, 2]
crash["0xdeadbeef"]                  #=> [/^0x[0-9a-f]+$/, :hex]
crash["0xnotvalidhex"]               #=> nil
crash["0b010100110110000101101101"]  #=> [/^0b[01]+$/, :bin]</code></pre>

Keys that match more than one existing key, or none, will fall back to the
regular functionality.

<pre><code>sash = PatternHash.new({/foo/ => 1, /bar/ => 2, /baz/ => 3, "bar" => 4, "cat" => 5})
sash["foo"]     #=> [/foo/, 1]
sash["bar"]     #=> [/bar/, 2]
sash["foobar"]  #=> nil
sash["cat"]     #=> 5</code></pre>

String Values
-------------

Now onto the advanced functionality. If a String matches an existing Pattern
key, and the corresponding value is a String, then the String value is
returned, but also interpolated with the first subgroup in the match. Allow me.

<pre><code>cache = PatternHash.new({/(\d+)MB/ => "%d Megabytes", /(\d+)GB/ => "%d Gigabytes", /\$(\d+)/ => "%d dollars"})
cache["4MB"]   #=> "4 Megabytes"
cache["16MB"]  #=> "16 Megabytes"
cache["2GB"]   #=> "2 Gigabytes"
cache["$20"]   #=> "20 dollars"

names = PatternHash.new({
          /My name is (.*)/ => "Hello %s",
          /Your name is (.*)/ => "I am called %s"})
names["My name is Sam"]        #=> "Hello Sam"
names["Your name is HAL9000"]  #=> "I am called %s"</code></pre>

Proc Values
-----------

If a String matches an existing Pattern key, and the corresponding value is a
Proc, then the result of the Proc called is returned, sending the match to the
Proc. Allow me.

<pre><code>a = PatternHash.new({
          /(\d+)KB/ => Proc.new {|kb| kb[0].to_i*1024},
          /(\d+)MB/ => Proc.new {|mb| mb[0].to_i*1048576},
          /(\d+)GB/ => Proc.new {|gb| gb[0].to_i*1073741824}})
    a["5KB"]   #=>       5120
    a["12KB"]  #=>      12288
    a["314MB"] #=>  329252864
    a["2GB"]   #=> 2147483648</code></pre>