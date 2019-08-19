*&---------------------------------------------------------------------*
*& Report Z_014_CHAIN_OF_RESPONSIBILITY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_014_CHAIN_OF_RESPONSIBILITY.

CLASS lcl_message_handler DEFINITION ABSTRACT.
  PUBLIC SECTION.
    TYPES:
      ty_priority TYPE i.
    CONSTANTS:
      gc_error_msg    TYPE ty_priority VALUE 1,
      gc_warning_msg  TYPE ty_priority VALUE 2,
      gc_notice_msg   TYPE ty_priority VALUE 3.
    DATA:
          mv_mask TYPE ty_priority,
          mo_next TYPE REF TO lcl_message_handler.
    METHODS:
      constructor IMPORTING io_next TYPE REF TO lcl_message_handler OPTIONAL
                            iv_mask TYPE ty_priority,
      write_message IMPORTING iv_message TYPE string
                              iv_priority TYPE ty_priority.
  PROTECTED SECTION.
    METHODS:
      write_message_int ABSTRACT IMPORTING iv_message TYPE string.
ENDCLASS.

CLASS lcl_write_handler DEFINITION INHERITING FROM lcl_message_handler.
  PROTECTED SECTION.
    METHODS:
      write_message_int REDEFINITION.
ENDCLASS.

CLASS lcl_log_handler DEFINITION INHERITING FROM lcl_message_handler.
  PROTECTED SECTION.
    METHODS:
      write_message_int REDEFINITION.
ENDCLASS.

CLASS lcl_email_handler DEFINITION INHERITING FROM lcl_message_handler.
  PROTECTED SECTION.
    METHODS:
      write_message_int REDEFINITION.
ENDCLASS.

*&---------------------------------------------------------------------*
*&  Реализация классов
*&---------------------------------------------------------------------*

CLASS lcl_message_handler IMPLEMENTATION.

  METHOD constructor.
    mo_next = io_next.
    mv_mask = iv_mask.
  ENDMETHOD.

  METHOD write_message.
    IF iv_priority <= mv_mask.
      write_message_int( iv_message ).
    ENDIF.

    CHECK mo_next IS BOUND.

    mo_next->write_message(
      EXPORTING
        iv_message = iv_message
        iv_priority = iv_priority
        ).
  ENDMETHOD.

ENDCLASS.

CLASS lcl_write_handler IMPLEMENTATION.
  METHOD write_message_int.
    WRITE: / 'Write notice: ', iv_message.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_log_handler IMPLEMENTATION.
  METHOD write_message_int.
    WRITE: / 'Write to log: ', iv_message.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_email_handler IMPLEMENTATION.
  METHOD write_message_int.
    WRITE: / 'Sendto email: ', iv_message.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*&  Работа с шаблоном
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  DATA:
        lo_write_handler  TYPE REF TO lcl_write_handler,
        lo_log_handler    TYPE REF TO lcl_log_handler,
        lo_email_handler  TYPE REF TO lcl_email_handler.

  CREATE OBJECT lo_email_handler
    EXPORTING
      iv_mask = lcl_message_handler=>gc_error_msg.

  CREATE OBJECT lo_log_handler
    EXPORTING
      io_next = lo_email_handler
      iv_mask = lcl_message_handler=>gc_warning_msg.

  CREATE OBJECT lo_write_handler
    EXPORTING
      io_next = lo_log_handler
      iv_mask = lcl_message_handler=>gc_notice_msg.

  lo_write_handler->write_message(
    EXPORTING
      iv_message = 'Ошибка обрабатывается всеми обработчиками'
      iv_priority = lcl_message_handler=>gc_error_msg
      ).

  ULINE.

  lo_write_handler->write_message(
    EXPORTING
      iv_message = 'Ошибка обрабатывается только Write обработчиком'
      iv_priority = lcl_message_handler=>gc_notice_msg
      ).

  ULINE.

  lo_write_handler->write_message(
    iv_message = 'Ошибка обрабатывается только Write и Log обработчиками'
    iv_priority = lcl_message_handler=>gc_warning_msg
    ).
