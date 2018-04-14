CLASS zcl_wtcr_shop_user DEFINITION PUBLIC CREATE PROTECTED global friends zcl_wtcr_shop_factory .
  PUBLIC SECTION.
    METHODS:
      get_full_name RETURNING VALUE(r_fullname) TYPE string,
      get_email RETURNING VALUE(r_email) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_WTCR_SHOP_USER IMPLEMENTATION.


  METHOD get_email.
    DATA:
      badi_return  TYPE STANDARD TABLE OF bapiret2,
      address_smtp TYPE TABLE OF bapiadsmtp.

    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        username = sy-uname
      TABLES
        addsmtp  = address_smtp
        return   = badi_return.

    TRY.
        r_email = address_smtp[ 1 ]-e_mail.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDMETHOD.


  METHOD get_full_name.
    DATA:
      address     TYPE bapiaddr3,
      badi_return TYPE STANDARD TABLE OF bapiret2.
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        username = sy-uname
      IMPORTING
        address  = address
      TABLES
        return   = badi_return.

    "-- No need to check SY-SUBRC as the FM will never raise an Exception.
    CONCATENATE address-firstname
                address-lastname
          INTO  r_fullname
          SEPARATED BY space.
  ENDMETHOD.
ENDCLASS.
