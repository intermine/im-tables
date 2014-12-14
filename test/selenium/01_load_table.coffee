wd = require 'selenium-webdriver'
assert = require 'assert'
test = require 'selenium-webdriver/testing'
firefox = require 'selenium-webdriver/firefox'

{By} = wd

test.describe 'Load table', ->
  test.it 'should work', ->

    driver = new firefox.Driver

    driver.get 'http://localhost:9001/demo'

    locator = By.css '.im-table-summary'
    driver.wait(wd.until.elementsLocated locator)
          .then -> driver.findElement locator
          .then (el) -> el.getText()
          .then (text) -> assert.equal 'Foo', text

    driver.quit()
