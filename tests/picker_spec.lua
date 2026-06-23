local assert = require("luassert")

describe("window-picker", function()
  local window_picker

  before_each(function()
    -- Reload module for each test
    package.loaded["window-picker"] = nil
    package.loaded["window-picker.config"] = nil
    package.loaded["window-picker.picker"] = nil
    window_picker = require("window-picker")
  end)

  describe("setup", function()
    it("should work with default options", function()
      assert.has_no.errors(function()
        window_picker.setup()
      end)
    end)

    it("should accept custom labels", function()
      assert.has_no.errors(function()
        window_picker.setup({
          labels = "12345",
        })
      end)
    end)

    it("should accept custom float options", function()
      assert.has_no.errors(function()
        window_picker.setup({
          float = {
            border = "single",
            highlight = "TestHighlight",
          },
        })
      end)
    end)
  end)

  describe("pick", function()
    it("should not error with single window", function()
      window_picker.setup()
      assert.has_no.errors(function()
        window_picker.pick()
      end)
    end)
  end)
end)
