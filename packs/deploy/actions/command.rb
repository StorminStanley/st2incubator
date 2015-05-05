#!/usr/bin/env ruby
##
## StackStorm Pack Branch Deployment Script
##
## This script is designed to allow branch deployments
## of packs, from a variety of upstream sources.
##
require 'fileutils'
require 'optparse'
require 'json'
require 'socket'

module Deploy
  class Pack
    E_GENERICERROR=127
    attr_reader :pack, :branch, :subtree, :basedir, :options, :command, :first_run

    def initialize(options)
      @repo = options[:repo]
      @pack = options[:pack]
      @branch = options[:branch]
      @basedir = options[:basedir]
      @options = options
      @first_run = Dir.exists?(pack_dir) ? false : true

      setup
      eval_command(options)
      eval_subtree(options)

      debug "[#initialize] Repo: #{repo}, Pack: #{pack}, Ref: #{branch}, Subtree: #{subtree}"
    end

    def repo
      @repo.split('/').size.eql?(2) ? "https://github.com/#{@repo}" : @repo
    end

    def eval_command(options)
      @command = if options[:info] && !options[:delete]
        :info
      elsif options[:delete] && !options[:info]
        :delete
      else
        :run
      end
    end

    def eval_subtree(options)
      if state.has_key?('subtree')
        @subtree = state['subtree']
      else
        # Try and do the user a favor, and automatically compute subtree if it wasn't
        # explicitly set. This is to account for the packs that are in a monolithic repo
        # and need to be pulled out. Specifically, st2contrib and st2incubator
        match = repo.index(/[sS]tack[sS]torm\/st2(contrib|incubator)/) ? true : false

        # XOR match to user input and match parameters
        @subtree = match ^ options[:subtree]
        state['subtree'] = @subtree
      end
      debug "[#eval_subtree] Subtree: #{subtree}, state: #{state['subtree']}"
    end

    def setup
      [vcs_dir, packs_dir].each do |d|
        unless Dir.exists?(d)
          debug "[#setup] Creating directory #{d}"
          FileUtils.mkdir_p(d)
        end
      end
    end

    def cmds_available?(cmds)
      Array(cmds).each do |cmd|
        exist = `sh -c 'command -v #{cmd}'`.size.>(0)
        unless exist
          bail("command missing: #{cmd}")
        end
      end
    end

    def bail(message, code=E_GENERICERROR)
      log message
      exit code
    end

    def packs_dir
      File.join(basedir, 'packs')
    end

    def pack_dir
      File.join(packs_dir, pack)
    end

    def vcs_dir
      File.join(basedir, 'vcs')
    end

    def vcs_file
      File.join(pack_dir, '.vcs')
    end

    def pack_vcs_dir
      File.join(vcs_dir, pack)
    end

    def pack_vcs_dir_exists?
      File.directory? pack_vcs_dir
    end

    def clone_pack
      options[:first_clone] = true
      exec "git clone #{repo} #{pack_vcs_dir}"
      state['upstream'] = repo
    end

    def checkout_branch
      Dir.chdir pack_vcs_dir
      exec 'git fetch --all'
      exec "git reset --hard origin/#{branch}"
      state['branch'] = branch
      state['ref'] = `git rev-list -1 HEAD`.chomp
    end

    def sync_pack(args={})
      dry_opts = args[:dry_run] ? '--dry-run' : nil
      src_dir = subtree ? File.join(pack_vcs_dir, 'packs', pack) : pack_vcs_dir
      debug "[#sync_pack] subtree: #{subtree} src_dir: #{src_dir}"
      cmd = ['rsync', '-avz', dry_opts, '--delete',
             '--exclude=.git', '--exclude=config.txt', '--exclude=.vcs',
             src_dir, packs_dir
      ]

      exec cmd.join(' ')
    end

    def save_state
      File.open(vcs_file, 'w') { |f| f.write(state.to_json) }
    end

    def state
      begin
        @state ||= File.open(vcs_file, 'r') { |f| JSON.load(f) }
      rescue
        @state ||= {'branch' => nil, 'ref' => nil}
      end
    end

    def reload_st2
      exec 'st2ctl reload --register-all'
    end

    def log(message, extra={})
      puts "{#{Socket.gethostname}} #{message}"
    end

    def exec(cmd)
      debug "[exec] Running: #{cmd}"
      debug `#{cmd}`
    end

    def debug(message)
      puts message if options[:debug]
      return message
    end

    def dirty_tree?
      Dir.chdir pack_vcs_dir
      `git status -s 2> /dev/null`.size.>(0) ? true : false
    end

    def current_branch
      Dir.chdir pack_vcs_dir
      return "branch: #{state['branch']}, ref: #{state['ref']}, upstream: #{state['upstream']}"
    end

    def branch_exists?
      Dir.chdir pack_vcs_dir
      `git ls-remote --heads`.include?(branch)
    end

    # Determine if the running directory is in sync with the vcs repository.
    # Used in the event some editing has happened in the pack directly
    def nsync?
      sync = sync_pack(:dry_run => true)
      sync =~ /#{pack_vcs_dir}/ ? false : true
    end

    ### Control Functions
    def cmd_info
      cmds_available? ['git', 'rsync']
      if nsync? && !dirty_tree?
        log "in-sync and clean. #{current_branch}"
      elsif dirty_tree?
        log "Dirty git tree! Take a look at #{pack_vcs_dir}. #{current_branch}"
      end
    end

    def cmd_run
      cmds_available? ['git', 'rsync', 'st2ctl']

      clone_pack unless pack_vcs_dir_exists?

      if !dirty_tree? && branch_exists?
        checkout_branch
      elsif !branch_exists?
        bail "Git branch does not exist upstream. #{branch}"
      elsif dirty_tree?
        bail "Git tree is dirty. Will not proceed until reviewed in #{pack_vcs_dir}"
      end

      if nsync?
        sync_pack
      else
        bail "Hand-edited files exist in #{packs_dir}. Check on them and then re-run"
      end

      save_state
      reload_st2
      cmd_info
    end

    def cmd_delete
      if pack_vcs_dir_exists? && options[:force]
        [pack_dir, pack_vcs_dir].each do |dir|
          debug "[cmd_delete] #{FileUtils.rm_rf(dir)}"
        end
        log 'OK'
      else
        bail 'Must use "force" if you really mean this'
      end
    end

    ### CLI Runner
    def self.run(options)
      i = self.new(options)
      i.send("cmd_#{i.command.to_s}")
    end
  end
