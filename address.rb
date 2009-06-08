require 'rubygems'
require 'hpricot'
require 'open-uri'

class Array
    def split_where
        acc = []
        reduce([[]]) {|acc, e|
            acc[-1] << e
            acc << [] if yield e
            acc
        }
    end
end

ADDRESS_RE = /^(\s|\w)+,\s+[A-Z]{2}\s+\d{5}/
def find_addresses(url)
    Hpricot(open(url)).search("*").select {|e|
        e.kind_of? Hpricot::Text
    }.collect {|e|
        e.inner_text.gsub(/\s+$/, '').gsub(/&nbsp;/, ' ').gsub(/[\302\240]/,'')
    }.select {|t|
        t.length > 0
    }.split_where {|e|
        ADDRESS_RE === e
    }.collect {|a|
        a[-2,2]
    }.reject {|a|
        a.nil?
    }.collect {|a|
        a.join(' ')
    }
end

if $0 == __FILE__
    puts find_addresses(ARGV[0]).join("\n")
end
