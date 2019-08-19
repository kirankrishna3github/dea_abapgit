*&---------------------------------------------------------------------*
*& Report Z_013_MEDIATOR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_013_MEDIATOR.

CLASS lcl_mediator DEFINITION DEFERRED.

CLASS lcl_invoker DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_name TYPE string
                            io_mediator TYPE REF TO lcl_mediator,
      receive_message IMPORTING iv_message  TYPE string
                                iv_from     TYPE string,
      send_message IMPORTING iv_message TYPE string,
      get_name     RETURNING VALUE(rv_name) TYPE string.
  PRIVATE SECTION.
    DATA:
          mv_name TYPE string,
          mo_mediator TYPE REF TO lcl_mediator.
ENDCLASS.

CLASS lcl_mediator DEFINITION.
  PUBLIC SECTION.
    METHODS:
      add_client IMPORTING io_client TYPE REF TO lcl_invoker,
      send_message IMPORTING iv_message TYPE string
                             io_sender TYPE REF TO lcl_invoker.
  PRIVATE SECTION.
    DATA: mt_receivers TYPE TABLE OF REF TO lcl_invoker.
ENDCLASS.


*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""*
*" Реализация классов                                                         "*
*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""*
CLASS lcl_mediator IMPLEMENTATION.
  METHOD add_client.
    APPEND io_client TO mt_receivers.
  ENDMETHOD.

  METHOD send_message.
    DATA: lo_reciever TYPE REF TO lcl_invoker.

    LOOP AT mt_receivers INTO lo_reciever WHERE TABLE_LINE <> io_sender.
      lo_reciever->receive_message( iv_message = iv_message iv_from = io_sender->get_name( ) ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_invoker IMPLEMENTATION.

  METHOD constructor.
    mv_name = iv_name.
    mo_mediator = io_mediator.
  ENDMETHOD.

  METHOD receive_message.
    DATA(new_line) = cl_abap_char_utilities=>newline.
    WRITE: / mv_name, ' receive message:', new_line, iv_message, 'from:', iv_from.
  ENDMETHOD.

  METHOD send_message.
    mo_mediator->send_message( iv_message = iv_message io_sender = me ).
  ENDMETHOD.

  METHOD get_name.
    rv_name = mv_name.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  DATA:
        lo_invoker1 TYPE REF TO lcl_invoker,
        lo_invoker2 TYPE REF TO lcl_invoker,
        lo_mediator TYPE REF TO lcl_mediator.

  CREATE OBJECT lo_mediator.

  CREATE OBJECT lo_invoker1
    EXPORTING
      iv_name = 'John'
      io_mediator = lo_mediator.

  CREATE OBJECT lo_invoker2
    EXPORTING
      iv_name = 'Mike'
      io_mediator = lo_mediator.

  lo_mediator->add_client( lo_invoker1 ).
  lo_mediator->add_client( lo_invoker2 ).

  lo_invoker1->send_message( 'Hi to all!' ).
  lo_invoker2->send_message( 'Hi!' ).
*  BREAK-POINT.
