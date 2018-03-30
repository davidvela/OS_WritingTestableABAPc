CLASS zcl_wtcr_re_rule_item_id DEFINITION
  PUBLIC
  INHERITING FROM zcl_wtcr_re_rule_base
  FINAL
  CREATE PUBLIC .

  "------------------------------------------------------------
  "-- Price Engine Rule Class for trigger: <item_id, cnt>
  PUBLIC SECTION.

    METHODS set_trigger
      IMPORTING
        i_required_item_id  TYPE zase_shop_item_id
        i_required_quantity TYPE zase_shop_item_quantity .

    METHODS apply
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      m_required_id       TYPE zase_shop_item_id,
      m_required_quantity TYPE zase_shop_item_quantity.

ENDCLASS.



CLASS ZCL_WTCR_RE_RULE_ITEM_ID IMPLEMENTATION.


  METHOD apply.
    "-- rule applies to 'count of items in one cart item'
    CLEAR m_rebate_amount.

    FIELD-SYMBOLS: <item> TYPE zase_shop_cart_item.
    DATA: reduction_amount TYPE f,
          reduction_factor TYPE i.
    DATA(cart) = i_cart.
    LOOP AT cart ASSIGNING <item>.
      <item>-rebate_amount = 0.

      "-- do we have the right item?
      IF <item>-id = m_required_id.
        "-- compute reduction: can be 0 when below mv_num oder
        "-- multiple times when # of items is multiple of mv_num
        reduction_factor = <item>-quantity DIV m_required_quantity.

        "-- compute reduction amount depending on effect parameters
        IF m_percent > 0.
          reduction_amount = m_percent * <item>-standard_price * reduction_factor.
        ELSEIF m_amount_off > 0.
          reduction_amount = m_amount_off * reduction_factor.
        ENDIF.

        "-- apply reduction to 1 item or all
        IF m_apply_to = apply_to_1_item.
          <item>-rebate_amount = reduction_amount.
        ELSEIF m_apply_to = apply_to_all_items.
          <item>-rebate_amount = reduction_amount * m_required_quantity.
        ENDIF.
      ENDIF.
    ENDLOOP.

    "-- now compute total of adjusted prices
    LOOP AT cart ASSIGNING FIELD-SYMBOL(<cart_item>).
      DATA(previous_rebate_amount) = i_cart[ sy-tabix ]-rebate_amount.
      IF <cart_item>-rebate_amount > 0.
        IF previous_rebate_amount > <cart_item>-rebate_amount.
          <cart_item>-rebate_amount = previous_rebate_amount.
        ELSE.
          <cart_item>-rebate_reason = m_rule_name.
        ENDIF.
        m_rebate_amount = m_rebate_amount + <cart_item>-rebate_amount.
      ELSE.
        <cart_item>-rebate_amount = previous_rebate_amount.
      ENDIF.
    ENDLOOP.

    r_cart = cart.

  ENDMETHOD.


  METHOD set_trigger.
    m_required_id = i_required_item_id.
    m_required_quantity = i_required_quantity.
  ENDMETHOD.
ENDCLASS.
