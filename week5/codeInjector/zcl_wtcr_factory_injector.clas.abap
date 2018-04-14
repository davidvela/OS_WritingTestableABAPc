CLASS zcl_wtcr_factory_injector DEFINITION FOR TESTING "secure access only in test
  PUBLIC
  FINAL
  CREATE PRIVATE. "static class

  PUBLIC SECTION.
    CLASS-METHODS inject_cash_provider
      IMPORTING i_cash_provider TYPE REF TO zif_wtcr_cash_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_WTCR_FACTORY_INJECTOR IMPLEMENTATION.


  METHOD inject_cash_provider.
    zcl_wtcr_factory=>g_cash_provider = i_cash_provider.
  ENDMETHOD.
ENDCLASS.
