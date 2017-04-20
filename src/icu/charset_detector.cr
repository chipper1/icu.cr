# not thread-safe
class ICU::CharsetDetector
  class CharsetMatch
    getter name : String
    getter language : String
    getter confidence : Int32

    def initialize(csmatch : LibICU::UCharsetMatch)
      ustatus = uninitialized LibICU::UErrorCode

      name = LibICU.ucsdet_get_name(csmatch, pointerof(ustatus))
      ICU.check_error!(ustatus)
      @name = String.new(name)

      language = LibICU.ucsdet_get_language(csmatch, pointerof(ustatus))
      ICU.check_error!(ustatus)
      @language = String.new(language)

      @confidence = LibICU.ucsdet_get_confidence(csmatch, pointerof(ustatus))
      ICU.check_error!(ustatus)
    end
  end

  @csdet : LibICU::UCharsetDetector

  def initialize
    ustatus = uninitialized LibICU::UErrorCode
    @csdet = LibICU.ucsdet_open(pointerof(ustatus))
    ICU.check_error!(ustatus)
  end

  def finalize
    @csdet.try { |csdet| LibICU.ucsdet_close(csdet) }
  end

  def detect(text : String) : CharsetMatch
    ustatus = uninitialized LibICU::UErrorCode

    LibICU.ucsdet_set_text(@csdet, text, text.size, pointerof(ustatus))
    ICU.check_error!(ustatus)

    ucsmatch = LibICU.ucsdet_detect(@csdet, pointerof(ustatus))
    ICU.check_error!(ustatus)

    CharsetMatch.new(ucsmatch.not_nil!)
  end

  def detect_all(text : String) : Array(CharsetMatch)
    ustatus = uninitialized LibICU::UErrorCode

    LibICU.ucsdet_set_text(@csdet, text, text.size, pointerof(ustatus))
    ICU.check_error!(ustatus)

    ucsmatchs = LibICU.ucsdet_detect_all(@csdet, out num, pointerof(ustatus))
    ICU.check_error!(ustatus)

    Slice(LibICU::UCharsetMatch).new(ucsmatchs, num).map do |ucsmatch|
      CharsetMatch.new(ucsmatch.not_nil!)
    end
  end
end
