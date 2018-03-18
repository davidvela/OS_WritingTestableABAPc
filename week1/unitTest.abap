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