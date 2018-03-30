**********************************************************************
*****   Testing base class features                     **************
**********************************************************************
* We test through the ID_NUM rule since the base class is abstract

CLASS ltc_rule_base_checks DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS:
      active_default         FOR TESTING,
      active_from            FOR TESTING,
      active_to              FOR TESTING,
      item_rule_not_active   FOR TESTING,
      cart_rule_not_active   FOR TESTING,
      invalid_empty_effect   FOR TESTING,
      only_percent_or_amount FOR TESTING,
      percent_and_amount_gt_zero FOR TESTING.
    DATA:
      "-- we use items_id since the base class is abstract
      m_rebate_result TYPE zase_shop_rebate_result,
      m_rule          TYPE REF TO zcl_wtcr_re_rule_item_id.
ENDCLASS.

CLASS ltc_rule_base_checks IMPLEMENTATION.

  METHOD active_default.
    CREATE OBJECT m_rule
      EXPORTING
        i_rule_name = 'active default'.
    cl_abap_unit_assert=>assert_true( m_rule->is_active( sy-datum ) ).
  ENDMETHOD.

  METHOD active_from.
    DATA date TYPE d.

    date = sy-datum.
    CREATE OBJECT m_rule
      EXPORTING
        i_rule_name  = 'active default - from'
        i_valid_from = date.
    cl_abap_unit_assert=>assert_true( m_rule->is_active( sy-datum ) ).

    date = sy-datum + 1.
    CREATE OBJECT m_rule
      EXPORTING
        i_rule_name  = 'active default - from'
        i_valid_from = date.
    cl_abap_unit_assert=>assert_false( m_rule->is_active( sy-datum ) ).
  ENDMETHOD.

  METHOD active_to.
    DATA d1 TYPE d.

    d1 = sy-datum.
    CREATE OBJECT m_rule
      EXPORTING
        i_rule_name = 'active default - to'
        i_valid_to  = d1.
    cl_abap_unit_assert=>assert_true( m_rule->is_active( sy-datum ) ).

    d1 = sy-datum - 1.
    CREATE OBJECT m_rule
      EXPORTING
        i_rule_name = 'active default - to'
        i_valid_to  = d1.
    cl_abap_unit_assert=>assert_false( m_rule->is_active( sy-datum ) ).
  ENDMETHOD.


  METHOD invalid_empty_effect.
    CREATE OBJECT m_rule
      EXPORTING
        i_rule_name = 'dummy_rule'.

    TRY.
        "Effect must have either percent or amount off
        m_rule->set_effect(
*           i_percent    =
*           i_amount_off =
            i_apply_to   = zcl_wtcr_re_rule_base=>apply_to_all_items
        ).
      CATCH zcx_wtcr_shop_config_error INTO DATA(shop_config_error).
    ENDTRY.

    cl_abap_unit_assert=>assert_bound( shop_config_error ).
  ENDMETHOD.

  METHOD only_percent_or_amount.
    CREATE OBJECT m_rule
      EXPORTING
        i_rule_name = 'dummy_rule'.

    TRY.
        "Effect must have either percent or amount off
        m_rule->set_effect(
            i_percent_off    = 10
            i_amount_off = 20
            i_apply_to    = zcl_wtcr_re_rule_base=>apply_to_all_items
        ).
      CATCH zcx_wtcr_shop_config_error INTO DATA(shop_config_error).
    ENDTRY.

    cl_abap_unit_assert=>assert_bound( shop_config_error ).
  ENDMETHOD.

  METHOD percent_and_amount_gt_zero.
    CREATE OBJECT m_rule
      EXPORTING
        i_rule_name = 'dummy_rule'.

    TRY.
        m_rule->set_effect(
            i_percent_off    = '-3'
            i_amount_off = 0
            i_apply_to    = zcl_wtcr_re_rule_base=>apply_to_all_items
        ).
      CATCH zcx_wtcr_shop_config_error INTO DATA(shop_config_error).
    ENDTRY.

    cl_abap_unit_assert=>assert_bound( shop_config_error ).
  ENDMETHOD.

  METHOD item_rule_not_active.
    CREATE OBJECT m_rule
      EXPORTING
        i_rule_name  = 'dummy'
        i_valid_from = sy-datum
        i_valid_to   = sy-datum.

    DATA(rebate_engine) = NEW zcl_wtcr_rebate_engine( ).
    rebate_engine->add_item_rule( m_rule ).

    DATA(cart) = VALUE zase_shop_cart( ).
    m_rebate_result = rebate_engine->compute_rebate(
      EXPORTING
        i_date       = '20010101'
      CHANGING
        c_cart_items = cart
    ).
    cl_abap_unit_assert=>assert_initial( m_rebate_result-total_rebate ).
  ENDMETHOD.

  METHOD cart_rule_not_active.
    DATA(cart_total_rule) = NEW zcl_wtcr_re_rule_cart_total(
      i_rule_name  = 'dummy'
      i_valid_from = sy-datum
      i_valid_to   = sy-datum
    ).

    DATA(rebate_engine) = NEW zcl_wtcr_rebate_engine( ).
    rebate_engine->add_cart_rule( cart_total_rule ).

    DATA(cart) = VALUE zase_shop_cart( ).
    m_rebate_result = rebate_engine->compute_rebate(
      EXPORTING
        i_date       = '20010101'
      CHANGING
        c_cart_items = cart
    ).
    cl_abap_unit_assert=>assert_initial( m_rebate_result-total_rebate ).
  ENDMETHOD.

