CLASS zcl_wtcr_shop_payment_processo DEFINITION
  PUBLIC
  CREATE PROTECTED
  GLOBAL FRIENDS zcl_wtcr_shop_factory .

  PUBLIC SECTION.
    INTERFACES zif_wtcr_shop_payment.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS get_participant_information RETURNING VALUE(r_participant) TYPE string.
ENDCLASS.



CLASS ZCL_WTCR_SHOP_PAYMENT_PROCESSO IMPLEMENTATION.


  METHOD get_participant_information.
    DATA my_classname TYPE abap_abstypename.
    my_classname = cl_abap_classdescr=>get_class_name( me ).
    r_participant = sy-uname && ` from ` && my_classname.
  ENDMETHOD.


  METHOD zif_wtcr_shop_payment~pay.
    r_success = zcl_wtcr_shop_factory=>get_process_payment( )->process(
        i_username = sy-uname
        i_value    = i_value ).

    IF r_success = abap_true.
      i_email_sender->send(
        i_subject = `Payment processed for user ` && sy-uname
        i_body    = VALUE #( ( `Final price: ` && i_value ) ( get_participant_information( ) ) )
      ).
    ELSE.
      i_email_sender->send(
        i_subject = `Payment FAILED for user ` && sy-uname
        i_body    = VALUE #( ( `Final price: ` && i_value ) ( get_participant_information( ) ) )
      ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
