CLASS zcl_wtcr_shop_factory DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zth_wtcr_shop_factory_injector .

  PUBLIC SECTION.
    CLASS-METHODS:
      get_process_payment
        RETURNING
          VALUE(r_process_payment) TYPE REF TO zif_wtcr_shop_process_payment,
      get_payment_processor
        RETURNING
          VALUE(r_payment_processor) TYPE REF TO zif_wtcr_shop_payment,
      get_email_sender
        RETURNING
          VALUE(r_email_sender) TYPE REF TO zif_wtcr_shop_email_sender,
      get_user
        RETURNING
          VALUE(r_user) TYPE REF TO zcl_wtcr_shop_user.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA g_payment_processor TYPE REF TO zif_wtcr_shop_payment.
    CLASS-DATA g_email_sender TYPE REF TO zif_wtcr_shop_email_sender.
    CLASS-DATA g_user TYPE REF TO zcl_wtcr_shop_user.
    CLASS-DATA g_process_payment TYPE REF TO zif_wtcr_shop_process_payment.

    CLASS-METHODS reset.
    CLASS-METHODS:
      set_process_payment
        IMPORTING
          i_process_payment TYPE REF TO zif_wtcr_shop_process_payment,
      set_payment_processor
        IMPORTING
          i_payment_processor TYPE REF TO zif_wtcr_shop_payment,
      set_email_sender
        IMPORTING
          i_email_sender TYPE REF TO zif_wtcr_shop_email_sender,
      set_user
        IMPORTING
          i_user TYPE REF TO zcl_wtcr_shop_user.

ENDCLASS.



CLASS ZCL_WTCR_SHOP_FACTORY IMPLEMENTATION.


  METHOD get_email_sender.
    IF g_email_sender IS INITIAL.
      g_email_sender = NEW zcl_wtcr_shop_email_sender( ).
    ENDIF.
    r_email_sender = g_email_sender.
  ENDMETHOD.


  METHOD get_payment_processor.
    IF g_payment_processor IS INITIAL.
      g_payment_processor = NEW zcl_wtcr_shop_payment_processo( ).
    ENDIF.
    r_payment_processor = g_payment_processor.
  ENDMETHOD.


  METHOD get_process_payment.
    IF g_process_payment IS INITIAL.
      g_process_payment = NEW zcl_wtcr_shop_process_payment( ).
    ENDIF.
    r_process_payment = g_process_payment.
  ENDMETHOD.


  METHOD get_user.
    IF g_user IS INITIAL.
      g_user = NEW zcl_wtcr_shop_user( ).
    ENDIF.
    r_user = g_user.
  ENDMETHOD.


  METHOD reset.
    "need to be reset between tests
    CLEAR g_payment_processor.
    CLEAR g_payment_processor.
    CLEAR g_email_sender.
    CLEAR g_user.
    CLEAR g_process_payment.
  ENDMETHOD.


  METHOD set_email_sender.
    g_email_sender = i_email_sender.
  ENDMETHOD.


  METHOD set_payment_processor.
    g_payment_processor = i_payment_processor.
  ENDMETHOD.


  METHOD set_process_payment.
    g_process_payment = i_process_payment.
  ENDMETHOD.


  METHOD set_user.
    g_user = i_user.
  ENDMETHOD.
ENDCLASS.