ENDCLASS.



**********************************************************************
****** Testing rule that triggers on <id, num>           *************
**********************************************************************

CLASS ltc_id_num_one_rule_simple DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  "-- testing cases "number of items", scope = item

  PRIVATE SECTION.
    DATA:
      m_rule   TYPE REF TO zcl_wtcr_re_rule_item_id,
      cart     TYPE zase_shop_cart,
      out_cart TYPE zase_shop_cart.

    METHODS:
      setup,
      id_1_percent_apply_1   FOR TESTING,
      id_1_percent_apply_all FOR TESTING,
      id_2_percent_apply_1 FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltc_id_num_one_rule_simple IMPLEMENTATION.

  METHOD setup.
    CREATE OBJECT m_rule EXPORTING i_rule_name = 'dummy'.
  ENDMETHOD.


  METHOD id_1_percent_apply_1.
    cart = VALUE #( ( id = '1' quantity = 2 standard_price = '10.00' )
                    ( id = '2' quantity = 3 standard_price = '0.00'  )
                  ).

    m_rule->set_trigger(
        i_required_item_id  = 1
        i_required_quantity = 2 ).
    m_rule->set_effect(
        i_percent_off = 100
        i_apply_to    = zcl_wtcr_re_rule_base=>apply_to_1_item ).

    out_cart = m_rule->apply( i_cart = cart ).

    cl_abap_unit_assert=>assert_equals( exp = '10.00' act = out_cart[ 1 ]-rebate_amount ).
  ENDMETHOD.


  METHOD id_1_percent_apply_all.
    cart = VALUE #( ( id = '1' quantity = 2 standard_price = '10.00' )
                    ( id = '2' quantity = 3 standard_price = '20.00' )
                  ).
    m_rule->set_trigger(
        i_required_item_id  = 1
        i_required_quantity = 2 ).
    m_rule->set_effect(
        i_percent_off = 50
        i_apply_to    = zcl_wtcr_re_rule_base=>apply_to_all_items ).

    out_cart = m_rule->apply( i_cart = cart ).

    cl_abap_unit_assert=>assert_equals( exp = '10.00' act = out_cart[ 1 ]-rebate_amount ).
  ENDMETHOD.

  METHOD id_2_percent_apply_1.
    cart = VALUE #( ( id = '1' quantity = 2 standard_price = '10.00' )
                    ( id = '2' quantity = 3 standard_price = '20.00' )
                  ).

    m_rule->set_trigger(
        i_required_item_id  = 2
        i_required_quantity = 2 ).
    m_rule->set_effect(
        i_percent_off = 100
        i_apply_to    = zcl_wtcr_re_rule_base=>apply_to_1_item ).

    out_cart = m_rule->apply( i_cart = cart ).

    cl_abap_unit_assert=>assert_equals( exp = '20.00' act = out_cart[ 2 ]-rebate_amount ).
  ENDMETHOD.

ENDCLASS.



