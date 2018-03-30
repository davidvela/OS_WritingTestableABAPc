**********************************************************************
****** Rule level tests are at the rules classes   *******************
**********************************************************************


**********************************************************************
******** Tests for trigger 'total cart amount'         ***************
**********************************************************************
CLASS ltc_cart_level DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA:
      m_rebate_engine      TYPE REF TO zcl_wtcr_rebate_engine,
      m_pe_rule_cart_total TYPE REF TO zcl_wtcr_re_rule_cart_total,
      m_rebate_result      TYPE zase_shop_rebate_result,
      m_cart               TYPE zase_shop_cart.

    CLASS-DATA:
      at_1   TYPE string,
      at_all TYPE string.

    METHODS:
      setup,
      discount_total_using_percent FOR TESTING,
      discount_total_using_amount   FOR TESTING,
      no_discount                  FOR TESTING,
      rebate_reason_is_rule_name   FOR TESTING,
      no_items_in_cart             FOR TESTING,
      cart_cant_be_empty_after_calc FOR TESTING.

ENDCLASS.

CLASS ltc_cart_level IMPLEMENTATION.

  METHOD setup.
    m_rebate_engine      = NEW zcl_wtcr_rebate_engine( ).
    m_pe_rule_cart_total = NEW zcl_wtcr_re_rule_cart_total( i_rule_name = 'Discount after 100' ).
    m_rebate_engine->add_cart_rule( m_pe_rule_cart_total ).

    m_cart = VALUE #( ( name = 'Johnny English' category = 'DVD'       quantity = 2 standard_price = '10.00' standard_total = 30 )
                      ( name = 'Iron'           category = 'Household' quantity = 2 standard_price = '50.00' standard_total = 100 )
                      ( name = 'Ironman 3'      category = 'DVD'       quantity = 3 standard_price = '10.00' standard_total = 30 ) "Σ  160
                    ).
  ENDMETHOD.

  METHOD discount_total_using_percent.
    m_pe_rule_cart_total->set_trigger( i_required_amount = '100'  ).
    m_pe_rule_cart_total->set_effect(
      i_percent_off    = 10
    ).
    m_rebate_result = m_rebate_engine->compute_rebate(
      EXPORTING
        i_date        = sy-datum
      CHANGING
        c_cart_items =  m_cart
    ).

    cl_abap_unit_assert=>assert_equals( exp = '16' act = m_rebate_result-total_rebate ).
  ENDMETHOD.

  METHOD discount_total_using_amount.
    m_pe_rule_cart_total->set_trigger( i_required_amount = '100'  ).
    m_pe_rule_cart_total->set_effect( i_amount_off = 25 ).

    m_rebate_result = m_rebate_engine->compute_rebate(
      EXPORTING
        i_date        = sy-datum
      CHANGING
        c_cart_items =  m_cart
    ).
    cl_abap_unit_assert=>assert_equals( exp = '25' act = m_rebate_result-total_rebate ).
  ENDMETHOD.

  METHOD no_discount.
    m_pe_rule_cart_total->set_trigger( i_required_amount = '500'  ).
    m_pe_rule_cart_total->set_effect( i_amount_off = 25 ).

    m_rebate_result = m_rebate_engine->compute_rebate(
      EXPORTING
        i_date        = sy-datum
      CHANGING
        c_cart_items =  m_cart
    ).

    cl_abap_unit_assert=>assert_equals( exp = '0' act = m_rebate_result-total_rebate ).
  ENDMETHOD.

  METHOD rebate_reason_is_rule_name.
    m_pe_rule_cart_total->set_trigger( i_required_amount = '100'  ).
    m_pe_rule_cart_total->set_effect( i_amount_off = 25 ).

    m_rebate_result = m_rebate_engine->compute_rebate(
      EXPORTING
        i_date        = sy-datum
      CHANGING
        c_cart_items =  m_cart
    ).

    cl_abap_unit_assert=>assert_equals(
      act = m_rebate_result-global_rebate_reason
      exp = 'Discount after 100'
    ).
  ENDMETHOD.

  METHOD no_items_in_cart.
    m_cart = VALUE #( ).
    m_pe_rule_cart_total->set_trigger( i_required_amount = '100'  ).
    m_pe_rule_cart_total->set_effect( i_amount_off = 25 ).

    m_rebate_result = m_rebate_engine->compute_rebate(
      EXPORTING
        i_date        = sy-datum
      CHANGING
        c_cart_items = m_cart
    ).

    cl_abap_unit_assert=>assert_initial( m_rebate_result-total_rebate ).
    cl_abap_unit_assert=>assert_initial( m_rebate_result-global_rebate_reason ).
  ENDMETHOD.

  METHOD cart_cant_be_empty_after_calc.
    m_pe_rule_cart_total->set_trigger( i_required_amount = '100'  ).
    m_pe_rule_cart_total->set_effect( i_amount_off = 25 ).

    m_rebate_result = m_rebate_engine->compute_rebate(
      EXPORTING
        i_date        = sy-datum
      CHANGING
        c_cart_items = m_cart
    ).

    cl_abap_unit_assert=>assert_not_initial( m_cart ).
  ENDMETHOD.

