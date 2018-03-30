CLASS zcl_wtcr_shop DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      zif_wtc_shop.
    METHODS:
      constructor.
  PRIVATE SECTION.

    DATA:
      m_cart    TYPE REF TO zcl_wtcr_shop_cart,
      m_catalog TYPE REF TO zcl_wtcr_shop_catalog,
      m_payment TYPE REF TO zif_wtcr_shop_payment,
      m_email_sender TYPE REF TO zif_wtcr_shop_email_sender.
    METHODS build_new_empty_cart.

ENDCLASS.



CLASS ZCL_WTCR_SHOP IMPLEMENTATION.


  METHOD build_new_empty_cart.
    m_cart = NEW zcl_wtcr_shop_cart( ).
    DATA(rebate_engine) = NEW zcl_wtcr_rebate_engine( ).
    rebate_engine->load_rules( ).

    m_cart->set_rebate_engine( rebate_engine ).
  ENDMETHOD.


  METHOD constructor.
    m_payment = zcl_wtcr_shop_factory=>get_payment_processor( ).
    m_email_sender = zcl_wtcr_shop_factory=>get_email_sender( ).
    m_catalog = NEW zcl_wtcr_shop_catalog( ).
    build_new_empty_cart( ).
  ENDMETHOD.


  METHOD zif_wtc_shop~add_item_to_cart.
    m_cart->add_item( m_catalog->get_item( i_id ) ).
  ENDMETHOD.


  METHOD zif_wtc_shop~buy_cart.
    rv_success = m_payment->pay(
        i_email_sender = m_email_sender
        i_value        = zif_wtc_shop~get_final_price( )
    ).
    IF rv_success = abap_true.
      build_new_empty_cart( ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_wtc_shop~get_cart.
    r_cart = m_cart->get_cart( ).
  ENDMETHOD.


  METHOD zif_wtc_shop~get_catalog.
    r_catalog = m_catalog->get_catalog( ).
  ENDMETHOD.


  METHOD zif_wtc_shop~get_final_price.
    r_result = zif_wtc_shop~get_total_price( ) - zif_wtc_shop~get_global_rebate( ).
  ENDMETHOD.


  METHOD zif_wtc_shop~get_global_rebate.
    r_global_rebate = m_cart->get_rebate( ).
  ENDMETHOD.


  METHOD zif_wtc_shop~get_global_rebate_reason.
    r_global_rebate_reason = m_cart->get_total_rebate_reason( ).
  ENDMETHOD.


  METHOD zif_wtc_shop~get_names_of_active_rules.
    r_active_rule_names = m_cart->get_names_of_active_rules( ).
  ENDMETHOD.


  METHOD zif_wtc_shop~get_total_price.
    r_total_price = m_cart->get_standard_total( ).
  ENDMETHOD.


  METHOD zif_wtc_shop~remove_item_from_cart.
    m_cart->remove_item( i_cart_item ).
  ENDMETHOD.
ENDCLASS.
