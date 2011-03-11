#
# Author:: Christopher Walters (<cw@opscode.com>)
# Author:: Mark Anderson (<mark@opscode.com>)
# Copyright:: Copyright (c) 2010-2011 Opscode, Inc.
# License:: Apache License, Version 2.0
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

require 'dep_selector/package'
require 'dep_selector/gecode_wrapper'

# DependencyGraphs contain Packages, which in turn contain
# PackageVersions. Packages are created at access-time through
# #package
module DepSelector
  class DependencyGraph

    attr_reader :packages

    def initialize
      @packages = {}
    end

    def package(name)
      packages.has_key?(name) ? packages[name] : (packages[name]=Package.new(self, name))
    end

    def each_package
      packages.each do |name, pkg|
        yield pkg
      end
    end

    def gecode_wrapper
      raise "Must invoke generate_gecode_wrapper_constraints before attempting to access gecode_wrapper" unless @gecode_wrapper
      @gecode_wrapper
    end

    # Note: only invoke this method once all Packages and
    # PackageVersions have been added.
    def generate_gecode_wrapper_constraints(packages_to_include_in_solve=nil)
      unless @gecode_wrapper
        packages_in_solve =
          if packages_to_include_in_solve
            packages_to_include_in_solve
          else
            packages.map{ |name, pkg| pkg }
          end

        # In addition to all the packages that the user specified,
        # there is a "ghost" package that contains the solution
        # constraints. See Selector#solve for more information.
        @gecode_wrapper = GecodeWrapper.new(packages_in_solve.size + 1)
        packages_in_solve.each{ |pkg| pkg.generate_gecode_wrapper_constraints }
      end
    end

    def gecode_model_vars
      packages.inject({}){|acc, elt| acc[elt.first] = elt.last.gecode_model_var ; acc }
    end

    def to_s(incl_densely_packed_versions = false)
      packages.keys.sort.map{|name| packages[name].to_s(incl_densely_packed_versions)}.join("\n")
    end

    # TODO [cw,2010/11/23]: this is a simple but inefficient impl. Do
    # it for realz.
    def clone
      Marshal.load(Marshal.dump(self))
    end
  end
end