**********************************************************************
CLASS ltc_id_num_one_rule DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA:
      m_rule TYPE REF TO zcl_wtcr_re_rule_item_id,
      m_cart TYPE zase_shop_cart.

    CLASS-DATA:
      at_1   TYPE string,
      at_all TYPE string.

    METHODS:
      setup,

      run_case_and_assert IMPORTING
                            i_required_id              TYPE zase_shop_item_id
                            i_required_number_of_items TYPE zase_shop_item_quantity
                            i_percent                  TYPE i OPTIONAL
                            i_amount_off               TYPE f OPTIONAL
                            i_apply_to                 TYPE zcl_wtcr_re_rule_base=>t_apply_to
                            i_expected_rebate_amount   TYPE f,

      add_rebates
        IMPORTING
          i_cart       TYPE zase_shop_cart
        RETURNING
          VALUE(r_sum) TYPE zase_shop_item_standard_total,

      second_item_3_req_amount_off FOR TESTING,
      first_item_with_amount_off  FOR TESTING,
      rebate_reason_for_item_id   FOR TESTING,
      no_rebate_reason_when_no_disc FOR TESTING,
      second_item_with_percent_off FOR TESTING ,
      second_item_with_3_percent_off FOR TESTING ,
      second_item_no_rebate_percent FOR TESTING ,
      second_item_with_amount_off FOR TESTING ,
      second_item_4_req_no_reb FOR TESTING ,
      multi_hit_item_1 FOR TESTING ,
      multi_hit_item_2 FOR TESTING ,
      apply_to_all_6 FOR TESTING ,
      apply_to_all_4 FOR TESTING .
ENDCLASS.

