#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entries'
require 'svnx/revision/error'
require 'logue/loggable'
require 'svnx/revision/argfactory'

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
      def create value, args = Hash.new
        ArgumentFactory.new.create value, args
      end

      alias_method :orig_new, :new

      def new value, args = Hash.new
        ArgumentFactory.new.create value, args
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

  class IndexArgument < Argument
  end

  class StringArgument < Argument
  end

  # this is of the form -3, which is revision[-3] (second one from the most
  # recent; -1 is the most recent).
  class RelativeArgument < IndexArgument
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
        idx = value < 0 ? value.abs - 1 : nentries - value
        log_entry = entries[idx]
        super log_entry.revision.to_i
      end
    end
  end
end
