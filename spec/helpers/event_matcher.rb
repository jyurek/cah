RSpec::Matchers.define :have_received_event do |expected|
  expected_name = expected[0]
  expected_data = expected[1]

  match do |actual|
    actual_name = actual[0]
    actual_data = actual[1]

    actual_name == expected_name && actual_name == expected_data
  end
end
