CLASS zcl_wtcr_depend_lookup DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS get_amount_in_coins
      IMPORTING i_amount       TYPE i
      RETURNING VALUE(r_value) TYPE i.
    METHODS get_amount_in_notes
      IMPORTING i_amount       TYPE i
      RETURNING VALUE(r_value) TYPE i.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_WTCR_DEPEND_LOOKUP IMPLEMENTATION.

  METHOD get_amount_in_coins.
    DATA(notes) = zcl_wtcr_factory=>cash_provider( )->get_notes( i_currency = 'EUR' ). "dependency lookup
    SORT notes BY amount ASCENDING.

    r_value = COND #( WHEN i_amount <= 0
                      THEN -1
                      ELSE i_amount MOD notes[ 1 ]-amount ).
  ENDMETHOD.


  METHOD get_amount_in_notes.
    r_value = get_amount_in_coins( i_amount ).
    IF r_value >= 0.
      r_value = i_amount - r_value.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
