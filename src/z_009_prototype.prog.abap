*&---------------------------------------------------------------------*
*& Report Z_009_PROTOTYPE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_009_PROTOTYPE.

INTERFACE lif_clonable.
  METHODS:
    clone RETURNING VALUE(ro_clone) TYPE REF TO lif_clonable.
ENDINTERFACE.

CLASS lcl_request DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_clonable.
    ALIASES clone FOR lif_clonable~clone.
    TYPES:
      BEGIN OF ty_request_state,
        request_id    TYPE i,
        entity_id     TYPE i,
        request_data  TYPE string,
      END OF ty_request_state.
    METHODS:
      constructor IMPORTING iv_entity_id TYPE i
                            is_state TYPE ty_request_state OPTIONAL,
      get_state   RETURNING VALUE(rs_state) TYPE ty_request_state.
  PRIVATE SECTION.
    DATA
          ms_request_data TYPE ty_request_state.
ENDCLASS.

CLASS lcl_request IMPLEMENTATION.
  METHOD constructor.
    IF is_state IS SUPPLIED.
      ms_request_data = is_state.
      RETURN.
    ENDIF.

    " Эмулируем вызов RFC
    " Для упрощения инициализация происходит прямо в конструкторе
    " (запрос лучше отправлять в отдельном методе,
    " а конструктор оставить только для присвоения состояния).
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

  METHOD clone.
    DATA lo_clone TYPE REF TO lcl_request.

    CREATE OBJECT lo_clone
      EXPORTING
        iv_entity_id = 0
        is_state = me->get_state( ).

    ro_clone = lo_clone.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*&  Работа с прототипом
*&---------------------------------------------------------------------*

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

  WRITE: / 'Клон тут:', ls_state-entity_id, ls_state-request_data, ls_state-request_id.
