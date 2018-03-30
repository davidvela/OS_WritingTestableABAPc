CLASS zcl_wtcr_shop_catalog DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS:
      constructor,
      get_catalog
        RETURNING
          VALUE(r_catalog) TYPE zase_shop_item_table,
      get_item
        IMPORTING i_id      TYPE int4
        RETURNING VALUE(r_item) TYPE zase_shop_item
        .

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA:
      m_items TYPE zase_shop_item_table.    "-- should be read-only but cannot because of ALV

    METHODS:
      gen_local_test_data
      .
ENDCLASS.



CLASS ZCL_WTCR_SHOP_CATALOG IMPLEMENTATION.


  METHOD constructor.
    "-- Testability comment: Initially the constructor was generating the test data.
    " But that is bad design for testability. In a test we will want to create
    " different catalog items to test the catalog. In general one should not create
    " collaborators in the constructor (except through a factory).
    "gen_local_test_data( ).
  ENDMETHOD.


  METHOD gen_local_test_data.
    "-- Build up initial item list
    m_items = VALUE #(
      ( id = '111' category = 'Books'     name = 'Refactoring'          price = '59.99'  )
      ( id = '137' category = 'Household' name = 'Iron'                 price = '49.65'  )
      ( id = '250' category = 'DVDs'      name = 'Narnia'               price = '12.99'  )
      ( id = '270' category = 'Books'     name = 'Moby Dick'            price = '15.66'  )
      ( id = '362' category = 'Books'     name = 'Domain Driven Design' price = '39.99'  )
      ( id = '365' category = 'Gardening' name = 'Waterhose'            price = '15.66'  )
      ( id = '368' category = 'DVDs'      name = 'Couragous'            price = '10.99'  )
      ( id = '458' category = 'Computers' name = 'Screen'               price = '215.55' )
      ( id = '570' category = 'DVDs'      name = 'Superman'             price = '16.99'  )
      ( id = '964' category = 'Computers' name = 'Mouse'                price = '5.66'   )
    ).
  ENDMETHOD.


  METHOD get_catalog.
    "-- The catalog is used only for demo purposes and has fixed content. Fill it on first call.
    if LINES( m_items ) = 0.
      gen_local_test_data( ).
    endif.
    r_catalog = m_items.
  ENDMETHOD.


  METHOD get_item.
    READ TABLE m_items INTO r_item WITH KEY id = i_id.
  ENDMETHOD.
ENDCLASS.
