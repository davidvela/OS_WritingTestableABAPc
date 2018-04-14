CLASS zcl_wtcr_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE "factory is static
  GLOBAL FRIENDS zcl_wtcr_factory_injector. "injector is friend

  PUBLIC SECTION.
    CLASS-METHODS cash_provider
      RETURNING VALUE(r_object) TYPE REF TO zif_wtcr_cash_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA g_cash_provider TYPE REF TO zif_wtcr_cash_provider.
ENDCLASS.



CLASS ZCL_WTCR_FACTORY IMPLEMENTATION.


  METHOD cash_provider.
    IF g_cash_provider IS NOT BOUND.
      g_cash_provider = NEW zcl_wtcr_cash_provider_managed( ).
    ENDIF.
    r_object = g_cash_provider.
  ENDMETHOD.
ENDCLASS.
