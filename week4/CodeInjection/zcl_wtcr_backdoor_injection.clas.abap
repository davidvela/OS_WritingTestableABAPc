CLASS zcl_wtcr_backdoor_injection DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor.

    METHODS get_amount_in_coins
      IMPORTING i_amount       TYPE i
      RETURNING VALUE(r_value) TYPE i.
    METHODS get_amount_in_notes
      IMPORTING i_amount       TYPE i
      RETURNING VALUE(r_value) TYPE i.

  PRIVATE SECTION.
    DATA m_cash_provider TYPE REF TO zif_wtcr_cash_provider. "back door injection
ENDCLASS.



CLASS ZCL_WTCR_BACKDOOR_INJECTION IMPLEMENTATION.


  METHOD constructor.
    m_cash_provider = NEW zcl_wtcr_cash_provider( ). "back door injection
  ENDMETHOD.


  METHOD get_amount_in_coins.
    DATA(notes) = m_cash_provider->get_notes( i_currency = 'EUR' ).
    SORT notes BY amount ASCENDING.

    r_value = COND #( WHEN i_amount <= 0
                      THEN -1
                      ELSE i_amount MOD notes[ 1 ]-amount ).
  ENDMETHOD.


  METHOD get_amount_in_notes.
    r_value = i_amount - get_amount_in_coins( i_amount ).
  ENDMETHOD.
ENDCLASS.
