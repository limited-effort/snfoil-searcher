# frozen_string_literal: true

# Copyright 2021 Matthew Howes, Cliff Campbell

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#   http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'active_support/concern'
require_relative 'searcher/boolean'

module SnFoil
  #
  #
  # @author Matthew Howes
  #
  # @since 0.1.0
  module Searcher
    class Error < RuntimeError; end

    class ArgumentError < ArgumentError; end

    extend ActiveSupport::Concern

    class_methods do
      attr_reader :snfoil_model, :snfoil_setup, :snfoil_filters, :snfoil_booleans

      def model(klass = nil)
        raise SnFoil::Searcher::Error, "model already defined for #{self.class.name}" if @snfoil_model

        @snfoil_model = klass
      end

      def setup(setup_method = nil, &setup_block)
        raise SnFoil::Searcher::Error, "setup already defined for #{self.class.name}" if @snfoil_setup

        @snfoil_setup = setup_method || setup_block
      end

      def filter(method = nil, **options, &block)
        raise SnFoil::Searcher::ArgumentError, 'filter requires either a method name or a block' if method.nil? && block.nil?

        (@snfoil_filters ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
      end

      def booleans(*fields)
        @snfoil_booleans ||= []
        @snfoil_booleans |= fields.map(&:to_sym)
      end

      def inherited(subclass)
        super

        instance_variables.grep(/@snfoil_.+/).each do |i|
          subclass.instance_variable_set(i, instance_variable_get(i).dup)
        end
      end
    end

    def model
      self.class.snfoil_model
    end

    attr_reader :scope

    def initialize(scope: nil)
      raise SnFoil::Searcher::Error, "No default scope or model configured for #{self.class.name}" if !scope && !model

      @scope = scope || model.all
    end

    def search(params = {})
      params = transform_params_booleans(params) # this is required for params coming in from http-like sources
      filtered_scope = filter || scope # start usimg the default scope of the class or the filter method
      filtered_scope = apply_setup(filtered_scope, params)
      apply_filters(filtered_scope, params)
    end

    def filter; end

    def setup
      self.class.snfoil_setup
    end

    def filters
      self.class.snfoil_filters || []
    end

    def booleans
      self.class.snfoil_booleans || []
    end

    private

    def apply_setup(filtered_scope, params)
      return filtered_scope if setup.nil?

      if setup.is_a?(Symbol) || setup.is_a?(String)
        send(setup, filtered_scope, params)
      else
        instance_exec filtered_scope, params, &setup
      end
    end

    def apply_filters(filtered_scope, params)
      filters&.reduce(filtered_scope) do |i_scope, i_filter|
        apply_filter(i_filter, i_scope, params)
      end
    end

    def apply_filter(i_filter, filtered_scope, params)
      return filtered_scope unless filter_valid?(i_filter, params)

      return send(i_filter[:method], filtered_scope, params) if i_filter[:method]

      instance_exec filtered_scope, params, &i_filter[:block]
    end

    def filter_valid?(i_filter, params)
      return false if !i_filter[:if].nil? && !i_filter[:if].call(params)
      return false if !i_filter[:unless].nil? && i_filter[:unless].call(params)

      true
    end

    def transform_params_booleans(params)
      params.to_h do |key, value|
        value = if booleans.include?(key.to_sym)
                  SnFoil::Searcher::Boolean.new.cast(value)
                else
                  value
                end
        [key, value]
      end
    end
  end
end
