INTERFACE zif_wtcr_shop_email_sender
  PUBLIC .
  TYPES:
    ty_texts TYPE STANDARD TABLE OF soli.

  METHODS send
    IMPORTING
      i_subject TYPE string
      i_body    TYPE ty_texts.
ENDINTERFACE.
