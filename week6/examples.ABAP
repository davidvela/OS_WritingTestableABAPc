*> EXAMPLES FROM THE SLIDES: 
********************************

*> ABAP TEST DOUBLE FRAMEWORK 
*   - Standardized solution, (automatic creation of td)
*   Step 1: 
test_double ?= cl_abap_testduble=>create('if_some_global_interface')
*   Steo 2: 
cl_abap_testduble=>configure_call(test double
        )->returning(abap_true
        )->ignoring_all_parameters(
        )->and expect(
        )->is_called_once(). 
*   Step 3: 
test_double->method_to_double( 
        EXPORTING   i_parameter_1 = 0 
                    i_parameter_2 = abap_true ). 

*> OPEN SQL TEST FRAMEWORK 
*       - testing SQL statements, testing SQL logic written inside dev. objects.
DATA m_table_1 TYPE STANDARD TABLE OF table_1. 
* ... 
METHOD class_setup. 
    g_environment = cl_osql_test_environment=>create( 
        i_dependency_list_entity = VALUE #(('table_1')). 
ENDMETHOD. 

METHOD class_teardown. 
    g_environment->destroy(). 
ENDMETHOD. 

METHOD setup. 
    g_environment->clear_doubles(). 
ENDMETHOD. 

METHOD some_test_method. 
    " given 
    m_table_1 = VALUE #( ). 
    g_environment->insert_test_data(m_table). 
    "when 
    DATA(result) = m_cut->method_with_db_statements(). 
    "then 
    cl_abap_unit_asset=>assert_equals( act=result exp=1 ). 
ENDMETHOD.

*> CORE DATA SERVICE (CDS) 
*      - double depended components (tables, views, cds vies ... )
 DATA m_table_1 TYPE STANDARD TABLE OF table_1. 
 "... 
 METHOD class_setup. 
    g_environment= cl_cds_test_environment=>create(
                    i_for_entity = 'CDS_under_test'). 
ENDMETHOD. 

METHOD class_teardown. 
    g_environment->destroy(). 
ENDMETHOD.  

METHOD setup.
    g_environment->clear_doubles(). 
ENDMETHOD. 

METHOD some_test_method. 
    "given 
    m_table_1 = VALUE #(...).
    g_environment->insert_test_data(m_table_1). 
    "when  
    SELECT field FROM CDS_under_test 
        into @DATA(act_tab). 
    "then 
    cl_abap_unit_asset=>assert_equals( act = act_tab exp=m_exp_tab). 
ENDMETHOD. 

*> ABAP TEST SEAMS 
*       - exchange code snippets of p.code with test double code

***> product code 
    ... 
    AUTHORIT-CHECK OBJECT 'S_ANY' ID 'SABC' FIELD 'TABL'. 
    TEST-SEAM manipulate_authority. 
    END-TEST-SEAM. 

    IF sy-subrc <> 0. ... ENDIF. 

    TEST-SEAM remove_unwanted_statement. 
        CALL FUNCTION 'SOMETHING_WE_DONT_WANT_IN_THE_TEST'. 
    END-TEST-SEAM. 
    ... 
***> test code 
    ... 
    TEST-INJECTION manipulate_authority. 
        sy-subrc = 0 . 
    END-TEST-INJECTION. 
    
    TEST-INJECTION remove_unwanted_statement.
        " empty injection.  
    END-TEST-INJECTION. 
