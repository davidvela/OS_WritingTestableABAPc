CLASS zcl_wtcr_roman_converter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS to_arabic
      IMPORTING
        i_roman_numeral TYPE string
      RETURNING
        VALUE(r_arabic) TYPE i.
    CONSTANTS error_value TYPE i VALUE -1.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS value_of_roman_digit
      IMPORTING
        i_roman_numeral_digit TYPE char1
      RETURNING
        VALUE(r_arabic)       TYPE i.
ENDCLASS.



CLASS ZCL_WTCR_ROMAN_CONVERTER IMPLEMENTATION.


  METHOD to_arabic.
    DATA:
      offset              TYPE i,
      current_digit       TYPE char1,
      previous_digit      TYPE char1,
      roman               TYPE string,
      value_of_prev_digit TYPE i,
      value_of_cur_digit  TYPE i.

* Rules for correct syntax (in addition to simple chars):
* - larger symbols before smaller ones
* - additive: max 3 in a row
* - subtractive: only one; valid cases: I before X, X before L|C, C before D|M
* Added specific error handling checks

    offset = 0.
    value_of_prev_digit = 0.
    roman = i_roman_numeral.
    TRANSLATE roman TO UPPER CASE.

    DO strlen( roman ) TIMES.
      offset = sy-index - 1.
      previous_digit = current_digit.
      value_of_prev_digit = value_of_cur_digit.
      current_digit = roman+offset(1).
      value_of_cur_digit = value_of_roman_digit( current_digit ).
      IF value_of_cur_digit = error_value.        "-- illegal character?
        r_arabic = error_value.
        EXIT.
      ENDIF.

      r_arabic = r_arabic + value_of_cur_digit.
      IF value_of_prev_digit > 0 AND value_of_prev_digit < value_of_cur_digit.
        "-- subtractive case
        r_arabic = r_arabic - 2 * value_of_prev_digit.    "-- subtract = compensate for previous add
        " CHECK: valid cases: I before X, X before L|C, C before D|M
        CASE current_digit.
          WHEN 'X' OR 'V'. IF previous_digit NE 'I'. r_arabic = error_value. EXIT. ENDIF.
          WHEN 'L' OR 'C'. IF previous_digit NE 'X'. r_arabic = error_value. EXIT. ENDIF.
          WHEN 'D' OR 'M'. IF previous_digit NE 'C'. r_arabic = error_value. EXIT. ENDIF.
        ENDCASE.
      ELSE.
        "-- additive case; larger symbol before smaller already checked
        " CHECK: no more than 3 in a row = check if char at lv_offset-3 is the same
        DATA lv_check_offset TYPE i.
        lv_check_offset = offset - 3.
        IF lv_check_offset >= 0 AND current_digit = roman+lv_check_offset(1).
          r_arabic = error_value.
          EXIT.
        ENDIF.

      ENDIF.

    ENDDO.

  ENDMETHOD.  "to_arabic


  METHOD value_of_roman_digit.
    CASE i_roman_numeral_digit.
      WHEN 'I'. r_arabic = 1.
      WHEN 'V'. r_arabic = 5.
      WHEN 'X'. r_arabic = 10.
      WHEN 'L'. r_arabic = 50.
      WHEN 'C'. r_arabic = 100.
      WHEN 'D'. r_arabic = 500.
      WHEN 'M'. r_arabic = 1000.
      WHEN OTHERS.  r_arabic = error_value.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
