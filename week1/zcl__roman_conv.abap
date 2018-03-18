*> Exercise 1 - 
*     Write tests for ...
*           I, II, III, IX, CC, D, MMVII, empty string, space 
*           Exceptions: VV, AA, IIII, VX

* Error in the code: WHEN 'D'. r_arabic = 500. WAS NOT IMPLEMENTED

class ltc_roman2arabic DEFINITION FOR TESTING risk level HARMLESS duration SHORT. 
    public section. 
        CONSTANTS error TYPE i VALUE -1.  "zcl_wtcr_roman_converter=>error_value 

    private section. 
    DATA cut TYPE REF TO zcl_wtcr_roman_converter.

    methods setup. 
    methods Onein_1out              FOR TESTING RAISING cx_static_check. 

    methods check_val               importing pro type string par type i. 
    methods test_ex                 FOR TESTING RAISING cx_static_check. 
*    methods Twoin_2out              FOR TESTING RAISING cx_static_check. 
*    methods Threein_3out            FOR TESTING RAISING cx_static_check. 
*    methods Ninein_9out             FOR TESTING RAISING cx_static_check. 
*    methods TwoHundredin_200out     FOR TESTING RAISING cx_static_check. 
*    methods FiveHunin_500out        FOR TESTING RAISING cx_static_check. 
*    methods TwoThSevenn_2007out     FOR TESTING RAISING cx_static_check. 
*    methods emptyin_0out            FOR TESTING RAISING cx_static_check. 
*    methods Spacein_0out            FOR TESTING RAISING cx_static_check. 

endclass. 

class ltc_roman2arabic IMPLEMENTATION. 
    method Onein_1out. 
       " DATA(cut) = NEW zcl_wtcr_roman_converter( ). 
        DATA(arabic) = cut->to_arabic( i_roman_numeral = 'I' ). 
        cl_abap_unit_assert=>assert_equals( act = arabic exp = 1 ).
        " me->check_val( ero = 'I' ear = 1 ). 
    endmethod. 
  
    method setup.
        cut = NEW #( ).
    endmethod. 
    
    method check_val. 
        cl_abap_unit_assert=>assert_equals( act = cut->to_arabic( p_ro ) exp = par ).
    endmethod. 

    method test_ex. 
        "I, II, III, IX, CC, D, MMVII, empty string, space 
        me->check_val( ero = 'I'        ear = 1 ). 
        me->check_val( ero = 'II'       ear = 2 ). 
        me->check_val( ero = 'III'      ear = 3 ). 
        me->check_val( ero = 'IX'       ear = 9 ). 
        me->check_val( ero = 'CC'       ear = 50 ). 
        me->check_val( ero = 'MMVII'    ear = 2007 ). 
        me->check_val( ero = ''         ear = 0 ). 
        me->check_val( ero = ' '        ear = 0 ). 
        "Exceptions: VV, AA, IIII, VX
        me->check_val( ero = 'VV'       ear = error ). 
        me->check_val( ero = 'AA'       ear = error ). 
        me->check_val( ero = 'IIII'     ear = error ). 
        me->check_val( ero = 'VX'       ear = error ). 
    endmethod. 

endclass. 
" Control + Shift + F10 - run unit tests 