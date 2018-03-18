" Roman numerals spec: http://en.wikipedia.org/wiki/Roman_numerals
"
CLASS ltc_to_arabic DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA m_roman_converter TYPE REF TO zcl_wtcr_roman_converter.

    METHODS setup.

    METHODS assert_convert
      IMPORTING i_roman  TYPE string
                i_arabic TYPE i.
    METHODS assert_error
      IMPORTING i_roman TYPE string.

    METHODS verify_single FOR TESTING.
    METHODS verify_additive FOR TESTING.
    METHODS verify_subtractive FOR TESTING.
    METHODS verify_complex FOR TESTING.
    METHODS error_cases FOR TESTING.

ENDCLASS.


CLASS ltc_to_arabic IMPLEMENTATION.

  METHOD setup.
    CREATE OBJECT m_roman_converter.
  ENDMETHOD.

  METHOD assert_convert.
    cl_abap_unit_assert=>assert_equals( exp = i_arabic
                                        act = m_roman_converter->to_arabic( i_roman ) ).
  ENDMETHOD.

  METHOD assert_error.
    cl_abap_unit_assert=>assert_equals( exp = zcl_wtcr_roman_converter=>error_value
                                        act = m_roman_converter->to_arabic( i_roman ) ).
  ENDMETHOD.

  METHOD verify_single.
    assert_convert( i_roman = ''  i_arabic = 0 ).
    assert_convert( i_roman = 'I' i_arabic = 1 ).
    assert_convert( i_roman = 'V' i_arabic = 5 ).
    assert_convert( i_roman = 'X' i_arabic = 10 ).
    assert_convert( i_roman = 'L' i_arabic = 50 ).
    assert_convert( i_roman = 'C' i_arabic = 100 ).
    assert_convert( i_roman = 'D' i_arabic = 500 ).
    assert_convert( i_roman = 'M' i_arabic = 1000 ).
  ENDMETHOD.

  METHOD verify_additive.
    assert_convert( i_roman = 'II' i_arabic = 2 ).
    assert_convert( i_roman = 'XX' i_arabic = 20 ).
    assert_convert( i_roman = 'XV' i_arabic = 15 ).
    assert_convert( i_roman = 'MM' i_arabic = 2000 ).
    assert_convert( i_roman = 'III' i_arabic = 3 ).
  ENDMETHOD.

  METHOD verify_subtractive.
    assert_convert( i_roman = 'IX' i_arabic = 9 ).
    assert_convert( i_roman = 'XC' i_arabic = 90 ).
    assert_convert( i_roman = 'CM' i_arabic = 900 ).
  ENDMETHOD.

  METHOD verify_complex.
    assert_convert( i_roman = 'XIV' i_arabic = 14 ).
    assert_convert( i_roman = 'CMXL' i_arabic = 940 ).
    assert_convert( i_roman = 'CMXLIII' i_arabic = 943 ).
    assert_convert( i_roman = 'MCMXLVII' i_arabic = 1947 ).
  ENDMETHOD.

  METHOD error_cases.
    assert_error( i_roman = 'A' ).     "-- invalid character
    assert_error( i_roman = 'ABC' ).   "-- invalid characters
    assert_error( i_roman = 'IIII').   "-- more than 3
    assert_error( i_roman = 'MCXXXXI').   "-- more than 3 inside
    assert_error( i_roman = 'MIC').    "-- I only before X and V
  ENDMETHOD.
ENDCLASS.
