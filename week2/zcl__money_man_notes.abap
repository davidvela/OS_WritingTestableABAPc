*> Using TDD - Test Development ... 
*> -- to implement a new feautre: get_amount_in_notes
*           Steps: rename class, 
CLASS ltc_get_amount DEFINITION FOR TESTING
  RISK LEVEL HARMLESS 
  DURATION SHORT.      " risk level also:  DANGEROUS; CRITICAL 

    PRIVATE SECTION. 
    DATA m_cut TYPE REF TO cl_money_machine. "member variable

    METHODS SETUP. 
    METHODS amount1_coin1 FOR TESTING. 
    METHODS amount2_coin2 FOR TESTING. 
    "NEW
    METHODS amount4_note0 FOR TESTING. 
ENDCLASS. 

CLASS ltc_get_amount IMPLEMENTATION. 
    METHOD amount1_coin1. 
        m_cut = NEW cl_money_machine( ). 
    ENDMETHOD. 
    METHOD amount1_coin1. 
        DATA(coin_amount) = m_cut->ltc_get_amount_in_coins( 1 ).         
        cl_abap_unit_assert=>asser_equals( act = coin_amount exp = 1 ). 
    ENDMETHOD.
    METHOD amount2_coin2.
        DATA(coin_amount) = m_cut->ltc_get_amount_in_coins( 2 ).         
        cl_abap_unit_assert=>asser_equals( act = coin_amount exp = 2 ). 
    ENDMETHOD.


    
ENDCLASS. 