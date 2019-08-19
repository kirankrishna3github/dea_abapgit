*&---------------------------------------------------------------------*
*& Report Z_018_OBSERVER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_018_OBSERVER.

CLASS lcl_observer DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      update ABSTRACT IMPORTING iv_data TYPE string.
ENDCLASS.

CLASS lcl_concrete_observer DEFINITION INHERITING FROM lcl_observer.
  PUBLIC SECTION.
    METHODS:
      update REDEFINITION.
ENDCLASS.

CLASS lcl_concrete_observer IMPLEMENTATION.
  METHOD update.
    WRITE: / 'Update: ', iv_data.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_subject DEFINITION.
  PUBLIC SECTION.
    METHODS:
      attach_observer IMPORTING io_observer TYPE REF TO lcl_observer,
      raise_event.
  PRIVATE SECTION.
    DATA:
          mt_observers TYPE STANDARD TABLE OF REF TO lcl_observer.
ENDCLASS.

CLASS lcl_subject IMPLEMENTATION.
  METHOD attach_observer.
    APPEND io_observer TO mt_observers.
  ENDMETHOD.

  METHOD raise_event.
    DATA:
          lo_observer TYPE REF TO lcl_observer.

    LOOP AT mt_observers INTO lo_observer.
      DATA(test1) = |{ sy-tabix }|.
      DATA(test2) = sy-tabix.
      DATA(test3) = |( sy-tabix )|.
      DATA(test4) = | sy-tabix |.
      lo_observer->update( |{ sy-tabix }| ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  DATA:
        lo_subject TYPE REF TO lcl_subject,
        lo_observer TYPE REF TO lcl_concrete_observer.

  CREATE OBJECT lo_subject.

  CREATE OBJECT lo_observer.
  lo_subject->attach_observer( lo_observer ).
  CREATE OBJECT lo_observer.
  lo_subject->attach_observer( lo_observer ).
    CREATE OBJECT lo_observer.
  lo_subject->attach_observer( lo_observer ).
    CREATE OBJECT lo_observer.
  lo_subject->attach_observer( lo_observer ).

  lo_subject->raise_event( ).
