#
# Copyright 2014 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name "dep-selector-libgecode"
default_version "1.0.2"

dependency "rubygems"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # On some RHEL-based systems, the default GCC that's installed is 4.1. We
  # need to use 4.4, which is provided by the gcc44 and gcc44-c++ packages.
  # These do not use the gcc binaries so we set the flags to point to the
  # correct version here.
  if File.exist?("/usr/bin/gcc44")
    env["CC"]  = "gcc44"
    env["CXX"] = "g++44"
  end

  # Ruby DevKit ships with BSD Tar
  env["PROG_TAR"] = "bsdtar" if windows?

  gem "install dep-selector-libgecode" \
      " --version '#{version}'" \
      " --no-ri --no-rdoc", env: env

  if windows?
    block "Clean up large object files" do
      # find the embedded rubygems dir and clean it up for globbing
      gem_dir = "#{install_dir}/embedded/lib/ruby/gems/*/gems".gsub(/\\/, '/')

      # find all the static *.a files in the dep-selector-libgecode gem(s)
      # we don't use and delete them
      Dir.glob("#{gem_dir}/dep-selector-libgecode*/**/*.a").each do |f|
        puts "Deleting #{f}"
        File.delete(f)
      end
    end
  end
end
