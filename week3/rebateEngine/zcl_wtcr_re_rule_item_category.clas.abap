CLASS zcl_wtcr_re_rule_item_category DEFINITION
  PUBLIC
  INHERITING FROM zcl_wtcr_re_rule_base
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS set_trigger
      IMPORTING
        i_required_quantity TYPE zase_shop_item_quantity
        i_required_category TYPE zase_shop_item_category .

    METHODS apply
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      m_required_number_of_items TYPE zase_shop_item_quantity,
      m_required_category        TYPE zase_shop_item_category.

ENDCLASS.



CLASS ZCL_WTCR_RE_RULE_ITEM_CATEGORY IMPLEMENTATION.


  METHOD apply.

    FIELD-SYMBOLS: <item> TYPE zase_shop_cart_item.
    DATA: reduction_amount TYPE f,
          reduction_factor TYPE i.

    CLEAR m_rebate_amount.

    DATA(cart) = i_cart.
    LOOP AT cart ASSIGNING <item>.
      "-- set default first
      <item>-rebate_amount = 0.

      "-- do we have the right item?
      IF <item>-category = m_required_category.
        "-- compute reduction: can be 0 when below mv_num oder
        "-- multiple times when # of items is multiple of mv_num
        reduction_factor = <item>-quantity DIV m_required_number_of_items.

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
          <item>-rebate_amount = reduction_amount * m_required_number_of_items.
        ENDIF.
      ENDIF.
    ENDLOOP.

    "-- now compute total of rebated prices
    LOOP AT cart ASSIGNING FIELD-SYMBOL(<cart_item>).
      IF <cart_item>-rebate_amount IS NOT INITIAL.
        <cart_item>-rebate_reason = m_rule_name.
      ENDIF.
      DATA(previous_rebate_amount) = i_cart[ sy-tabix ]-rebate_amount.
      IF previous_rebate_amount > <cart_item>-rebate_amount.
        <cart_item>-rebate_amount   = previous_rebate_amount.
        <cart_item>-rebate_reason =  i_cart[ sy-tabix ]-rebate_reason.
      ENDIF.
    ENDLOOP.

    LOOP AT cart ASSIGNING <cart_item>.
      m_rebate_amount = m_rebate_amount + <cart_item>-rebate_amount.
    ENDLOOP.


    r_cart = cart.
  ENDMETHOD.


  METHOD set_trigger.
    m_required_number_of_items = i_required_quantity.
    m_required_category        = i_required_category.
  ENDMETHOD.
ENDCLASS.
