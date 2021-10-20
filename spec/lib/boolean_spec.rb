# frozen_string_literal: true

RSpec.describe ::Boolean do
  subject(:boolean) { described_class.new }

  describe 'casts' do
    it 'true to true' do
      expect(boolean.cast(true)).to be true
    end

    it '1 to true' do
      expect(boolean.cast(1)).to be true
    end

    it '"1" to true' do
      expect(boolean.cast('1')).to be true
    end

    it '"t" to true' do
      expect(boolean.cast('t')).to be true
    end

    it '"T" to true' do
      expect(boolean.cast('T')).to be true
    end

    it '"true" to true' do
      expect(boolean.cast('true')).to be true
    end

    it '"TRUE" to true' do
      expect(boolean.cast('TRUE')).to be true
    end

    it '"on" to true' do
      expect(boolean.cast('on')).to be true
    end

    it '"ON" to true' do
      expect(boolean.cast('ON')).to be true
    end

    it '" " to true' do
      expect(boolean.cast(' ')).to be true
    end

    it '"\u3000\r\n" to true' do
      expect(boolean.cast("\u3000\r\n")).to be true
    end

    it '"\u0000" to true' do
      expect(boolean.cast("\u0000")).to be true
    end

    it '"SOMETHING RANDOM" to true' do
      expect(boolean.cast('SOMETHING RANDOM')).to be true
    end

    it ':"1" to true' do
      expect(boolean.cast(:'1')).to be true
    end

    it ':t to true' do
      expect(boolean.cast(:t)).to be true
    end

    it ':T to true' do
      expect(boolean.cast(:T)).to be true
    end

    it ':true to true' do
      # rubocop:disable Lint/BooleanSymbol
      expect(boolean.cast(:true)).to be true
      # rubocop:enable Lint/BooleanSymbol
    end

    it ':TRUE to true' do
      expect(boolean.cast(:TRUE)).to be true
    end

    it ':on to true' do
      expect(boolean.cast(:on)).to be true
    end

    it ':ON to true' do
      expect(boolean.cast(:ON)).to be true
    end

    it 'empty string to false' do
      expect(boolean.cast('')).to be false
    end

    it 'nil to false' do
      expect(boolean.cast(nil)).to be false
    end

    it 'false to false' do
      expect(boolean.cast(false)).to be false
    end

    it '0 to false' do
      expect(boolean.cast(0)).to be false
    end

    it '"0" to false' do
      expect(boolean.cast('0')).to be false
    end

    it '"f" to false' do
      expect(boolean.cast('f')).to be false
    end

    it '"F" to false' do
      expect(boolean.cast('F')).to be false
    end

    it '"false" to false' do
      expect(boolean.cast('false')).to be false
    end

    it '"FALSE" to false' do
      expect(boolean.cast('FALSE')).to be false
    end

    it '"off" to false' do
      expect(boolean.cast('off')).to be false
    end

    it '"OFF" to false' do
      expect(boolean.cast('OFF')).to be false
    end

    it ':"0" to false' do
      expect(boolean.cast(:'0')).to be false
    end

    it ':f to false' do
      expect(boolean.cast(:f)).to be false
    end

    it ':F to false' do
      expect(boolean.cast(:F)).to be false
    end

    it ':false to false' do
      # rubocop:disable Lint/BooleanSymbol
      expect(boolean.cast(:false)).to be false
      # rubocop:enable Lint/BooleanSymbol
    end

    it ':FALSE to false' do
      expect(boolean.cast(:FALSE)).to be false
    end

    it ':off to false' do
      expect(boolean.cast(:off)).to be false
    end

    it ':OFF to false' do
      expect(boolean.cast(:OFF)).to be false
    end
  end
end
