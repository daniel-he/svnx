#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rexml/document'
require 'logue/loggable'

module SVNx
  # this is a parse/process on-demand list of entries, acting like an
  # Enumerable.

  class Entries
    include Logue::Loggable, Enumerable

    attr_reader :size

    def initialize args = Hash.new
      # it's a hash, but indexed with integers, for non-sequential access:
      @entries = Hash.new

      if xmllines = args[:xmllines]
        if xmllines.kind_of? Array
          xmllines = xmllines.join ''
        end

        doc = REXML::Document.new xmllines

        @elements = get_elements doc
        @size = @elements.size
      elsif args[:xmlentries]
        raise "argument xmlentries is no longer supported"
      end
    end

    def get_elements doc
      raise "get_elements must be implemented for: #{self.class}"
    end

    def create_entry xmlelement
      raise "create_entry must be implemented for: #{self.class}"
    end

    # this doesn't handle negative indices
    def [] idx
      if entry = @entries[idx]
        return entry
      end
      if idx < 0 && idx >= size
        raise "error: index #{idx} is not in range(0 .. #{size})"
      end
      @entries[idx] = create_entry(@elements[idx + 1])
    end

    def each(&blk)
      # all elements must be processed before each can run:
      if @elements
        # a little confusing here: REXML does each_with_index with idx
        # zero-based, but elements[0] is invalid.
        @elements.each_with_index do |element, idx|
          @entries[idx] ||= create_entry(element)
        end

        @elements = nil
      end

      @entries.keys.sort.collect { |idx| @entries[idx] }.each(&blk)
    end
  end
end
