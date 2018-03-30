CLASS zcl_wtcr_re_rule_base DEFINITION
  ABSTRACT
  PUBLIC CREATE PUBLIC.

  PUBLIC SECTION.
    "---- specifying effects
    TYPES: t_apply_to TYPE string.
    CLASS-DATA:
      apply_to_1_item            TYPE t_apply_to READ-ONLY VALUE 'ONE',
      apply_to_all_items         TYPE t_apply_to READ-ONLY VALUE 'ALL',
      apply_to_lowest_price_item TYPE t_apply_to READ-ONLY VALUE 'LPI',
      apply_to_whole_cart        TYPE t_apply_to READ-ONLY VALUE 'CART'.

    METHODS:
      constructor
        IMPORTING
          i_rule_name  TYPE string
          i_valid_from TYPE d OPTIONAL
          i_valid_to   TYPE d OPTIONAL,
      is_active
        IMPORTING
          i_date          TYPE d
        RETURNING
          VALUE(r_active) TYPE abap_bool,
      apply ABSTRACT
        IMPORTING
          i_cart          TYPE zase_shop_cart
        RETURNING
          VALUE(r_cart)   TYPE zase_shop_cart,
      get_rebate_reason
        RETURNING
          VALUE(r_reason) TYPE string,
      get_rebate_amount
        RETURNING
          VALUE(r_amount) TYPE f,
      get_name
        RETURNING VALUE(r_name) TYPE string,
      "---- specifying effects
      set_effect
        IMPORTING
          i_percent_off TYPE i OPTIONAL
          i_amount_off  TYPE f OPTIONAL
          i_apply_to    TYPE t_apply_to OPTIONAL.

  PROTECTED SECTION.
    DATA: m_rule_name     TYPE string,
          m_valid_from    TYPE d,
          m_valid_to      TYPE d,
          m_rebate_amount TYPE f,
          m_percent       TYPE f,
          m_amount_off    TYPE f,
          m_apply_to      TYPE t_apply_to.

    METHODS calculate_current_items_price
      IMPORTING
        i_cart                 TYPE zase_shop_cart
      RETURNING
        VALUE(r_current_price) TYPE f.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_WTCR_RE_RULE_BASE IMPLEMENTATION.


  METHOD calculate_current_items_price.
    LOOP AT i_cart INTO DATA(item).
      r_current_price = r_current_price + item-standard_total - item-rebate_amount.
    ENDLOOP.
  ENDMETHOD.


  METHOD constructor.
    m_rule_name  = i_rule_name.
    m_valid_from = i_valid_from.
    m_valid_to   = i_valid_to.
  ENDMETHOD.


  METHOD get_name.
    r_name = m_rule_name.
  ENDMETHOD.


  METHOD get_rebate_amount.
    r_amount = m_rebate_amount.
  ENDMETHOD.


  METHOD get_rebate_reason.
    IF get_rebate_amount( ) IS NOT INITIAL.
      r_reason = m_rule_name.
    ENDIF.
  ENDMETHOD.


  METHOD is_active.
    "-- rule is active by default; when valid period boundaries are set, they are tested
    r_active = abap_true.
    IF m_valid_from IS NOT INITIAL AND i_date < m_valid_from.
      r_active = abap_false.
    ENDIF.
    IF m_valid_to IS NOT INITIAL AND i_date > m_valid_to.
      r_active = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD set_effect.
    "-- There should only be one of the effects set.
    IF i_percent_off    IS NOT INITIAL AND
       i_amount_off IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcx_wtcr_shop_config_error.
    ENDIF.

    "-- They cannot both be zero
    IF i_percent_off IS INITIAL AND i_amount_off IS INITIAL.
      RAISE EXCEPTION TYPE zcx_wtcr_shop_config_error.
    ENDIF.

    "-- none of them can be < 0
    IF i_percent_off    < 0 OR
       i_amount_off < 0    .
      RAISE EXCEPTION TYPE zcx_wtcr_shop_config_error.
    ENDIF.

    m_percent    = i_percent_off / 100.
    m_amount_off = i_amount_off.
    m_apply_to   = i_apply_to.
  ENDMETHOD.
ENDCLASS.
