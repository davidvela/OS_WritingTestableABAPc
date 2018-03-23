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
  methods GET_AMOUNT_IN_COINS  importing   !I_AMOUNT type I  returning   value(R_VALUE) type I .
  methods GET_AMOUNT_IN_NOTES  importing   !I_AMOUNT type I  returning   value(R_VALUE) type I .
  methods get_change           importing   !I_AMOUNT type I  returning   value(R_VALUE) type tty_change .
  PROTECTED SECTION.  PRIVATE SECTION.
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
        append value( amount = lf_notes type = 'note' ) to r_value.
      endif. 

    endwhile. 


  ENDMETHOD.


ENDCLASS.