ENDCLASS.

**********************************************************************
****** two rules interacting                                **********
**********************************************************************

CLASS ltc_several_item_rules DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
      m_rebate_engine TYPE REF TO zcl_wtcr_rebate_engine,
      m_rebate_result TYPE zase_shop_rebate_result,
      m_cart          TYPE zase_shop_cart.
    METHODS:
      two_rules_for_same_id   FOR TESTING,
      two_rules_same_category FOR TESTING,
      two_cart_rules          FOR TESTING,
      conflicting_item_rules  FOR TESTING,
      only_first_rule_applied FOR TESTING.
ENDCLASS.


CLASS ltc_several_item_rules IMPLEMENTATION.

  METHOD two_rules_for_same_id.
    m_rebate_engine = NEW zcl_wtcr_rebate_engine( ).
    m_cart = VALUE #(
                      ( id = 1 name = 'Star Wars' category = 'DVD' quantity = 3 standard_price = '15.00' standard_total = 45 )
               ).
    DATA(three_items_id_rebate) = NEW zcl_wtcr_re_rule_item_id( 'Three DVDs discount' ).
    three_items_id_rebate->set_trigger(
      i_required_item_id  = 1
      i_required_quantity = 3
    ).
    three_items_id_rebate->set_effect(
      i_amount_off = 10
      i_apply_to   = zcl_wtcr_re_rule_base=>apply_to_all_items
    ).
    m_rebate_engine->add_item_rule( three_items_id_rebate ).


    DATA(two_items_id_rebate) = NEW zcl_wtcr_re_rule_item_id( 'Two DVDs discount' ).
    two_items_id_rebate->set_trigger(
      i_required_item_id              = 1
      i_required_quantity = 2
    ).
    two_items_id_rebate->set_effect(
      i_amount_off = 5
      i_apply_to   = zcl_wtcr_re_rule_base=>apply_to_all_items
    ).
    m_rebate_engine->add_item_rule( two_items_id_rebate ).

    m_rebate_result = m_rebate_engine->compute_rebate(
      EXPORTING
        i_date       = sy-datum
      CHANGING
        c_cart_items = m_cart
    ).

    "Cart should have the highest rebate
    cl_abap_unit_assert=>assert_equals(
      act = m_cart[ name = 'Star Wars' ]-rebate_amount
      exp = 30
    ).
  ENDMETHOD.

  METHOD two_rules_same_category.
    m_rebate_engine = NEW zcl_wtcr_rebate_engine( ).
    m_cart = VALUE #(
                      ( id = 1 name = 'Star Wars' category = 'DVD' quantity = 3 standard_price = '15.00' standard_total = 45 ) "Σ  45
               ).
    DATA(three_items_id_rebate) = NEW zcl_wtcr_re_rule_item_category( 'Three DVDs discount' ).
    three_items_id_rebate->set_trigger(
      i_required_category        = 'DVD'
      i_required_quantity = 3
    ).
    three_items_id_rebate->set_effect(
      i_amount_off = 10
      i_apply_to   = zcl_wtcr_re_rule_base=>apply_to_all_items
    ).
    m_rebate_engine->add_item_rule( three_items_id_rebate ).


    DATA(two_items_id_rebate) = NEW zcl_wtcr_re_rule_item_category( 'Two DVDs discount' ).
    two_items_id_rebate->set_trigger(
      i_required_category        = 'DVD'
      i_required_quantity = 2
    ).

    two_items_id_rebate->set_effect(
      i_amount_off = 5
      i_apply_to   = zcl_wtcr_re_rule_base=>apply_to_all_items
    ).

    m_rebate_engine->add_item_rule( two_items_id_rebate ).

    m_rebate_result = m_rebate_engine->compute_rebate(
      EXPORTING
        i_date       = sy-datum
      CHANGING
        c_cart_items = m_cart
    ).

    "Cart should have the highest rebate
    cl_abap_unit_assert=>assert_equals(
      act = m_cart[ name = 'Star Wars' ]-rebate_amount
      exp = 30
    ).
  ENDMETHOD.

  METHOD two_cart_rules.
    m_rebate_engine = NEW zcl_wtcr_rebate_engine( ).
    m_cart = VALUE #(
                      ( id = 1 name = 'Star Wars' category = 'DVD' quantity = 3 standard_price = '15.00' standard_total = 45 ) "Σ  45
             ).

    DATA(cart_total_15_rule) = NEW zcl_wtcr_re_rule_cart_total( 'Discount over 15' ).
    cart_total_15_rule->set_trigger( i_required_amount = 15 ).
    cart_total_15_rule->set_effect( i_amount_off = 25 ).
    m_rebate_engine->add_cart_rule( cart_total_15_rule ).

    DATA(cart_total_10_rule) = NEW zcl_wtcr_re_rule_cart_total( 'Discount over 10' ).
    cart_total_10_rule->set_trigger( i_required_amount = 10 ).
    cart_total_10_rule->set_effect( i_amount_off = 15 ).
    m_rebate_engine->add_cart_rule( cart_total_10_rule ).

    m_rebate_result = m_rebate_engine->compute_rebate(
      EXPORTING
        i_date       = sy-datum
      CHANGING
        c_cart_items = m_cart
    ).

    cl_abap_unit_assert=>assert_equals(
      act = m_rebate_result-total_rebate
      exp = 25
    ).

    cl_abap_unit_assert=>assert_equals(
      act = m_rebate_result-global_rebate_reason
      exp = 'Discount over 15'
    ).
  ENDMETHOD.


  METHOD conflicting_item_rules.
    "An item and a category rule interacting. Category rule is not applied
    m_rebate_engine = NEW zcl_wtcr_rebate_engine( ).
    m_cart = VALUE #(
                      ( id = 1 name = 'Star Wars' category = 'DVD' quantity = 3 standard_price = '15.00' standard_total = 45 ) "Σ  45
               ).
    DATA(three_items_id_rebate) = NEW zcl_wtcr_re_rule_item_id( 'Three DVDs discount' ).
    three_items_id_rebate->set_trigger(
      i_required_item_id              = 1
      i_required_quantity = 3
    ).
    three_items_id_rebate->set_effect(
      i_amount_off = 10
      i_apply_to   = zcl_wtcr_re_rule_base=>apply_to_all_items
    ).
    m_rebate_engine->add_item_rule( three_items_id_rebate ).


    DATA(category_rule_rebate) = NEW zcl_wtcr_re_rule_item_category( 'Category Two DVDs discount' ).
    category_rule_rebate->set_trigger(
      i_required_category        = 'DVD'
      i_required_quantity = 9
    ).

    category_rule_rebate->set_effect(
      i_amount_off = 5
      i_apply_to   = zcl_wtcr_re_rule_base=>apply_to_all_items
    ).

    m_rebate_engine->add_item_rule( category_rule_rebate ).

    m_rebate_result = m_rebate_engine->compute_rebate(
      EXPORTING
        i_date       = sy-datum
      CHANGING
        c_cart_items = m_cart
    ).

    "ID has the highest rebate
    cl_abap_unit_assert=>assert_equals(
      act = m_cart[ name = 'Star Wars' ]-rebate_amount
      exp = 30
    ).
    cl_abap_unit_assert=>assert_equals(
      act = m_cart[ name = 'Star Wars' ]-rebate_reason
      exp = 'Three DVDs discount'
    ).
    cl_abap_unit_assert=>assert_equals(
      act = m_rebate_result-total_rebate
      exp = 30
    ).
  ENDMETHOD.


  METHOD only_first_rule_applied.
    "An item and a category rule interacting. The best rebate should be kept
    m_rebate_engine = NEW zcl_wtcr_rebate_engine( ).
    m_cart = VALUE #(
                      ( id = 1 name = 'Star Wars' category = 'DVD' quantity = 3 standard_price = '15.00' standard_total = 45 ) "Σ  45
               ).
    DATA(three_items_id_rebate) = NEW zcl_wtcr_re_rule_item_id( 'Three DVDs discount' ).
    three_items_id_rebate->set_trigger(
      i_required_item_id              = 1
      i_required_quantity = 3
    ).
    three_items_id_rebate->set_effect(
      i_amount_off = 10
      i_apply_to   = zcl_wtcr_re_rule_base=>apply_to_all_items
    ).
    m_rebate_engine->add_item_rule( three_items_id_rebate ).


    DATA(category_rule_rebate) = NEW zcl_wtcr_re_rule_item_category( 'Category Two DVDs discount' ).
    category_rule_rebate->set_trigger(
      i_required_category        = 'DVD'
      i_required_quantity = 3
    ).

    category_rule_rebate->set_effect(
      i_amount_off = 5
      i_apply_to   = zcl_wtcr_re_rule_base=>apply_to_all_items
    ).

    m_rebate_engine->add_item_rule( category_rule_rebate ).

    m_rebate_result = m_rebate_engine->compute_rebate(
      EXPORTING
        i_date       = sy-datum
      CHANGING
        c_cart_items = m_cart
    ).

    "ID has the highest rebate
    cl_abap_unit_assert=>assert_equals(
      act = m_cart[ name = 'Star Wars' ]-rebate_amount
      exp = 30
    ).
    cl_abap_unit_assert=>assert_equals(
      act = m_cart[ name = 'Star Wars' ]-rebate_reason
      exp = 'Three DVDs discount'
    ).
  ENDMETHOD.