end

# Shell Application Scaffolding
options = Hash.new
optparse = OptionParser.new do |opts|
  options[:info] = false
  opts.on('-i', '--info', 'Gather info on pack deployment (version, clean)') do
    options[:info] = true
  end

  options[:pack] = nil
  opts.on('-p', '--pack PACK', 'Pack to install/manage') do |pack|
    options[:pack] = pack
  end

  options[:branch] = 'master'
  opts.on('-r', '--branch BRANCH', 'Git branch to switch pack to') do |branch|
    options[:branch] = branch
  end

  options[:repo] = 'https://github.com/StackStorm/st2contrib'
  opts.on('-u', '--repo REPO', 'Git repositiory to clone pack from') do |repo|
    options[:repo] = repo
  end

  options[:basedir] = '/opt/stackstorm'
  opts.on('-b', '--basedir DIR', 'Base directory where StackStorm packs are installed') do |basedir|
    options[:basedir] = basedir
  end

  options[:subtree] = false
  opts.on('-s', '--subtree', 'Pack is installed in subtree packs/$PACK of repo') do
    options[:subtree] = true
  end

  options[:force] = false
  opts.on('-f', '--force', 'Force destructive actions') do
    options[:force] = true
  end

  options[:delete] = false
  opts.on('-x', '--delete', 'Delete installation of a pack') do
    options[:delete] = true
  end

  options[:debug] = false
  opts.on('-d', '--debug', 'Enable debug output') do
    options[:debug] = true
  end

  opts.on('-h', '--help', 'Display this screen') { puts opts; exit }
end

begin
  optparse.parse!
  mandatory = [:pack, :repo, :basedir]
  missing = mandatory.select{ |param| options[param].nil? }
  unless missing.empty?
    puts "Missing options: #{missing.join(', ')}"
    puts optparse
    exit
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end

Deploy::Pack.run(options)
