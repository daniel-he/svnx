#!/usr/bin/ruby -w
# -*- ruby -*-

require 'system/command/arg'
require 'logue/loggable'
require 'open3'
require 'rainbow'

module System
  class CommandLine
    include Logue::Loggable

    attr_reader :output

    def initialize args = Array.new
      @args = args.dup
    end

    def << arg
      # @args << Argument.new(arg)
      @args << arg
    end

    def execute
      cmd = to_command

      info "cmd: #{cmd}".color("8A8A43")

      # cmd << " 2>&1"

      # I want to use popen3, but the version that works (sets $?) is in 1.9.x,
      # not 1.8.x:
      IO.popen(cmd + " 2>&1") do |io|
        @output = io.readlines
      end

      if $? && $?.exitstatus != 0
        info "cmd: #{cmd}".color(:red)
        info "$?: #{$?.inspect}".color(:red)
        info "$?.exitstatus: #{$? && $?.exitstatus}".color(:red)
        raise "ERROR running command '#{cmd}': #{@output[-1]}"
      end

      @output
    end

    def to_command
      @args.join ' '
    end
  end
end
