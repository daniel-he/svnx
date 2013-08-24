#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entries'
require 'svnx/revision/error'
require 'logue/loggable'

module SVNx; module Revision; end; end

# We represent what svn calls a revision (-r134:{2010-1-1}) as a Range,
# consisting of a from and to (optional) Argument.
module SVNx::Revision
  RELATIVE_REVISION_RE = Regexp.new '^([\+\-])(\d+)$'
  
  # Returns the Nth revision from the given logging output.
  
  # -n means to count from the end of the list.
  # +n means to count from the beginning of the list.
  #  n means the literal revision number.  
  class Argument
    include Logue::Loggable, Comparable

    DATE_REGEXP = Regexp.new '^\{(.*?)\}'
    SVN_ARGUMENT_WORDS = %w{ HEAD BASE COMMITTED PREV }
    
    # these are also valid revisions
    # :working_copy
    # :head

    attr_reader :value

    class << self
      alias_method :orig_new, :new

      def new value, args = Hash.new
        # these are log entries:
        entries = args[:entries]
        
        case value
        when Fixnum
          if value < 0
            RelativeArgument.orig_new value, entries: entries
          else
            FixnumArgument.orig_new value
          end
        when String
          if SVN_ARGUMENT_WORDS.include? value
            StringArgument.orig_new value
          elsif md = RELATIVE_REVISION_RE.match(value)
            RelativeArgument.orig_new md[0].to_i, entries: entries
          elsif DATE_REGEXP.match value
            StringArgument.orig_new value
          else
            FixnumArgument.orig_new value.to_i
          end
        when Symbol
          raise RevisionError.new "symbol not yet handled"
        when Date
          # $$$ this (and Time) will probably have to be converted to svn's format
          raise RevisionError.new "date not yet handled"
        when Time
          raise RevisionError.new "time not yet handled"
        end          
      end

      def matches_relative? str
        RELATIVE_REVISION_RE.match str
      end
    end

    def initialize value
      @value = value
    end

    def to_s
      @value.to_s
    end

    def <=> other
      @value <=> other.value
    end
  end

  class FixnumArgument < Argument
  end

  class StringArgument < Argument
  end

  class WorkingCopyArgument < Argument
  end

  # this is of the form -3, which is revision[-3] (second one from the most
  # recent; -1 is the most recent).
  class RelativeArgument < FixnumArgument
    def initialize value, args
      entries = args[:entries]
      
      unless entries
        raise RevisionError.new "cannot determine relative revision without entries"
      end
      
      nentries = entries.size

      # logentries are in descending order, so the most recent one is index 0

      if value.abs > nentries
        raise RevisionError.new "ERROR: no entry for revision: #{value.abs}; number of entries: #{nentries}"
      else
        idx = value < 0 ? -1 + value.abs : nentries - value
        log_entry = entries[idx]
        super log_entry.revision.to_i
      end
    end
  end
end