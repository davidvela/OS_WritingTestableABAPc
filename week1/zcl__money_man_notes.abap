CLASS ltc_get_amount_in_coins DEFINITION FOR TESTING
  RISK LEVEL HARMLESS 
  DURATION SHORT.      " risk level also:  DANGEROUS; CRITICAL 

    PRIVATE SECTION. 
    "! Amount of 1 euro results in 1 euro coin 
    METHOD amount1_coin1 FOR TESTING. "method name limit = 30char 
   "! Amount of 2 euro results in 2 euro coin 
    METHOD amount2_coin2 FOR TESTING. 
ENDCLASS. 

CLASS ltc_get_amount_in_coins IMPLEMENTATION. 
    METHOD amount1_coin1. 
        " given 
        DATA(cut) = NEW cl_money_machine( ). 
        " when 
        DATA(coin_amount) = cut->ltc_get_amount_in_coins( 1 ).         
        " then 
        cl_abap_unit_assert=>asser_equals( act = coin_amount exp = 1 ). 
    ENDMETHOD.
    METHOD amount2_coin2.
        DATA(cut) = NEW cl_money_machine( ). 
        DATA(coin_amount) = cut->ltc_get_amount_in_coins( 2 ).         
        cl_abap_unit_assert=>asser_equals( act = coin_amount exp = 2 ). 
    ENDMETHOD.
ENDCLASS. 

" spetial methods: CLASS_SETUP, SETUP, TEARDOWN, CLASS_TEARDOWN, 

CLASS ltc_get_amount_in_coins2 DEFINITION FOR TESTING
  RISK LEVEL HARMLESS 
  DURATION SHORT.      " risk level also:  DANGEROUS; CRITICAL 

    PRIVATE SECTION. 
    DATA m_cut TYPE REF TO cl_money_machine. "member variable

    METHODS SETUP. 
    "! Amount of 1 euro results in 1 euro coin 
    METHODS amount1_coin1 FOR TESTING. 
   "! Amount of 2 euro results in 2 euro coin 
    METHODS amount2_coin2 FOR TESTING. 
ENDCLASS. 

CLASS ltc_get_amount_in_coins IMPLEMENTATION. 
    METHOD setup. 
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