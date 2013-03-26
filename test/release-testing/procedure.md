Manual Testing Procedure
=========================

Where this library is to be manually tested the following procedure is
as follows:
* The different sections of the spec should be divided amongst the
  available testers. Each section of the spec should be tested by at
  least two different testers.
* Each tester should test their sections on at least two different
  browsers.
* Testing should be conducted in two runs
  - The first with any logging facilities[^1] open. All errors should be
    noted.
  - The second with all logging facilities turned off. This must not
    produce any errors.

Browsers to be tested:
* Webkit: chrome, safari, ios, android, opera (new)
* Gecko: Firefox
* IE 8+
* Presto: opera (old)

  [^1]: Dev tools in webkit, firebug in firefox, developer tools in
        IE, dragonfly in opera.
