**********************************************************************
* Integration tests for ASE_SHOP
*
* Comments in the source explain the patterns and reasons for choices.
**********************************************************************
*
* Test Doubles and Factories
*
* We consider the case that we have a factory (CL_WTCR_SHOP_FACTORY) that
* manages a class C1 that is CREATE PRIVATE (so all users of the class
* have to go through the factory). Then C1 must declare FACTORY as FRIEND
* so that the factory can create a C1 instance.
*
* We implemented two test doubles, one for email and one for payment
* following the interface approach as described in the backlog.
*
**********************************************************************

* test double classes

*-----------------------------------

CLASS ltd_email_sender_spy DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zif_wtcr_shop_email_sender.
    DATA m_send_was_called TYPE abap_bool.
ENDCLASS.

CLASS ltd_email_sender_spy IMPLEMENTATION.
  METHOD zif_wtcr_shop_email_sender~send.
    "-- do nothing but just record we were called
    m_send_was_called = abap_true.
  ENDMETHOD.
ENDCLASS.

*-------------------------------

CLASS ltd_process_payment DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zif_wtcr_shop_process_payment.
    DATA m_process_was_called TYPE abap_bool.
    DATA m_success TYPE abap_bool.
ENDCLASS.

CLASS ltd_process_payment IMPLEMENTATION.

  METHOD zif_wtcr_shop_process_payment~process.
    m_process_was_called = abap_true.
    r_success = m_success.
  ENDMETHOD.

ENDCLASS.


**********************************************************************

CLASS ltc_shop_integration_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      setup,
      payment_process_successfull FOR TESTING RAISING cx_static_check,
      payment_process_unsuccessfull FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltc_shop_integration_test IMPLEMENTATION.

  METHOD setup.
    "reset the factory between test to get a clean state
    zth_wtcr_shop_factory_injector=>reset( ).
  ENDMETHOD.

  METHOD payment_process_successfull.
    "-- positive buy_cart case where pay was successful

    "GIVEN
    DATA(process_payment) = NEW ltd_process_payment( ).
    process_payment->m_success = abap_true.
    zth_wtcr_shop_factory_injector=>inject_process_payment( process_payment ).

    DATA(email_sender_spy) = NEW ltd_email_sender_spy( ).
    zth_wtcr_shop_factory_injector=>inject_email_sender( email_sender_spy ).

    DATA(shop) = CAST zif_wtc_shop( NEW zcl_wtcr_shop( ) ).
    shop->add_item_to_cart( i_id = '111' ).

    "WHEN
    shop->buy_cart( ).

    "THEN
    cl_abap_unit_assert=>assert_true( process_payment->m_process_was_called ).
    cl_abap_unit_assert=>assert_true( email_sender_spy->m_send_was_called ).
    cl_abap_unit_assert=>assert_initial( act = shop->get_cart( )
                                         msg = 'Cart is expected to be empty after successful buy' ).
  ENDMETHOD.

  METHOD payment_process_unsuccessfull.
    "-- negative buy_cart case where pay was successful

    "GIVEN
    DATA(process_payment) = NEW ltd_process_payment( ).
    process_payment->m_success = abap_false.
    zth_wtcr_shop_factory_injector=>inject_process_payment( process_payment ).

    DATA(email_sender_spy) = NEW ltd_email_sender_spy( ).
    zth_wtcr_shop_factory_injector=>inject_email_sender( email_sender_spy ).

    DATA(shop) = CAST zif_wtc_shop( NEW zcl_wtcr_shop( ) ).
    shop->add_item_to_cart( i_id = '111' ).

    "WHEN
    shop->buy_cart( ).

    "THEN
    cl_abap_unit_assert=>assert_true( process_payment->m_process_was_called ).
    cl_abap_unit_assert=>assert_true( email_sender_spy->m_send_was_called ).
    cl_abap_unit_assert=>assert_not_initial( act = shop->get_cart( )
                                             msg = 'Cart is expected to be not empty after unsuccessful buy' ).
  ENDMETHOD.

ENDCLASS.


**********************************************************************
* Second variant using the ABAP Test Double Framework                *
**********************************************************************

CLASS ltc_shop_integration_test_tdf DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  "-- alternative test that uses the ABAP test double framework
  PRIVATE SECTION.
    METHODS:
      buy_cart_pay_success FOR TESTING,
      setup.
ENDCLASS.

CLASS ltc_shop_integration_test_tdf IMPLEMENTATION.

  METHOD setup.
  ENDMETHOD.

  METHOD buy_cart_pay_success.
    "-- using the ABAP test double framework
    DATA payment_spy TYPE REF TO zif_wtcr_shop_payment.
    DATA email_sender_null TYPE REF TO ltd_email_sender_spy. "-- just needed for NULL reference

    "GIVEN
    "-- get the test double classes to use in calls and injects
    "-- Since pay() will the mocked, the email_sender will not be called. Therefore not needed.
    payment_spy ?= cl_abap_testdouble=>create( 'zif_wtcr_shop_payment' ).

    "-- specify behavior of pay() method. First return value and expectations. Then close definition with 'real call' (pay())
    cl_abap_testdouble=>configure_call( payment_spy )->returning( abap_true )->ignore_all_parameters( )->and_expect( )->is_called_once( ).
    payment_spy->pay(
      EXPORTING
        i_email_sender = email_sender_null
        i_value        = '0.0'
    ).
    zth_wtcr_shop_factory_injector=>inject_payment_processor( payment_spy ).

    DATA(shop) = NEW zcl_wtcr_shop( ).

    "WHEN
    shop->zif_wtc_shop~buy_cart( ).

    "THEN
    "-- will raise exception when expectation of 'called once' not met
    cl_abap_testdouble=>verify_expectations( payment_spy ).
  ENDMETHOD.

ENDCLASS.
