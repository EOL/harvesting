module Exceptions
  class ColumnMismatch < StandardError ; end
  class ColumnMissing < StandardError ; end
  class ColumnEmpty < StandardError ; end
  class ColumnUnmatched < StandardError ; end
  class ColumnNonInteger < StandardError ; end
  class ColumnUnknownUri < StandardError ; end
end
