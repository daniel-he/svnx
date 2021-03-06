#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entries'
require 'svnx/revision/argument'
require 'logue/loggable'

module SVNx; module Revision; end; end

module SVNx::Revision
  # this is of the form: -r123:456
  class Range
    include Logue::Loggable
    
    attr_reader :from
    attr_reader :to

    def initialize from, to = nil, entries = nil
      if to
        @from = to_revision from, entries
        @to = to_revision to, entries
      elsif from.kind_of? String
        @from, @to = from.split(':').collect { |x| to_revision x, entries }
      else
        @from = to_revision from, entries
        @to = :working_copy
      end
    end

    def to_revision val, entries
      val.kind_of?(Argument) ? val : Argument.create(val, entries: entries)
    end
    
    def to_s
      str = @from.to_s
      unless working_copy?
        str << ':' << @to.to_s
      end
      str
    end

    def head?
      @to && @to.value == 'HEAD'
    end

    def working_copy?
      @to == nil || @to == :wc || @to == :working_copy
    end
  end
end
