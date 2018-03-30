*CLASS ltd_fake_price_engine DEFINITION
*  INHERITING FROM cl_ase_shop_price_engine.
*  PUBLIC SECTION.
*    METHODS compute_rebate REDEFINITION.
*    METHODS set_total
*      IMPORTING
*        i_total TYPE i.
*    METHODS was_called
*      RETURNING
*        VALUE(r_return) TYPE abap_bool.
*  PRIVATE SECTION.
*    DATA total TYPE i.
*    DATA compute_rebate_amount_called TYPE abap_bool.
*
*ENDCLASS.
*
*CLASS ltd_fake_price_engine IMPLEMENTATION.
*  METHOD was_called.
*    r_return = me->compute_rebate_amount_called.
*    me->compute_rebate_amount_called = abap_false.
*  ENDMETHOD.
*  METHOD compute_rebate.
*    me->compute_rebate_amount_called = abap_true.
*  ENDMETHOD.
*
*  METHOD set_total.
*    me->total = i_total.
*  ENDMETHOD.
*
*
*ENDCLASS.
*
*CLASS ltc_cart_test DEFINITION FINAL FOR TESTING
*  DURATION SHORT
*  RISK LEVEL HARMLESS.
*
*  PRIVATE SECTION.
*    DATA: cart                TYPE REF TO cl_ase_shop_cart,
*          fake_pricing_engine TYPE REF TO ltd_fake_price_engine.
*    METHODS:
*      setup,
*      adding_item_should_trigger_pe FOR TESTING,
*      remove_item_should_trigger_pe FOR TESTING.
*ENDCLASS.
*
*
*CLASS ltc_cart_test IMPLEMENTATION.
*  METHOD setup.
*    cart = NEW cl_ase_shop_cart( ).
*    fake_pricing_engine = NEW ltd_fake_price_engine( ).
*    cart->set_price_engine( fake_pricing_engine ).
*  ENDMETHOD.
*  METHOD adding_item_should_trigger_pe.
*    "Adding an item should trigger the price engine
*    fake_pricing_engine->set_total( 42 ).
*
*    cart->add_item( VALUE ase_shop_item( ) ).
*
*    cl_abap_unit_assert=>assert_equals(
*      act = cart->get_standard_total( )
*      exp = 42
*    ).
*
*    cl_abap_unit_assert=>assert_equals(
*      act = fake_pricing_engine->was_called( )
*      exp = abap_true
*    ).
*  ENDMETHOD.
*
*  METHOD remove_item_should_trigger_pe.
*    "Removing an item should trigger the price engine
*    fake_pricing_engine->set_total( 30 ).
*    cart->add_item( VALUE ase_shop_item( ) ).
*    fake_pricing_engine->was_called( ).
*
*    fake_pricing_engine->set_total( 50 ).
*    cart->add_item( VALUE ase_shop_item( ) ).
*    fake_pricing_engine->was_called( ).
*
*    fake_pricing_engine->set_total( 40 ).
*    cart->remove_item( VALUE ase_shop_cart_item( ) ).
*
*    cl_abap_unit_assert=>assert_equals(
*      act = cart->get_standard_total( )
*      exp = 40
*    ).
*
*    cl_abap_unit_assert=>assert_equals(
*      act = fake_pricing_engine->was_called( )
*      exp = abap_true
*    ).
*  ENDMETHOD.
*
*
*ENDCLASS.
