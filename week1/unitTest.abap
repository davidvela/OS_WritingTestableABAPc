*&---------------------------------------------------------------------*
*& Report Z_HELLO_WORLD_ABAP
*&---------------------------------------------------------------------*
*  Hello World in ABAP
*  Modifications: 
*     $1 - 20180101 - DVT - first change ...  
*---------------------------------------------------------------------*
report z_hello_world.

parameters: p_name type text50 default 'World'.

start-of-selection.

  concatenate p_name '!' into p_name.
  write: 'Hello', p_name.

*&--------------------------------------------------------------------*
*  Hello World CLASS
*---------------------------------------------------------------------*
CLASS zcl_helloWorld DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS sayHi  IMPORTING  i_name TYPE string   RETURNING VALUE(r_hi) TYPE string.
    CONSTANTS error_value TYPE i VALUE -1.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_helloWorld IMPLEMENTATION.
  METHOD sayHi.
    r_hi = 'Hello ' &&  p_name.
  ENDMETHOD.
ENDCLASS. 
*&--------------------------------------------------------------------*
*  Hello World UNIT TESTS
*---------------------------------------------------------------------*
* CUT - Code Under Test
* F.I.R.S.T - Fast Independent Repetable Self-validating Timely
* KISS - Keep It Simple Stupid
* DRY - Don't Repeat Yourself.


CLASS ltc_hello DEFINITION FOR TESTING risk level HARMLESS duration SHORT. 
  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_helloWorld.
    METHODS setup.
    METHODS hi_David
ENDCLASS. 
CLASS ltc_hello IMPLEMENTATION. 
  METHOD setup.
    cut = NEW #( ).  
  ENDMETHOD.
  METHOD hi_David.
    data(msg) = cut->sayHi( 'David' ). 
    cl_abap_unit_assert=>assert_equals( act = cut->sayHi( 'David' ) exp = 'Hello David' ).
  ENDMETHOD.
ENDCLASS. 