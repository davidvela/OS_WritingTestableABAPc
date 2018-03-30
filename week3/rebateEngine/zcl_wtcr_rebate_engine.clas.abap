CLASS zcl_wtcr_rebate_engine DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        i_rule_provider TYPE REF TO zcl_wtcr_re_rule_provider OPTIONAL .
    METHODS add_item_rule
      IMPORTING
        i_rule TYPE REF TO zcl_wtcr_re_rule_base .
    METHODS add_cart_rule
      IMPORTING
        i_cart_rule TYPE REF TO zcl_wtcr_re_rule_base .

    METHODS compute_rebate
      IMPORTING
        i_date       TYPE d
      CHANGING
        c_cart_items TYPE zase_shop_cart
      RETURNING VALUE(r_rebate_result) TYPE zase_shop_rebate_result.

    METHODS get_names_of_active_rules
      RETURNING
        VALUE(r_active_rule_names) TYPE zase_shop_rules_table .
    METHODS load_rules .
  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA:
      m_total               TYPE zase_shop_item_standard_total,
      m_cart_price_rules    TYPE TABLE OF REF TO zcl_wtcr_re_rule_base,
      m_total_rebate_reason TYPE string,
      m_total_rebate_amount TYPE f,
      m_rebate_reason       TYPE REF TO zcl_wtcr_re_rebate_reason,
      m_item_price_rules    TYPE TABLE OF REF TO zcl_wtcr_re_rule_base,
      m_rule_provider       TYPE REF TO zcl_wtcr_re_rule_provider.
    METHODS:
      compute_rebate_for_items
        IMPORTING
          i_date       TYPE d
        CHANGING
          c_cart_items TYPE zase_shop_cart,
      compute_rebate_for_cart
        IMPORTING
          i_date       TYPE d
        CHANGING
          c_cart_items TYPE zase_shop_cart.

ENDCLASS.



CLASS ZCL_WTCR_REBATE_ENGINE IMPLEMENTATION.


  METHOD add_cart_rule.
    APPEND i_cart_rule TO m_cart_price_rules.
  ENDMETHOD.


  METHOD add_item_rule.
    APPEND i_rule TO m_item_price_rules.
  ENDMETHOD.


  METHOD compute_rebate.
    m_rebate_reason = NEW zcl_wtcr_re_rebate_reason( ).
    CLEAR m_total_rebate_amount.

    compute_rebate_for_items(
      EXPORTING
        i_date       = i_date
      CHANGING
        c_cart_items = c_cart_items
    ).
    compute_rebate_for_cart(
      EXPORTING
        i_date       = i_date
      CHANGING
        c_cart_items = c_cart_items
    ).

    "-- set return values of service call
    r_rebate_result-total_rebate = m_total_rebate_amount.
    r_rebate_result-global_rebate_reason = m_rebate_reason->get_text( ).
  ENDMETHOD.


  METHOD compute_rebate_for_cart.
    LOOP AT m_cart_price_rules INTO DATA(rule).
      IF rule->is_active( i_date ).
        c_cart_items = rule->apply( c_cart_items ).
        IF rule->get_rebate_amount( ) > m_total_rebate_amount.
          m_total_rebate_amount = m_total_rebate_amount + rule->get_rebate_amount( ).
          m_rebate_reason->remove_last_clause( ).

          m_rebate_reason->add_clause( rule->get_rebate_reason( ) ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD compute_rebate_for_items.
    LOOP AT m_item_price_rules INTO DATA(rule).
      IF rule->is_active( i_date ).
        c_cart_items = rule->apply( i_cart = c_cart_items ).
        m_total_rebate_amount = rule->get_rebate_amount( ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD constructor.
    m_rule_provider = i_rule_provider.
  ENDMETHOD.


  METHOD get_names_of_active_rules.
    DATA rule TYPE REF TO zcl_wtcr_re_rule_base.
    DATA s_rule_name TYPE zase_shop_rule_table_item.

    LOOP AT m_item_price_rules INTO rule.
      s_rule_name-rule_name = `ITEM: ` && rule->get_name( ).
      APPEND s_rule_name TO r_active_rule_names.
    ENDLOOP.

    LOOP AT m_cart_price_rules INTO rule.
      s_rule_name-rule_name = `CART: ` && rule->get_name( ).
      APPEND s_rule_name TO r_active_rule_names.
    ENDLOOP.

  ENDMETHOD.


  METHOD load_rules.
    IF m_rule_provider IS NOT BOUND.
      m_rule_provider = NEW zcl_wtcr_re_rule_provider( ).
    ENDIF.
    LOOP AT m_rule_provider->get_item_rules( ) INTO DATA(item_rule).
      me->add_item_rule( item_rule ).
    ENDLOOP.

    LOOP AT m_rule_provider->get_cart_rules( ) INTO DATA(cart_rule).
      me->add_cart_rule( cart_rule ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
