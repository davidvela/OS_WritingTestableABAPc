CLASS zth_wtcr_re_givenwhenthen DEFINITION
PUBLIC
  ABSTRACT.

  "--- test helper to allow for a given-when-then type
  " syntax of test methods and readable custom assertions.

  PUBLIC SECTION.
  PROTECTED SECTION.
    DATA:
      m_rebate_engine TYPE REF TO zcl_wtcr_rebate_engine,
      m_rebate_result TYPE zase_shop_rebate_result.

    METHODS given_the_cart_items
      IMPORTING
        i_cart_items TYPE zase_shop_cart.
    METHODS given_item_rule
      IMPORTING
        i_item_rule TYPE REF TO zCL_WTCR_RE_RULE_BASE.
    METHODS when_computing_rebate.
    METHODS: then_rebate_amount_should_be
      IMPORTING
          i_rebate_amount TYPE i.

  PRIVATE SECTION.
    DATA cart_items TYPE zase_shop_cart.
ENDCLASS.



CLASS ZTH_WTCR_RE_GIVENWHENTHEN IMPLEMENTATION.


  METHOD given_item_rule.
    m_rebate_engine->add_item_rule( i_item_rule ).
  ENDMETHOD.


  METHOD given_the_cart_items.
    cart_items = i_cart_items.
  ENDMETHOD.


  METHOD then_rebate_amount_should_be.
    cl_abap_unit_assert=>assert_equals(
      act = m_rebate_result-total_rebate
      exp = i_rebate_amount
    ).
  ENDMETHOD.


  METHOD when_computing_rebate.
    m_rebate_result = m_rebate_engine->compute_rebate(
      EXPORTING
        i_date        = sy-datum
      CHANGING
        c_cart_items =  cart_items
    ).
  ENDMETHOD.
ENDCLASS.
