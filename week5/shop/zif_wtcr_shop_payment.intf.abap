INTERFACE zif_wtcr_shop_payment
  PUBLIC .
    METHODS pay
      IMPORTING
        i_email_sender   TYPE REF TO zif_wtcr_shop_email_sender
        i_value          TYPE f
      RETURNING
        VALUE(r_success) TYPE abap_bool .

endinterface.
