CLASS zcl_wtcr_re_rebate_reason DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS add_clause
      IMPORTING
        i_text TYPE string.
    METHODS get_text
      RETURNING
        VALUE(r_text) TYPE string.
    METHODS remove_last_clause.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA m_texts TYPE standard table of string.
ENDCLASS.



CLASS ZCL_WTCR_RE_REBATE_REASON IMPLEMENTATION.


  METHOD add_clause.
    APPEND i_text TO m_texts.
  ENDMETHOD.


  METHOD get_text.
    LOOP AT m_texts INTO DATA(text).
      IF r_text IS INITIAL.
        r_text = text.
      ELSE.
        r_text = r_text && ` and ` && text.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD remove_last_clause.
    IF m_texts IS NOT INITIAL.
      DATA(last_clause_index) = lines( m_texts ).
      DELETE m_texts INDEX last_clause_index.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
