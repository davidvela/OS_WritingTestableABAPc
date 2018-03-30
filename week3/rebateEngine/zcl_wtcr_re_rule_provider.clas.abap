CLASS zcl_wtcr_re_rule_provider DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      ty_item_rules TYPE STANDARD TABLE OF REF TO zcl_wtcr_re_rule_base WITH DEFAULT KEY .
    TYPES:
      ty_cart_rules TYPE STANDARD TABLE OF REF TO zcl_wtcr_re_rule_base WITH DEFAULT KEY .

    METHODS get_item_rules
      RETURNING
        VALUE(r_item_rules) TYPE ty_item_rules .
    METHODS get_cart_rules
      RETURNING
        VALUE(r_cart_rules) TYPE ty_cart_rules .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      load_rules,
      get_test_item_rules RETURNING VALUE(r_item_rules) TYPE ty_item_rules,
      get_test_cart_rules RETURNING VALUE(r_cart_rules) TYPE ty_cart_rules.
ENDCLASS.



CLASS ZCL_WTCR_RE_RULE_PROVIDER IMPLEMENTATION.


  METHOD get_cart_rules.
    r_cart_rules = get_test_cart_rules( ).
  ENDMETHOD.


  METHOD get_item_rules.
    r_item_rules = get_test_item_rules( ).
  ENDMETHOD.


  METHOD get_test_cart_rules.
    DATA(m_pe_rule_cart_total) = NEW zcl_wtcr_re_rule_cart_total(  'cart total: req_sum = 100, percent_off=10').
    m_pe_rule_cart_total->set_trigger( i_required_amount =  100 ).
    m_pe_rule_cart_total->set_effect(  i_percent_off    = 10 ).
    APPEND m_pe_rule_cart_total TO r_cart_rules.
  ENDMETHOD.


  METHOD get_test_item_rules.
    "-- Normally we would load the rules from the rules DB at this time
    " Here we will only create a fixed set of rules to be used in the
    " interactive version of the ASE_SHOP for demo purposes.

    DATA(m_pe_rule_item_id) = NEW zcl_wtcr_re_rule_item_id(  'item: id=368, num=2, percent_off=20, apply=ONE' ).
    m_pe_rule_item_id->set_trigger(
      i_required_item_id              = 368
      i_required_quantity = 2
    ).
    m_pe_rule_item_id->set_effect(
       i_percent_off    = 20
       i_apply_to   = zcl_wtcr_re_rule_base=>apply_to_1_item
    ).
    APPEND m_pe_rule_item_id TO r_item_rules.

    DATA(m_pe_rule_category) = NEW zcl_wtcr_re_rule_item_category( 'item: category=DVDs, num=3, amt_off=5, apply=ONE' ).
    m_pe_rule_category->set_trigger(
      i_required_quantity = 3
      i_required_category = 'DVDs'
    ).
    m_pe_rule_category->set_effect(
      i_amount_off = 5
      i_apply_to   = zcl_wtcr_re_rule_base=>apply_to_1_item
    ).
    APPEND m_pe_rule_category TO r_item_rules.
  ENDMETHOD.


  METHOD load_rules.
    "TODO: implement
    "--SELECT * FROM ase_shop_rule_db INTO TABLE m_rules.
  ENDMETHOD.
ENDCLASS.
