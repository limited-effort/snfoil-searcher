# frozen_string_literal: true

# Copyright 2021 Matthew Howes

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
      attr_reader :i_model, :i_setup, :i_filters, :i_search_step, :i_booleans

      def model(klass = nil)
        raise SnFoil::Searcher::Error, "model already defined for #{self.class.name}" if @i_model

        @i_model = klass
      end

      def setup(setup_method = nil, &setup_block)
        raise SnFoil::Searcher::Error, "setup already defined for #{self.class.name}" if @i_setup

        @i_setup = setup_method || setup_block
      end

      def filter(method = nil, **options, &block)
        raise SnFoil::Searcher::ArgumentError, 'filter requires either a method name or a block' if method.nil? && block.nil?

        (@i_filters ||= []) << {
          method: method,
          block: block,
          if: options[:if],
          unless: options[:unless]
        }
      end

      def booleans(*fields)
        @i_booleans ||= []
        @i_booleans |= fields.map(&:to_sym)
      end
    end

    def model
      self.class.i_model
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
      self.class.i_setup
    end

    def filters
      self.class.i_filters || []
    end

    def booleans
      self.class.i_booleans || []
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
      params.map do |key, value|
        value = if booleans.include?(key.to_sym)
                  value_to_boolean(value)
                else
                  value
                end
        [key, value]
      end.to_h
    end

    def value_to_boolean(value)
      value = false if value == '' || value.nil?
      falses = [false, 0, '0', :'0', 'f', :f, 'F', :F, 'false', :false, 'FALSE', :FALSE, 'off', :off, 'OFF', :OFF].to_set.freeze # rubocop:disable Lint/BooleanSymbol

      !falses.include?(value)
    end
  end
end
