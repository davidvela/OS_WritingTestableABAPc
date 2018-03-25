TYPES:  BEGIN OF ty_change, 
                    amount  type i, 
                    type    type string, 
        END OF ty_change, 

        tty_change  type standard table of ty_change with default key.

class ZCL_WTC_MONEY_MACHINE definition
  public
  final
  create public .
  public section.
    methods constructor.
    methods GET_AMOUNT_IN_COINS  importing   !I_AMOUNT type I  returning   value(R_VALUE)  type I .
    methods GET_AMOUNT_IN_NOTES  importing   !I_AMOUNT type I  returning   value(R_VALUE)  type I .
    methods get_change           importing   !I_AMOUNT type I  returning   value(R_change) type tty_change .
  PROTECTED SECTION.  
  PRIVATE SECTION.
    DATA m_ordered_amounts TYPE tt_change.
ENDCLASS.

CLASS ZCL_WTC_MONEY_MACHINE IMPLEMENTATION.
  METHOD get_amount_in_coins.
    r_value = COND #( WHEN i_amount <= 0
                      THEN -1
                      ELSE i_amount MOD 5 ).
  ENDMETHOD.

  METHOD get_amount_in_notes.
    r_value = i_amount - get_amount_in_coins( i_amount ).
  ENDMETHOD.

  METHOD get_change( ) .
    data: lf_notes    type i, 
          lf_cois     type i, 
          lf_amount   type i. 
    lf_amount = i_amount.

    lf_notes = lf_amount.  
    while lf_notes GT 0.
      lf_notes = get_amount_in_notes(lf_amount).
      if lf_notes <> 0. 
        append value( amount = lf_notes type = 'note' ) to R_change.
      endif. 
    endwhile. 
  ENDMETHOD.


* Sol: 
  METHOD constructor.
    m_ordered_amounts = VALUE #(
      ( amount = 500 type = 'note' )
      ( amount = 200 type = 'note' )
      ( amount = 100 type = 'note' )
      ( amount = 50  type = 'note' )
      ( amount = 20  type = 'note' )
      ( amount = 10  type = 'note' )
      ( amount = 5   type = 'note' )
      ( amount = 2   type = 'coin' )
      ( amount = 1   type = 'coin' )
    ).
  ENDMETHOD.
  METHOD get_change.
    DATA(remaining_amount) = i_amount.
    WHILE remaining_amount > 0.
      LOOP AT m_ordered_amounts INTO DATA(amount).
        IF remaining_amount >= amount-amount.
          APPEND amount TO r_change.
          SUBTRACT amount-amount FROM remaining_amount.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
