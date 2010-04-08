require 'patternhash'

describe PatternHash, "new" do
  it "initializes an empty hash" do
    a = PatternHash.new
    a.keys.should == []
    a.values.should == []
  end
  
  it "initializes a hash with standard keys" do
    a = PatternHash.new({1 => 2, 2 => 3, 3 => 5, 4 => 7, 5 => 11})
    a[1].should == 2
    a[2].should == 3
    a[3].should == 5
    a[4].should == 7
    a[5].should == 11
    
    b = PatternHash.new({"a" => 1, "e" => 5, "i" => 9, "o" => 15, "u" => 21})
    b["a"].should == 1
    b["e"].should == 5
    b["i"].should == 9
    b["o"].should == 15
    b["u"].should == 21
    
    c = PatternHash.new({"pi" => :pi, :pi => 3.14, 3.14 => 3, 3 => [3,7,15,1], [3,7,15,1] => "pi"})
    c["pi"].should       == :pi
    c[:pi].should        == 3.14
    c[3.14].should       == 3
    c[3].should          == [3,7,15,1]
    c[[3,7,15,1]].should == "pi"
  end
  
  it "searches for a string key if no pattern key matches" do
    a = PatternHash.new({"small" => 512, "medium" => 2048, "large" => 20480, "larger" => 51200,
      /(\d+)MB/ => "%d Megabytes", /(\d+)GB/ => "%d Gigabytes"})
    a["small"].should == 512
    a["medium"].should == 2048
    a["large"].should == 20480
    a["larger"].should == 51200
  end
  
  it "searches for a string key if > 1 pattern keys match" do
    a = PatternHash.new({"small" => 512, "medium" => 2048, "large" => 20480, "larger" => 51200,
      /(\d+)MB/ => "%d Megabytes", /(\d+)GB/ => "%d Gigabytes", "3GB 14MB" => 3086})
    a["1GB 512MB"].should == nil
    a["3GB 14MB"].should == 3086
  end
  
  it "returns an association if there is one match, and value is not a String" do
    a = PatternHash.new({/(\d+)KB/ => 1024, /(\d+)MB/ => 1024*1024, /(\d+)GB/ => 1024*1024*1024})
    a["5KB"].should == [/(\d+)KB/, 1024]
    a["12KB"].should == [/(\d+)KB/, 1024]
    a["314MB"].should == [/(\d+)MB/, 1024*1024]
    a["123456789GB"].should == [/(\d+)GB/, 1024*1024*1024]
  end
  
  it "returns an interpolated string if there is one match, and value is a String" do
    a = PatternHash.new({/(\d+)KB/ => "%d Kilobytes", /(\d+)MB/ => "%d Megabytes", /(\d+)GB/ => "%d Gigabytes"})
    a["5KB"].should == "5 Kilobytes"
    a["12KB"].should == "12 Kilobytes"
    a["314MB"].should == "314 Megabytes"
    a["123456789GB"].should == "123456789 Gigabytes"
  end
  
  it "returns the return of a called Proc if there is one match, and value is a Proc" do
    a = PatternHash.new({
          /(\d+)KB/ => Proc.new {|kb| kb[0].to_i*1024},
          /(\d+)MB/ => Proc.new {|mb| mb[0].to_i*1048576},
          /(\d+)GB/ => Proc.new {|gb| gb[0].to_i*1073741824}})
    a["5KB"].should == 5120
    a["12KB"].should == 12288
    a["314MB"].should == 329252864
    a["123456789GB"].should == 132560717806043136
  end
end