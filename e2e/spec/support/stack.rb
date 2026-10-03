require "bundler"
require "fileutils"
require "socket"
require "timeout"

# Starts the API and UI if they are not already listening, and stops whatever it
# started. Mirrors running `bin/rails server` and `npm run dev` by hand.
module Stack
  ROOT = File.expand_path("../../..", __dir__)
  FRONTEND_URL = ENV.fetch("E2E_FRONTEND_URL", "http://127.0.0.1:5173")
  BACKEND_URL  = ENV.fetch("E2E_BACKEND_URL", "http://127.0.0.1:8000")

  BACKEND_PORT  = URI.parse(BACKEND_URL).port
  FRONTEND_PORT = URI.parse(FRONTEND_URL).port

  class << self
    def start
      @pids = []
      start_backend unless port_open?(BACKEND_PORT)
      start_frontend unless port_open?(FRONTEND_PORT)

      wait_for_port(BACKEND_PORT)
      wait_for_port(FRONTEND_PORT)
    end

    def stop
      Array(@pids).each do |pid|
        # Vite and Rails both spawn children, so signal the whole process group.
        Process.kill("TERM", -pid)
      rescue Errno::ESRCH
        next
      end

      Array(@pids).each do |pid|
        Timeout.timeout(10) { Process.wait(pid) }
      rescue Timeout::Error, Errno::ECHILD, Errno::ESRCH
        next
      end

      @pids = []
    end

    private

    # This suite has its own Gemfile. with_original_env undoes what `bundle exec`
    # set here, so the backend resolves its own bundle, while leaving any gem
    # paths the surrounding environment configured intact.
    def child_env(extra = {})
      original = Bundler.with_original_env { ENV.to_h }
      removed = (ENV.to_h.keys - original.keys).to_h { |key| [ key, nil ] }

      original.merge(removed).merge(extra)
    end

    def backend_env
      # SQLite keeps the suite free of a database service.
      child_env("DB_ENGINE" => "sqlite", "RAILS_ENV" => "development")
    end

    def start_backend
      backend = File.join(ROOT, "backend")

      system(backend_env, "bin/rails", "db:prepare", chdir: backend, exception: true)

      @pids << spawn(
        backend_env,
        "bin/rails", "server", "-b", "127.0.0.1", "-p", BACKEND_PORT.to_s,
        chdir: backend, pgroup: true, **log_to("backend")
      )
    end

    def start_frontend
      @pids << spawn(
        child_env,
        "npm", "run", "dev", "--",
        "--host", "127.0.0.1", "--port", FRONTEND_PORT.to_s, "--strictPort",
        chdir: File.join(ROOT, "frontend"), pgroup: true, **log_to("frontend")
      )
    end

    # Server chatter goes to log/ so it does not drown out the spec output.
    def log_to(name)
      dir = File.join(__dir__, "../../log")
      FileUtils.mkdir_p(dir)
      path = File.join(dir, "#{name}.log")

      { out: path, err: [ :child, :out ] }
    end

    def port_open?(port, host = "127.0.0.1")
      Socket.tcp(host, port, connect_timeout: 0.25, &:close)
      true
    rescue StandardError
      false
    end

    def wait_for_port(port, timeout: 120)
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout

      until port_open?(port)
        if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
          raise "Timed out waiting for 127.0.0.1:#{port}"
        end

        sleep 0.25
      end
    end
  end
end
