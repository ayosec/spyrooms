
module Colors

  def black(str)
    "\033[0;30m#{str}\033[m"
  end

  def red(str)
    "\033[0;31m#{str}\033[m"
  end

  def green(str)
    "\033[0;32m#{str}\033[m"
  end

  def yellow(str)
    "\033[0;33m#{str}\033[m"
  end

  def blue(str)
    "\033[0;34m#{str}\033[m"
  end

  def magenta(str)
    "\033[0;35m#{str}\033[m"
  end

  def cyan(str)
    "\033[0;36m#{str}\033[m"
  end

  def white(str)
    "\033[0;37m#{str}\033[m"
  end


end
