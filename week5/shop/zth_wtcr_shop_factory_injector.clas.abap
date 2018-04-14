CLASS zth_wtcr_shop_factory_injector DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE FOR TESTING .

  PUBLIC SECTION.
    CLASS-METHODS:
      reset,
      inject_process_payment
        IMPORTING
          i_process_payment TYPE REF TO zif_wtcr_shop_process_payment,
      inject_payment_processor
        IMPORTING
          i_payment_processor TYPE REF TO zif_wtcr_shop_payment,
      inject_email_sender
        IMPORTING
          i_email_sender TYPE REF TO zif_wtcr_shop_email_sender,
      inject_user
        IMPORTING
          i_user TYPE REF TO zcl_wtcr_shop_user.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTH_WTCR_SHOP_FACTORY_INJECTOR IMPLEMENTATION.


  METHOD inject_email_sender.
    zcl_wtcr_shop_factory=>set_email_sender( i_email_sender ).
  ENDMETHOD.


  METHOD inject_payment_processor.
    zcl_wtcr_shop_factory=>set_payment_processor( i_payment_processor ).
  ENDMETHOD.


  METHOD inject_process_payment.
    zcl_wtcr_shop_factory=>set_process_payment( i_process_payment ).
  ENDMETHOD.


  METHOD inject_user.
    zcl_wtcr_shop_factory=>set_user( i_user ).
  ENDMETHOD.


  METHOD reset.
    zcl_wtcr_shop_factory=>reset( ).
  ENDMETHOD.
ENDCLASS.
