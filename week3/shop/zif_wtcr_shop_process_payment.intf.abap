INTERFACE zif_wtcr_shop_process_payment
  PUBLIC.

  METHODS process
    IMPORTING VALUE(i_username) TYPE syst_uname
              VALUE(i_value)    TYPE f
    RETURNING VALUE(r_success)  TYPE abap_bool.

ENDINTERFACE.
