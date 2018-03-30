CLASS ztd_wtcr_re_fake_rule_provider DEFINITION
  PUBLIC INHERITING FROM zcl_wtcr_re_rule_provider
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      get_cart_rules REDEFINITION,
      get_item_rules REDEFINITION,
      clean_rules.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA m_clean_rules TYPE abap_bool.
ENDCLASS.



CLASS ZTD_WTCR_RE_FAKE_RULE_PROVIDER IMPLEMENTATION.


  METHOD clean_rules.
    m_clean_rules = abap_true.
  ENDMETHOD.


  METHOD get_cart_rules.
    IF m_clean_rules = abap_true.
      RETURN.
    ENDIF.
    APPEND NEW zcl_wtcr_re_rule_cart_total( 'cart_rule_1' ) TO r_cart_rules.
    APPEND NEW zcl_wtcr_re_rule_cart_total( 'cart_rule_2' ) TO r_cart_rules.
  ENDMETHOD.


  METHOD get_item_rules.
    IF m_clean_rules = abap_true.
      RETURN.
    ENDIF.
    APPEND NEW zcl_wtcr_re_rule_item_id( 'item_rule_1' ) TO r_item_rules.
    APPEND NEW zcl_wtcr_re_rule_item_id( 'item_rule_2' ) TO r_item_rules.
  ENDMETHOD.
ENDCLASS.
