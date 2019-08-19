*&---------------------------------------------------------------------*
*& Report Z_009_PROTOTYPE_V1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_009_PROTOTYPE_V1.

CLASS lcl_request DEFINITION INHERITING FROM cl_os_state.
  PUBLIC SECTION.
    ALIASES: clone FOR if_os_clone~clone.
    TYPES:
      BEGIN OF ty_request_state,
        request_id  TYPE i,
        entity_id   TYPE i,
        request_data  TYPE string,
      END OF ty_request_state.
    METHODS:
      constructor IMPORTING iv_entity_id  TYPE i
                            iv_skip_init  TYPE abap_bool OPTIONAL,
      get_state   RETURNING VALUE(rs_state) TYPE ty_request_state.
  PRIVATE SECTION.
    DATA:
          ms_request_data TYPE ty_request_state.
ENDCLASS.

CLASS lcl_request IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).

    CHECK iv_skip_init = abap_false.
    WAIT UP TO 3 SECONDS.
    " В реальности было бы что-то вроде
    " CALL FUNCTION 'ZGET_DATA_FROM_RFC'
    " EXPORTING
    "   iv_entity_id = iv_entity_id
    " IMPORTING
    "   es_request_data = ms_request_data
    ms_request_data-entity_id = iv_entity_id.
    ms_request_data-request_data = 'Sample data'.
    ms_request_data-request_id = 1.
  ENDMETHOD.

  METHOD get_state.
    rs_state = ms_request_data.
  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.
  DATA:
        lo_request  TYPE REF TO lcl_request,
        ls_state    TYPE lcl_request=>ty_request_state,
        lo_clone    TYPE REF TO lcl_request.

  CREATE OBJECT lo_request
    EXPORTING
      iv_entity_id = 1.

  ls_state = lo_request->get_state( ).
  WRITE: / ls_state-entity_id, ls_state-request_data, ls_state-request_id.

  " Повторный вызов конструктора приведет к задержке при инициализации
  " воспользуемся методом клонирования

  lo_clone ?= lo_request->clone( ).
  ls_state = lo_clone->get_state( ).

  WRITE: / 'Клоник:', ls_state-entity_id, ls_state-request_data, ls_state-request_id.
