#!/usr/bin/env ruby

require "test/unit"
require "../lib/sheet"

class TestSheet < Test::Unit::TestCase

  def test_sample
    sheet = Sheet.new(3, 2)
    sheet.input_cell(0, 0, "A2")
    sheet.input_cell(0, 1, "4 5 *")
    sheet.input_cell(0, 2, "A1")
    sheet.input_cell(1, 0, "A1 B2 / 2 +")
    sheet.input_cell(1, 1, "3")
    sheet.input_cell(1, 2, "39 B1 B2 * /")

    assert_equal(true, sheet.calculate())

    assert_equal(20.0, sheet.get_cell_val(0,0))
    assert_equal(20.0, sheet.get_cell_val(0,1))
    assert_equal(20.0, sheet.get_cell_val(0,2))
    assert_equal((20.0 / 3 + 2), sheet.get_cell_val(1,0))
    assert_equal(3.0, sheet.get_cell_val(1,1))
    assert_equal(1.5, sheet.get_cell_val(1,2).round(5))

  end
end
