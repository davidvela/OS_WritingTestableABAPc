CLASS zcl_wtcr_re_rule_cart_total DEFINITION
  PUBLIC INHERITING FROM zcl_wtcr_re_rule_base
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      apply REDEFINITION.
    METHODS set_trigger
      IMPORTING
        i_required_amount TYPE zase_shop_item_standard_price.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      m_required_amount TYPE zase_shop_item_standard_price.

ENDCLASS.



CLASS ZCL_WTCR_RE_RULE_CART_TOTAL IMPLEMENTATION.


  METHOD apply.
    r_cart = i_cart.
    DATA(current_price) = calculate_current_items_price( i_cart ).
    CLEAR m_rebate_amount.

    IF current_price >= m_required_amount.
      IF m_percent > 0.
        m_rebate_amount = current_price * m_percent.
      ELSEIF m_amount_off > 0.
        m_rebate_amount = m_amount_off.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD set_trigger.
    m_required_amount = i_required_amount.
  ENDMETHOD.
ENDCLASS.
