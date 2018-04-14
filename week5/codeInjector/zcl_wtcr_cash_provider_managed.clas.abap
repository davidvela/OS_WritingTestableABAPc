CLASS zcl_wtcr_cash_provider_managed DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE "dependency lookup
  GLOBAL FRIENDS zcl_wtcr_factory. "dependency lookup

  PUBLIC SECTION.
    INTERFACES zif_wtcr_cash_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_WTCR_CASH_PROVIDER_MANAGED IMPLEMENTATION.


  METHOD zif_wtcr_cash_provider~get_coins.
    "not usable right now
    ASSERT 0 = 1.
  ENDMETHOD.


  METHOD zif_wtcr_cash_provider~get_notes.
    "not usable right now
    ASSERT 0 = 1.
  ENDMETHOD.
ENDCLASS.
