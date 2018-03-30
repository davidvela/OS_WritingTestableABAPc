CLASS ltc_rebate_reason DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      add_1_reason FOR TESTING,
      add_2_reasons for testing,
      remove_last_reason for testing,
      add_2_remove_last for testing,
      remove_last_reason_empty for testing.
ENDCLASS.


CLASS ltc_rebate_reason IMPLEMENTATION.

  METHOD add_1_reason.
    DATA(reason) = NEW zcl_wtcr_re_rebate_reason( ).
    reason->add_clause( 'Discount on DVDs' ).

    cl_abap_unit_assert=>assert_equals(
      act = reason->get_text( )
      exp = 'Discount on DVDs'
    ).
  ENDMETHOD.

  METHOD add_2_reasons.
    DATA(reason) = NEW zcl_wtcr_re_rebate_reason( ).
    reason->add_clause( 'Discount on DVDs' ).
    reason->add_clause( 'Discount over 500 total price' ).

    cl_abap_unit_assert=>assert_equals(
      act = reason->get_text( )
      exp = 'Discount on DVDs and Discount over 500 total price'
    ).
  ENDMETHOD.

  METHOD remove_last_reason.
    DATA(reason) = NEW zcl_wtcr_re_rebate_reason( ).
    reason->add_clause( 'Discount on DVDs' ).
    reason->remove_last_clause( ).

    cl_abap_unit_assert=>assert_equals(
      act = reason->get_text( )
      exp = ''
    ).
  ENDMETHOD.

  METHOD add_2_remove_last.
    DATA(reason) = NEW zcl_wtcr_re_rebate_reason( ).
    reason->add_clause( 'Discount on DVDs' ).
    reason->add_clause( 'Discount over 500 total price' ).

    reason->remove_last_clause( ).

    cl_abap_unit_assert=>assert_equals(
      act = reason->get_text( )
      exp = 'Discount on DVDs'
    ).
  ENDMETHOD.

  METHOD remove_last_reason_empty.
    DATA(reason) = NEW zcl_wtcr_re_rebate_reason( ).
    reason->remove_last_clause( ).

    cl_abap_unit_assert=>assert_equals(
      act = reason->get_text( )
      exp = ''
    ).
  ENDMETHOD.

ENDCLASS.
