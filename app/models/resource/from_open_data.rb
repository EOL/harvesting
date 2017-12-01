class Resource
  class FromOpenData
    def initialize(url)
      # E.g.: https://opendata.eol.org/dataset/univ-alberta-museums/resource/6575df9b-3a60-4ed1-bea3-3c558a826509
      @url = url
    end

    def parse
      # YOU WERE HERE ... grab the open code from eol_web, use kaminari to parse it, look for .breadcrumb and find the
      # penultimate LI; go there to get info about the partner, then grab the first "p a" (roughly), download it, unzip
      # it... etc. Make sure there can only be one file on this page, though. ...I think so.
    end
  end
end
