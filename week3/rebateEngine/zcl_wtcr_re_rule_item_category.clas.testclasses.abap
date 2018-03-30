**********************************************************************
******** Tests for trigger 'category'                  ***************
**********************************************************************

CLASS ltc_category_one_rule DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA:
      m_rule          TYPE REF TO zcl_wtcr_re_rule_item_category,
      m_cart          TYPE zase_shop_cart.

    CLASS-DATA:
      at_1   TYPE string,
      at_all TYPE string.

    METHODS:
      setup,

      run_case_and_assert IMPORTING
                 i_category               TYPE zase_shop_item_category
                 i_num                    TYPE zase_shop_item_quantity
                 i_percent                TYPE i OPTIONAL
                 i_amount_off             TYPE f OPTIONAL
                 i_apply_to               TYPE zcl_wtcr_re_rule_base=>t_apply_to
                 i_expected_rebate_amount TYPE f,

      add_rebates
        IMPORTING
          i_cart       TYPE zase_shop_cart
        RETURNING
          VALUE(r_sum) TYPE zase_shop_item_standard_total,


      hit_2_items FOR TESTING,
      hit_1_item_should_have_reason FOR TESTING,
      hit_no_item_should_no_reason FOR TESTING ,
      hit_1_item_1_reduction FOR TESTING RAISING cx_static_check,
      hit_another_1_item FOR TESTING RAISING cx_static_check,
      hit_only_1_required FOR TESTING RAISING cx_static_check,
      hit_apply_to_all FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltc_category_one_rule IMPLEMENTATION.

  METHOD setup.
    CREATE OBJECT m_rule EXPORTING i_rule_name = 'item_category'.

    at_1   = zcl_wtcr_re_rule_base=>apply_to_1_item.
    at_all = zcl_wtcr_re_rule_base=>apply_to_all_items.
  ENDMETHOD.

  METHOD add_rebates.
    FIELD-SYMBOLS: <item> TYPE zase_shop_cart_item.
    LOOP AT i_cart ASSIGNING <item>.
      r_sum = r_sum + <item>-rebate_amount.
    ENDLOOP.
  ENDMETHOD.


  METHOD run_case_and_assert.
    DATA: total_rebate TYPE zase_shop_item_standard_total.

    m_rule->set_trigger(
        i_required_quantity = i_num
        i_required_category = i_category ).
    m_rule->set_effect(
        i_percent_off = i_percent
        i_amount_off  = i_amount_off
        i_apply_to    = i_apply_to ).

    m_cart = m_rule->apply(  i_cart = m_cart ).

    total_rebate = add_rebates( m_cart ).
    cl_abap_unit_assert=>assert_equals( exp = i_expected_rebate_amount act = total_rebate ).
  ENDMETHOD.


  METHOD hit_1_item_1_reduction.
    "--- category with one item line, mixed variants
    m_cart = VALUE #( ( name = 'Johnny English' category = 'DVD'       quantity = 3 standard_price = '10.00'  )
                      ( name = 'Iron'           category = 'Household' quantity = 2 standard_price = '50.00'  )
                    ).

    "-- hit 1 item cat='DVD', 1 reductions
    run_case_and_assert(
        i_category               = 'DVD'
        i_num                    = 2
        i_percent                = 50
        i_apply_to               = at_1
        i_expected_rebate_amount = '5.00' ).
  ENDMETHOD.

  METHOD hit_another_1_item.
    m_cart = VALUE #( ( name = 'Johnny English' category = 'DVD'       quantity = 3 standard_price = '10.00' )
                      ( name = 'Iron'           category = 'Household' quantity = 2 standard_price = '50.00' )
                      ).

    run_case_and_assert(
        i_category               = 'Household'
        i_num                    = 2
        i_amount_off             = 20
        i_apply_to               = at_1
        i_expected_rebate_amount = '20.00' ).
  ENDMETHOD.

  METHOD hit_only_1_required.
    m_cart = VALUE #( ( name = 'Johnny English' category = 'DVD'       quantity = 3 standard_price = '10.00' )
                      ( name = 'Iron'           category = 'Household' quantity = 2 standard_price = '50.00' )
                      ).

    run_case_and_assert(
        i_category               = 'Household'
        i_num                    = 1
        i_amount_off             = 20
        i_apply_to               = at_1
        i_expected_rebate_amount = '40.00' ).
  ENDMETHOD.

  METHOD hit_apply_to_all.
    m_cart = VALUE #( ( name = 'Johnny English' category = 'DVD'       quantity = 3 standard_price = '10.00' )
                      ( name = 'Iron'           category = 'Household' quantity = 2 standard_price = '50.00' )
                      ).

    run_case_and_assert(
        i_category               = 'Household'
        i_num                    = 2
        i_amount_off             = 20
        i_apply_to               = at_all
        i_expected_rebate_amount = '40.00' ).
  ENDMETHOD.

  "--- category spread over multiple line items
  METHOD hit_2_items.
    m_cart = VALUE #( ( name = 'Johnny English' category = 'DVD' quantity = 2 standard_price = '10.00' )
                      ( name = 'Iron' category = 'Household' quantity = 2 standard_price = '50.00'  )
                      ( name = 'Ironman 3' category = 'DVD' quantity = 3 standard_price = '10.00'   )
                      ( name = 'Hose' category = 'Gardening' quantity = 1 standard_price = '10.00'  )
                    ).

    "-- hit 2 items, cat='DVD', 1 reduction
    run_case_and_assert(
        i_category               = 'DVD'
        i_num                    = 2
        i_percent                = 50
        i_apply_to               = at_1
        i_expected_rebate_amount = '10.00' ).
  ENDMETHOD.


  METHOD hit_1_item_should_have_reason.
    m_cart = VALUE #( ( name = 'Johnny English' category = 'DVD'       quantity = 3 standard_price = '10.00' )
                      ( name = 'Iron'           category = 'Household' quantity = 2 standard_price = '50.00' )
                      ).

    run_case_and_assert(
        i_category               = 'DVD'
        i_num                    = 2
        i_percent                = 50
        i_apply_to               = at_1
        i_expected_rebate_amount = '5.00' ).

    cl_abap_unit_assert=>assert_equals(
      act = m_cart[ category = 'DVD' ]-rebate_reason
      exp = 'item_category'
    ).
  ENDMETHOD.


  METHOD hit_no_item_should_no_reason.
    m_cart = VALUE #( ( name = 'Johnny English' category = 'DVD'       quantity = 3 standard_price = '10.00' )
                      ( name = 'Iron'           category = 'Household' quantity = 2 standard_price = '50.00' )
                      ).

    run_case_and_assert(
        i_category               = 'DVD'
        i_num                    = 9
        i_percent                = 50
        i_apply_to               = at_1
        i_expected_rebate_amount = '0.00' ).

    cl_abap_unit_assert=>assert_equals(
      act = m_cart[ category = 'DVD' ]-rebate_reason
      exp = ''
    ).
  ENDMETHOD.

ENDCLASS.
