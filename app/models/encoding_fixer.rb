# Simple Module for fixing strings that were bogusly converted on input. We really need to address root prob
module EncodingFixer
  def fix_encoding(input)
    string = input.dup
    @fixes = {
      'Ã€' => 'À',
      'Ã' => 'Á',
      'Ã‚' => 'Â',
      'Ãƒ' => 'Ã',
      'Ã„' => 'Ä',
      'Ã…' => 'Å',
      'Ã†' => 'Æ',
      'Ã‡' => 'Ç',
      'Ãˆ' => 'È',
      'Ã‰' => 'É',
      'ÃŠ' => 'Ê',
      'Ã‹' => 'Ë',
      'ÃŒ' => 'Ì',
      # 'Ã' => 'Í', # unrecoverable duplicate
      'ÃŽ' => 'Î',
      # 'Ã' => 'Ï', # unrecoverable duplicate
      # 'Ã' => 'Ð', # unrecoverable duplicate
      'Ã‘' => 'Ñ',
      'Ã’' => 'Ò',
      'Ã“' => 'Ó',
      'Ã”' => 'Ô',
      'Ã•' => 'Õ',
      'Ã–' => 'Ö',
      'Ã—' => '×',
      'Ã˜' => 'Ø',
      'Ã™' => 'Ù',
      'Ãš' => 'Ú',
      'Ã›' => 'Û',
      'Ãœ' => 'Ü',
      # 'Ã' => 'Ý', # unrecoverable duplicate
      'Ãž' => 'Þ',
      'ÃŸ' => 'ß',
      # 'Ã' => 'à', # unrecoverable duplicate
      'Ã¡' => 'á',
      'Ã¢' => 'â',
      'Ã£' => 'ã',
      'Ã¤' => 'ä',
      'Ã¥' => 'å',
      'Ã¦' => 'æ',
      'Ã§' => 'ç',
      'Ã¨' => 'è',
      'Ã©' => 'é',
      'Ãª' => 'ê',
      'Ã«' => 'ë',
      'Ã¬' => 'ì',
      'Ã­' => 'í',
      'Ã®' => 'î',
      'Ã¯' => 'ï',
      'Ã°' => 'ð',
      'Ã±' => 'ñ',
      'Ã²' => 'ò',
      'Ã³' => 'ó',
      'Ã´' => 'ô',
      'Ãµ' => 'õ',
      'Ã¶' => 'ö',
      'Ã·' => '÷',
      'Ã¸' => 'ø',
      'Ã¹' => 'ù',
      'Ãº' => 'ú',
      'Ã»' => 'û',
      'Ã¼' => 'ü',
      'Ã½' => 'ý',
      'Ã¾' => 'þ',
      'Ã¿' => 'ÿ'
    }
    @fixes.each do |from, to|
      string.gsub!(from, to)
    end
    string
  end
end