**********************************************************************
CLASS ltc_id_num_one_rule IMPLEMENTATION.

  METHOD setup.
    CREATE OBJECT m_rule EXPORTING i_rule_name = 'item_rebate'.

    at_1   = zcl_wtcr_re_rule_base=>apply_to_1_item.
    at_all = zcl_wtcr_re_rule_base=>apply_to_all_items.
  ENDMETHOD.

  METHOD run_case_and_assert.
    DATA: total_rebate TYPE zase_shop_item_standard_total.

    m_rule->set_trigger(
        i_required_item_id  = i_required_id
        i_required_quantity = i_required_number_of_items ).

    m_rule->set_effect(
        i_percent_off = i_percent
        i_amount_off  = i_amount_off
        i_apply_to    = i_apply_to ).

    m_cart = m_rule->apply(  i_cart = m_cart ).

    total_rebate = add_rebates( m_cart ).

    cl_abap_unit_assert=>assert_equals( exp = i_expected_rebate_amount act = total_rebate ).
  ENDMETHOD.

  METHOD add_rebates.
    FIELD-SYMBOLS: <item> TYPE zase_shop_cart_item.
    LOOP AT i_cart ASSIGNING <item>.
      r_sum = r_sum + <item>-rebate_amount.
    ENDLOOP.
  ENDMETHOD.


  METHOD second_item_with_percent_off.
    m_cart = VALUE #( ( id = '1' quantity = 2 standard_price = '10.00' )
                      ( id = '2' quantity = 3 standard_price = '20.00' )
                  ).
    run_case_and_assert(
        i_required_id              = '2'
        i_required_number_of_items = 2
        i_percent                  = 50
        i_apply_to                 = at_1
        i_expected_rebate_amount   = '10.00' ).
  ENDMETHOD.

  METHOD second_item_with_3_percent_off.
    m_cart = VALUE #( ( id = '1' quantity = 2 standard_price = '10.00' )
                      ( id = '2' quantity = 3 standard_price = '20.00' )
                    ).
    "-- item 2, 3 required OK
    run_case_and_assert(
        i_required_id              = '2'
        i_required_number_of_items = 3
        i_percent                  = 50
        i_apply_to                 = at_1
        i_expected_rebate_amount   = '10.00' ).
  ENDMETHOD.

  METHOD second_item_no_rebate_percent.
    m_cart = VALUE #( ( id = '1' quantity = 2 standard_price = '10.00' )
                      ( id = '2' quantity = 3 standard_price = '20.00' )
                    ).
    "-- item 3, 4 required, no rebate
    run_case_and_assert(
        i_required_id              = '2'
        i_required_number_of_items = 4
        i_percent                  = 50
        i_apply_to                 = at_1
        i_expected_rebate_amount   = '0.00' ).
  ENDMETHOD.

  METHOD first_item_with_amount_off.
    m_cart = VALUE #( ( id = '1' quantity = 2 standard_price = '10.00' )
                      ( id = '2' quantity = 3 standard_price = '20.00' )
                    ).
    "-- hit item 1
    run_case_and_assert(
        i_required_id              = '1'
        i_required_number_of_items = 2
        i_amount_off               = 5
        i_apply_to                 = at_1
        i_expected_rebate_amount   = '5.00' ).
  ENDMETHOD.

  METHOD second_item_with_amount_off.
    m_cart = VALUE #( ( id = '1' quantity = 2 standard_price = '10.00' )
                      ( id = '2' quantity = 3 standard_price = '20.00' )
                  ).
    "-- hit item 2
    run_case_and_assert(
        i_required_id              = '2'
        i_required_number_of_items = 2
        i_amount_off               = 10
        i_apply_to                 = at_1
        i_expected_rebate_amount   = '10.00' ).
  ENDMETHOD.

  METHOD second_item_3_req_amount_off.
    m_cart = VALUE #( ( id = '1' quantity = 2 standard_price = '10.00' )
                      ( id = '2' quantity = 3 standard_price = '20.00' )
                    ).
    "-- item 2, 3 required OK
    run_case_and_assert(
        i_required_id              = '2'
        i_required_number_of_items = 3
        i_amount_off               = 10
        i_apply_to                 = at_1
        i_expected_rebate_amount   = '10.00' ).
  ENDMETHOD.

  METHOD second_item_4_req_no_reb.
    m_cart = VALUE #( ( id = '1' quantity = 2 standard_price = '10.00' )
                      ( id = '2' quantity = 3 standard_price = '20.00' )
                    ).
    "-- item 3, 4 required, no rebate
    run_case_and_assert(
        i_required_id              = '2'
        i_required_number_of_items = 4
        i_amount_off               = 10
        i_apply_to                 = at_1
        i_expected_rebate_amount   = '0.00' ).
  ENDMETHOD.


  METHOD multi_hit_item_1.
    m_cart = VALUE #( ( id = '1' quantity = 7 standard_price = '10.00' )
                      ( id = '2' quantity = 5 standard_price = '20.00' )
                    ).
    "-- multiple hits in one item e.g. 2 x 2-for-1; make sure the count of processed items works
    "-- hit item 1, 3 reductions
    run_case_and_assert(
        i_required_id              = '1'
        i_required_number_of_items = 2
        i_percent                  = 50
        i_apply_to                 = at_1
        i_expected_rebate_amount   = '15.00' ).
  ENDMETHOD.


  METHOD multi_hit_item_2.
    m_cart = VALUE #( ( id = '1' quantity = 7 standard_price = '10.00' )
                      ( id = '2' quantity = 5 standard_price = '20.00' )
                    ).
    "-- hit item 2, 2 reductions
    run_case_and_assert(
        i_required_id              = '2'
        i_required_number_of_items = 2
        i_amount_off               = 10
        i_apply_to                 = at_1
        i_expected_rebate_amount   = '20.00' ).
  ENDMETHOD.


  METHOD apply_to_all_6.
    m_cart = VALUE #( ( id = '1' quantity = 7 standard_price = '10.00' )
                      ( id = '2' quantity = 5 standard_price = '20.00' )
                    ).
    "-- semantics of 'apply_to_all': the reduction is applied to all items
    "-- covered by the reduction rule

    "-- hit item 1, 3 reductions, 50% reduction applied to ALL 6 items covered by rule
    run_case_and_assert(
        i_required_id              = '1'
        i_required_number_of_items = 2
        i_percent                  = 50
        i_apply_to                 = at_all
        i_expected_rebate_amount   = '30.00' ).
  ENDMETHOD.


  METHOD apply_to_all_4.
    m_cart = VALUE #( ( id = '1' quantity = 7 standard_price = '10.00' )
                      ( id = '2' quantity = 5 standard_price = '20.00' )
                    ).
    "-- semantics of 'apply_to_all': the reduction is applied to all items
    "-- covered by the reduction rule

    "-- hit item 2, 2 reductions, reduction amt applied to ALL 4 items covered by rule
    run_case_and_assert(
        i_required_id              = '2'
        i_required_number_of_items = 2
        i_amount_off               = 12
        i_apply_to                 = at_all
        i_expected_rebate_amount   = '48.00' ).
  ENDMETHOD.

  METHOD rebate_reason_for_item_id.
    m_cart = VALUE #( ( id = '1' quantity = 2 standard_price = '10.00' )
                      ( id = '2' quantity = 3 standard_price = '20.00' )
                    ).

    run_case_and_assert(
        i_required_id              = '1'
        i_required_number_of_items = 2
        i_amount_off               = 5
        i_apply_to                 = at_1
        i_expected_rebate_amount   = '5.00' ).

    cl_abap_unit_assert=>assert_equals(
      act = m_cart[ id = '1' ]-rebate_reason
      exp = 'item_rebate'
    ).

  ENDMETHOD.


  METHOD no_rebate_reason_when_no_disc.
    m_cart = VALUE #( ( id = '1' quantity = 2 standard_price = '10.00' )
                      ( id = '2' quantity = 3 standard_price = '20.00' )
                    ).

    run_case_and_assert(
        i_required_id              = '1'
        i_required_number_of_items = 9
        i_amount_off               = 5
        i_apply_to                 = at_1
        i_expected_rebate_amount   = '0.00' ).

    cl_abap_unit_assert=>assert_equals(
      act = m_cart[ id = '1' ]-rebate_reason
      exp = ''
    ).
  ENDMETHOD.

