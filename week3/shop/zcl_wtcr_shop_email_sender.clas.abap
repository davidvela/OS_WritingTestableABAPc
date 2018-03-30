CLASS zcl_wtcr_shop_email_sender DEFINITION
  PUBLIC
  CREATE PROTECTED
  GLOBAL FRIENDS zcl_wtcr_shop_factory .

  PUBLIC SECTION.
    INTERFACES zif_wtcr_shop_email_sender.

ENDCLASS.



CLASS ZCL_WTCR_SHOP_EMAIL_SENDER IMPLEMENTATION.


  METHOD zif_wtcr_shop_email_sender~send.
    DATA:
      mail_subject    TYPE sodocchgi1,
      mail_recipients TYPE STANDARD TABLE OF somlrec90,
      mail_recipient  LIKE LINE OF mail_recipients,
      mail_texts      TYPE STANDARD TABLE OF soli,
      mail_text       LIKE LINE OF mail_texts.
    "Recipients
    DATA(user) = zcl_wtcr_shop_factory=>get_user( ).
    DATA(user_email) = user->get_email( ).

    mail_recipient-rec_type  = 'U'.
    mail_recipient-receiver = user_email.
    APPEND mail_recipient TO mail_recipients .

    "Subject.
    mail_subject-obj_name = 'TEST'.
    mail_subject-obj_langu = sy-langu.
    mail_subject-obj_descr = i_subject.
    "Mail Contents
    "mail_text = i_body.
    "APPEND mail_text TO mail_texts.
    APPEND LINES OF i_body TO mail_texts.

    "Send Mail
    CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
      EXPORTING
        document_data              = mail_subject
      TABLES
        object_content             = mail_texts
        receivers                  = mail_recipients
      EXCEPTIONS
        too_many_receivers         = 1
        document_not_sent          = 2
        document_type_not_exist    = 3
        operation_no_authorization = 4
        parameter_error            = 5
        x_error                    = 6
        enqueue_error              = 7
        OTHERS                     = 8.
    IF sy-subrc EQ 0.
      COMMIT WORK.
      "Push mail out from SAP outbox
      SUBMIT rsconn01 WITH mode = 'INT' AND RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
