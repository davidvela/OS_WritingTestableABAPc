CLASS zcl_wtcr_shop_process_payment DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_wtcr_shop_factory.

  PUBLIC SECTION.
    INTERFACES zif_wtcr_shop_process_payment.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_WTCR_SHOP_PROCESS_PAYMENT IMPLEMENTATION.


  METHOD zif_wtcr_shop_process_payment~process.
    CALL FUNCTION 'ZASE_WTC_SHOP_PROCESS_PAYMENT'
      EXPORTING
        i_username = i_username
        i_value    = i_value
      IMPORTING
        e_success  = r_success.
  ENDMETHOD.
ENDCLASS.
