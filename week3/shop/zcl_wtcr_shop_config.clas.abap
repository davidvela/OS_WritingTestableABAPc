CLASS zcl_wtcr_shop_config DEFINITION
  PUBLIC FINAL CREATE PUBLIC .
  "---------------------------------------------------------
  "-- Offers key-value pair store for global configuration.
  "-- Data type for both is string.

  PUBLIC SECTION.
    METHODS constructor.
    METHODS:
      read_config_tuple
        IMPORTING
          i_name        TYPE string
        RETURNING
          VALUE(r_value) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mt_ase_shop_configs TYPE TABLE OF zase_shop_config.
ENDCLASS.



CLASS ZCL_WTCR_SHOP_CONFIG IMPLEMENTATION.


  METHOD constructor.
    SELECT * FROM zase_shop_config INTO TABLE @mt_ase_shop_configs.
  ENDMETHOD.


  METHOD read_config_tuple.
    TRY.
        r_value = mt_ase_shop_configs[ name = i_name ]-value.
      CATCH cx_sy_itab_line_not_found.
        RAISE EXCEPTION TYPE zcx_wtcr_shop_config_error.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