ENDCLASS.

**********************************************************************
CLASS ltc_rules_from_rule_provider DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      read_item_rules FOR TESTING,
      read_cart_rules FOR TESTING,
      empty_rules FOR TESTING.
ENDCLASS.


CLASS ltc_rules_from_rule_provider IMPLEMENTATION.

  METHOD read_item_rules.
    DATA rule_provider TYPE REF TO zcl_wtcr_re_rule_provider.
    rule_provider = NEW ztd_wtcr_re_fake_rule_provider( ).
    DATA(rebate_engine) = NEW zcl_wtcr_rebate_engine( rule_provider ).
    rebate_engine->load_rules( ).

    cl_abap_unit_assert=>assert_table_contains(
      line  = VALUE zase_shop_rule_table_item( rule_name = 'ITEM: item_rule_1' )
      table = rebate_engine->get_names_of_active_rules( )
    ).
    cl_abap_unit_assert=>assert_table_contains(
      line  = VALUE zase_shop_rule_table_item( rule_name = 'ITEM: item_rule_2' )
      table = rebate_engine->get_names_of_active_rules( )
    ).
  ENDMETHOD.

  METHOD read_cart_rules.
    DATA rule_provider TYPE REF TO zcl_wtcr_re_rule_provider.
    rule_provider = NEW ztd_wtcr_re_fake_rule_provider( ).
    DATA(rebate_engine) = NEW zcl_wtcr_rebate_engine( rule_provider ).
    rebate_engine->load_rules( ).

    cl_abap_unit_assert=>assert_table_contains(
      line  = VALUE zase_shop_rule_table_item( rule_name = 'CART: cart_rule_1' )
      table = rebate_engine->get_names_of_active_rules( )
    ).
    cl_abap_unit_assert=>assert_table_contains(
      line  = VALUE zase_shop_rule_table_item( rule_name = 'CART: cart_rule_2' )
      table = rebate_engine->get_names_of_active_rules( )
    ).
  ENDMETHOD.

  METHOD empty_rules.
    DATA(rule_provider) = NEW ztd_wtcr_re_fake_rule_provider( ).
    rule_provider->clean_rules( ).
    DATA(rebate_engine) = NEW zcl_wtcr_rebate_engine( rule_provider ).
    rebate_engine->load_rules( ).

    cl_abap_unit_assert=>assert_initial( rebate_engine->get_names_of_active_rules( ) ).
  ENDMETHOD.

ENDCLASS.
