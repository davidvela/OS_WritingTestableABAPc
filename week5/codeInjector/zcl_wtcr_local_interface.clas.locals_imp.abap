INTERFACE lif_cash_provider.  "provide testability

  METHODS get_notes
    IMPORTING i_currency      TYPE string
    RETURNING VALUE(r_change) TYPE zcl_wtcr_cash_provider_static=>tt_change.

ENDINTERFACE.

* _____________________________________________________________________________

CLASS lcl_cash_provider DEFINITION.  "provide testability
  PUBLIC SECTION.
    INTERFACES lif_cash_provider.
ENDCLASS.


CLASS lcl_cash_provider IMPLEMENTATION.

  METHOD lif_cash_provider~get_notes.
    r_change = zcl_wtcr_cash_provider_static=>get_notes( i_currency = i_currency ).
  ENDMETHOD.

ENDCLASS.
