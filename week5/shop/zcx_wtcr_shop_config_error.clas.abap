CLASS zcx_wtcr_shop_config_error DEFINITION
  PUBLIC
  INHERITING FROM cx_no_check
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    CONSTANTS:
      BEGIN OF total_should_not_be_to_one,
        msgid TYPE symsgid VALUE '/ASU/XML_MAINTAIN',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF total_should_not_be_to_one .

    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCX_WTCR_SHOP_CONFIG_ERROR IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
