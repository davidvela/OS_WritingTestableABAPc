*&---------------------------------------------------------------------*
*& Report Z_HELLO_WORLD_ABAP
*&---------------------------------------------------------------------*
*  Hello World in ABAP
*  Modifications: 
*     $1 - 20180101 - DVT - first change ...  
*---------------------------------------------------------------------*

report z_hello_world.

TYPES: BEGIN OF ty_hello,
         name     TYPE text50,
         surname  TYPE text50,
         pos      TYPE text50,
      END OF ty_hello.

*&--------------------------------------------------------------------*
*  Hello World CLASS
*---------------------------------------------------------------------*
CLASS zcl_helloworld DEFINITION
  CREATE PUBLIC .
  PUBLIC SECTION.
    CONSTANTS error_value TYPE i VALUE -1.
    DATA l_val TYPE string.
    METHODS sayhi  IMPORTING   i_name TYPE string   RETURNING VALUE(r_hi) TYPE string.
    METHODS get_data IMPORTING i_name TYPE string   RETURNING VALUE(r_val) TYPE ty_hello .
ENDCLASS.

CLASS zcl_helloworld IMPLEMENTATION.
  METHOD sayhi.
    "r_hi = 'Hello ' &&  i_name.
    r_hi = |Hello { i_name }|.
  ENDMETHOD.

  METHOD get_data.
    DATA: lt_data TYPE TABLE OF ty_kag.
    DATA: ls_data TYPE ty_kag.

    SELECT SINGLE c~name c~surname c~position "t~other 
      INTO ls_data
      FROM hello AS c " LEFT OUTER JOIN other AS t ON c~name = t~name 
      WHERE  c~name = i_name. 

   "Get BL reference and build a line with this data
    DATA(lo_data_contr) = cl_data_contr=>if_data_contr~factory( ).
    CASE ls_data-pos.
      WHEN 'pos_dev'.
        DATA(l_model) = if_bl=>co_modeltype-dev.
        DATA(lo_dev) = CAST bl_dev( lo_data_contr->get_reference( EXPORTING i_key1 = ls_data-name  i_type = l_model ) ) .
        " > get superior     
        ls_data-superior = lo_dev->if_bl_dev~get_header( )-superior.
        " get code
        lo_dev->get_code( IMPORTING e_cod  = ls_data-code ).
        " get personal no.
        ls_data-no_per = lines( lo_dev->if_bl_dev~get_assigned_team( ) ).
    WHEN other. 
    ENDCASE. 
    r_val = ls_data.
  ENDMETHOD.

ENDCLASS.

*&--------------------------------------------------------------------*
PARAMETERS: p_name TYPE text50 DEFAULT 'World'.
*&--------------------------------------------------------------------*
START-OF-SELECTION.
  DATA(cut) = NEW zcl_helloworld( ).
  CONCATENATE p_name '!'  INTO p_name.
  WRITE: 'Hello', p_name.
  WRITE: cut->get_data( 'david' )-name  .
*&--------------------------------------------------------------------*

*&--------------------------------------------------------------------*
*  Hello World UNIT TESTS shortcut: control + shift + F10
*---------------------------------------------------------------------*
CLASS ltc_hello DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
    " PRINCIPLES:
      "   F.I.R.S.T - Fast Independent Repetable Self-validating Timely
      "   KISS - Keep It Simple Stupid
      "   DRY - Don't Repeat Yourself.
  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_helloworld.
    METHODS setup.
    METHODS hi_david   FOR TESTING.
    METHODS hi_david_e FOR TESTING.
    METHODS get_data   FOR TESTING.
    METHODS get_data_e FOR TESTING.
ENDCLASS.

CLASS ltc_hello IMPLEMENTATION.
  METHOD setup.
    cut = NEW #( ). " CUT - Code Under Test
  ENDMETHOD.
  METHOD hi_david.
    cl_abap_unit_assert=>assert_equals( act = cut->sayhi( 'David' ) exp = 'Hello David' ).
  ENDMETHOD.
  METHOD hi_david_e.
    cl_abap_unit_assert=>assert_equals( act = cut->sayhi( 'Davi' ) exp = 'Hello David' ).
  ENDMETHOD.

  METHOD get_data.
    cl_abap_unit_assert=>assert_equals( act = cut->get_data( 'david' )
                                        exp = VALUE ty_hello( name = 'david'  surname = 'vela' pos = 'dev' )
    ).
  ENDMETHOD.

  METHOD get_data_e.
    cl_abap_unit_assert=>assert_equals( act = cut->get_data( 'david' )
                                        exp = VALUE ty_hello( name = 'davi'  surname = 'vela' pos = 'dev' )
    ).
  ENDMETHOD.

ENDCLASS.