ENDCLASS.


**********************************************************************
* An alternative implementation of num rule, inheriting from a test helper
* It uses the given-when-then structure and a domain specific language approach

CLASS ltc_id_num_rule_alt DEFINITION FINAL FOR TESTING
  INHERITING FROM zth_wtcr_re_givenwhenthen
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA:
      m_items_id_rule TYPE REF TO zcl_wtcr_re_rule_item_id,
      m_cart          TYPE zase_shop_cart.

    CLASS-DATA:
      at_1   TYPE string,
      at_all TYPE string.

    METHODS:
      setup,
      second_item_with_amount_off FOR TESTING,

      given_rule_trigger_as
        IMPORTING
          i_item_id                  TYPE zase_shop_item_id
          i_required_number_of_items TYPE zase_shop_item_quantity,
      given_rule_effect_as
        IMPORTING
          i_percent    TYPE i OPTIONAL
          i_amount_off TYPE f OPTIONAL
          i_apply_to   TYPE zcl_wtcr_re_rule_base=>t_apply_to.
ENDCLASS.

CLASS ltc_id_num_rule_alt IMPLEMENTATION.

  METHOD setup.
    CREATE OBJECT m_items_id_rule EXPORTING i_rule_name = 'dummy'.
    m_items_id_rule = NEW zcl_wtcr_re_rule_item_id( 'dummy_rule_name' ).
    m_rebate_engine = NEW zcl_wtcr_rebate_engine( ).

    at_1   = zcl_wtcr_re_rule_base=>apply_to_1_item.
    at_all = zcl_wtcr_re_rule_base=>apply_to_all_items.
  ENDMETHOD.

  METHOD second_item_with_amount_off.
    given_the_cart_items(
      VALUE #( ( id = '1' quantity = 2 standard_price = '10.00' standard_total = 20 )
               ( id = '2' quantity = 3 standard_price = '20.00' standard_total = 60 ) "Σ  80
    ) ).

    given_item_rule( m_items_id_rule ).

    given_rule_trigger_as(
      i_item_id                  = '2'
      i_required_number_of_items = 2
    ).
    given_rule_effect_as(
      i_amount_off = 10
      i_apply_to   = at_1
    ).

    when_computing_rebate( ).

    then_rebate_amount_should_be( 10 ).
  ENDMETHOD.

  METHOD given_rule_trigger_as.
    m_items_id_rule->set_trigger(
      i_required_item_id              = i_item_id
      i_required_quantity = i_required_number_of_items
    ).
  ENDMETHOD.

  METHOD given_rule_effect_as.
    m_items_id_rule->set_effect(
      i_amount_off = i_amount_off
      i_percent_off    = i_percent
      i_apply_to   = i_apply_to
    ).
  ENDMETHOD.

ENDCLASS.
