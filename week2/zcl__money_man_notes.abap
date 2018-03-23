*> Using TDD - Test Driven Development ... 
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
    METHODS amount4_note0   FOR TESTING   RAISING cx_static_check. 
    METHODS amount29_note25 FOR TESTING   RAISING cx_static_check.
    METHODS amount29_coin4  FOR TESTING   RAISING cx_static_check.
    "EXERCISE
    METHODS get_change_for_amount IMPORTING am type tt_change exp_am type tt_change.
    METHODS get_change_for_amount_minus11   FOR TESTING   RAISING cx_static_check. 
    METHODS get_change_for_amount_0   FOR TESTING   RAISING cx_static_check. 
ENDCLASS. 
    cl_abap_unit_assert=>assert_equals( act = m_cut->get_change( 1 )
                                        exp = VALUE zcl_wtcr_money_machine=>tt_change(
                                                ( amount = 1   type = 'coin' ) ) ).
CLASS ltc_get_amount IMPLEMENTATION. 
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
*> new
    METHOD amount4_note0. 
        DATA(note_amount) = m_cut->ltc_get_amount_in_notes( 4 ).
        cl_abap_unit_assert=>asser_equals( act = note_amount exp = 0 ). 
    ENDMETHOD. 
    METHOD amount29_note25. 
        DATA(note_amount) = m_cut->ltc_get_amount_in_notes( 29 ).
        cl_abap_unit_assert=>asser_equals( act = note_amount exp = 25 ). 
    ENDMETHOD. 
    METHOD amount29_coin4.
        DATA(coin_amount) = m_cut->ltc_get_amount_in_coins( 29 ).         
        cl_abap_unit_assert=>asser_equals( act = coin_amount exp = 4 ). 
    ENDMETHOD.
*> Exercise 2..................
    METHOD get_change_for_amount.
        cl_abap_unit_assert=>assert_equals( act = am   exp = exp_am  ).  
    ENDMETHOD.
    METHOD get_change_for_amount2.
        cl_abap_unit_assert=>assert_equals( act = am   exp = exp_am  ).  
    ENDMETHOD.


    METHOD get_change_for_amount_minus_11.
        cl_abap_unit_assert=>assert_initial( m_cut->get_change( -11 ) ).
    ENDMETHOD.
    METHOD get_change_for_amount_0.
        cl_abap_unit_assert=>assert_initial( m_cut->get_change( 0 ) ).
    ENDMETHOD.
    " 1 
    METHOD get_change_for_amount_1.
        cl_abap_unit_assert=>assert_equals( act = m_cut->get_change( 1 )
                                        exp = VALUE zcl_wtcr_money_machine=>tt_change(
                                                ( amount = 1   type = 'coin' ) ) ).
    ENDMETHOD.
    " 2 
    METHOD get_change_for_amount_2.
        get_change_for_amount_2( am = m_cut->get_change( 1 )
                 exp_am = VALUE  ( amount = 2  type = 'coin' ) ) ).
    ENDMETHOD.
    " 3 
    METHOD get_change_for_amount_3.
        cl_abap_unit_assert=>assert_equals( act = m_cut->get_change( 1 )
                                        exp = VALUE zcl_wtcr_money_machine=>tt_change(
                                                ( amount = 2   type = 'coin' )
                                                ( amount = 1   type = 'coin' ) ) ).
    ENDMETHOD.
    " 4 
    METHOD get_change_for_amount_4.
        cl_abap_unit_assert=>assert_equals( act = m_cut->get_change( 4 )
                                        exp = VALUE zcl_wtcr_money_machine=>tt_change(
                                                ( amount = 2   type = 'coin' )
                                                ( amount = 2   type = 'coin' ) ) ).
    ENDMETHOD.
    " 5 
    METHOD get_change_for_amount_5.
        cl_abap_unit_assert=>assert_equals( act = m_cut->get_change( 1 )
                                        exp = VALUE zcl_wtcr_money_machine=>tt_change(
                                                ( amount = 5   type = 'note' ) ) ).
    ENDMETHOD.
    " 8 
    METHOD get_change_for_amount_5.
        cl_abap_unit_assert=>assert_equals( act = m_cut->get_change( 1 )
                                        exp = VALUE zcl_wtcr_money_machine=>tt_change(
                                                ( amount = 5   type = 'note' ) ) ).
    ENDMETHOD.
     " 10 
    METHOD get_change_for_amount_5.
        cl_abap_unit_assert=>assert_equals( act = m_cut->get_change( 1 )
                                        exp = VALUE zcl_wtcr_money_machine=>tt_change(
                                                ( amount = 5   type = 'note' ) ) ).
    ENDMETHOD.
    " 15 
    METHOD get_change_for_amount_5.
        cl_abap_unit_assert=>assert_equals( act = m_cut->get_change( 1 )
                                        exp = VALUE zcl_wtcr_money_machine=>tt_change(
                                                ( amount = 5   type = 'note' ) ) ).
    ENDMETHOD.
    " 20 
    METHOD get_change_for_amount_5.
        cl_abap_unit_assert=>assert_equals( act = m_cut->get_change( 1 )
                                        exp = VALUE zcl_wtcr_money_machine=>tt_change(
                                                ( amount = 5   type = 'note' ) ) ).
    ENDMETHOD.
        " 5 
    METHOD get_change_for_amount_5.
        cl_abap_unit_assert=>assert_equals( act = m_cut->get_change( 1 )
                                        exp = VALUE zcl_wtcr_money_machine=>tt_change(
                                                ( amount = 5   type = 'note' ) ) ).
    ENDMETHOD.
        " 5 
    METHOD get_change_for_amount_5.
        cl_abap_unit_assert=>assert_equals( act = m_cut->get_change( 1 )
                                        exp = VALUE zcl_wtcr_money_machine=>tt_change(
                                                ( amount = 5   type = 'note' ) ) ).
    ENDMETHOD.
        " 5 
    METHOD get_change_for_amount_5.
        cl_abap_unit_assert=>assert_equals( act = m_cut->get_change( 1 )
                                        exp = VALUE zcl_wtcr_money_machine=>tt_change(
                                                ( amount = 5   type = 'note' ) ) ).
    ENDMETHOD.
        " 5 
    METHOD get_change_for_amount_5.
        cl_abap_unit_assert=>assert_equals( act = m_cut->get_change( 1 )
                                        exp = VALUE zcl_wtcr_money_machine=>tt_change(
                                                ( amount = 5   type = 'note' ) ) ).
    ENDMETHOD.
ENDCLASS. 