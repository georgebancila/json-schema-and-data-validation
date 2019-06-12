# frozen_string_literal: true

module JsonUtilities
  module_function

  def verify_last_response_schema(json_response_file, args = {})
    raw_response = File.read(SHARED_DIR.join(json_response_file))
    expected_response = format(raw_response, args)
    result = JsonUtilities.check_json_equality(JSON.parse(last_body), JSON.parse(expected_response))
    expect(result).to be true
  end

  def check_json_equality(response, expected, required_values = {})
    required_values = required_values.map { |_key, value| value }
    check_json_equality_recursive(response, expected, required_values)
  end

  # rubocop:disable AbcSize, CyclomaticComplexity, PerceivedComplexity, MethodLength
  def check_json_equality_recursive(response, expected, required_values = {})
    result = false

    if response.is_a?(Array)
      return false unless expected.length == response.length

      result = true

      response.each_with_index do |obj, index|
        response_obj = obj
        expected_obj = expected[index]
        result = if response_obj.is_a?(Array) || response_obj.is_a?(Hash)
                   check_json_equality_recursive(response_obj, expected_obj, required_values)
                 elsif value_requested?(expected_obj, required_values)
                   check_values(response_obj, expected_obj)
                 else
                   true
                 end

        unless result
          puts "response: #{response_obj}, expected: #{expected_obj}"
          break
        end
      end
    elsif response.is_a?(Hash)
      return false unless response.keys.length == expected.keys.length

      response.each do |key, value|
        return false unless expected.key?(key)

        response_val = value
        expected_val = expected[key]
        result = if response_val.is_a?(Array) || response_val.is_a?(Hash)
                   check_json_equality_recursive(response_val, expected_val, required_values)
                 elsif value_requested?(expected_val, required_values)
                   check_values(response_val, expected_val)
                 else
                   true
                 end

        unless result
          puts "response: #{response_val}, expected: #{expected_val}"
          break
        end
      end
    end

    result
  end
  # rubocop:enable AbcSize, CyclomaticComplexity, PerceivedComplexity, MethodLength

  def value_requested?(expected_val, required_values = {})
    required_values.include?(expected_val)
  end

  def check_values(response_val, expected_combined_val)
    expected_arr = expected_combined_val.split(':')
    expected_val = expected_arr.slice(1, expected_arr.length - 1).join

    result = response_val.to_s == expected_val
    result
  end
end
