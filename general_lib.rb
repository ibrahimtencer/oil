Infinity = Float::INFINITY
Idfn = -> x {x}

class Object
  def let
    yield self
  end

  def to_bool #equivalent to !!
    self ? true : false
  end

  def xor other
    self ? !other : other
  end

  def mapr *procs
    #procs can be symbols, methods, lambdas, ...
    procs.hash_map {|prc| prc.to_proc[self]}
  end
end

module Enumerable
  def split_by &pred
    trues, falses = [], []
    each do |x|
      (pred[x] ? trues : falses) << x
    end
    [trues, falses]
  end

  def hash_map &blk #use Array#to_h with block instead?
    Hash[map {|obj| [obj, blk[obj]]}]
  end
end

class Array
  def remove obj
    #probably equivalent to self - [obj] (without duplicates)
    dup.let {|res| res.delete(obj); res}
  end

  def slap
    each {|x| p x}
    nil
  end
end

class Hash #ActionController::Parameters #a hash basically
  def only *keys
    select {|k| keys.index(k)}
  end

  #already part of ActiveSupport
  #def without *keys
  #  reject {|k| keys.index(k)}
  #end
end

class Float
  def duration prec=0
    factor = 1
    [60, 60, 24, 7, 52, Infinity].zip(%w[seconds minutes hours days weeks years]).each do |conv, unit|
      if self < factor * conv
        numeric = (self/factor).round(prec)
        return "#{numeric} #{numeric == 1 ? unit.chop : unit}"
      else
        factor *= conv
      end
    end
  end
end

class Symbol
  #for easily composing symbols as Procs
  def << other
    -> x {self.to_proc[other.to_proc[x]]}
  end

  def >> other
    s = self.to_proc
    proc {|x| other.to_proc[s[x]]}
  end
end

#module Kernel
#  def random_unique q, n
#    #return q unique random numbers in the range 0...n
#    res = []
#    while res.size < q
#      res << rand(n)
#      res.uniq!
#    end
#    res
#  end
#
#  def condl *args
#    res = []
#    args.each_slice(2) {|cond, obj| res << obj if cond}
#    res
#  end
#end

class Numeric
  def divprec b, prec
    (to_f / b).round(prec)
  end
end

class String
  def past_tense
    end_with?("e") ? self + "d" : self + "ed"
  end

  def crunch
    #to make greater use of %w[] syntax which doesn't allow empty strings
    gsub("_", "")
  end

  def uri_encode
    #because the new encode method doesn't work correctly
    URI.encode_www_form_component(self).gsub("+", "%20")
  end
end

class TrueClass
  def to_i
    1
  end
end

class FalseClass
  def to_i
    0
  end
end
