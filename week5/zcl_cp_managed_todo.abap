class ZCL_WTC_CASH_PROVIDER_MANAGED definition
  public
  final
  create public .

public section.

  interfaces ZIF_WTC_CASH_PROVIDER .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_WTC_CASH_PROVIDER_MANAGED IMPLEMENTATION.


  METHOD ZIF_WTC_CASH_PROVIDER~get_coins.
    "not usable right now
    ASSERT 0 = 1.
  ENDMETHOD.


  METHOD ZIF_WTC_CASH_PROVIDER~get_notes.
    "not usable right now
    ASSERT 0 = 1.
  ENDMETHOD.
ENDCLASS.
