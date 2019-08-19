*&---------------------------------------------------------------------*
*& Report Z_001_DEMO_REF
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_001_DEMO_REF.

TYPES c1 TYPE c LENGTH 1.

DATA: dref         TYPE REF TO c1,
      dref_tab     LIKE TABLE OF dref WITH EMPTY KEY,
      dref_tab_new LIKE dref_tab.

DATA: text TYPE c LENGTH 10 VALUE '0123456789',
      off  TYPE i.

DO 10 TIMES.
  off = sy-index - 1.
  GET REFERENCE OF text+off(1) INTO dref.
  APPEND dref TO dref_tab.
ENDDO.

LOOP AT dref_tab INTO dref.
  cl_demo_output=>write( |{ dref->* }| ).
ENDLOOP.

READ TABLE dref_tab INTO DATA(dref1) INDEX 1.
cl_demo_output=>display( dref1 ).

dref_tab_new = VALUE #(
  FOR j = 0 UNTIL j > 9 ( REF #( text+j(1) ) ) ).
*DELETE dref_tab WHERE table_line IS NOT INITIAL.
ASSERT dref_tab_new = dref_tab.
BREAK-POINT.
""""
""""
""""dfkjfbkjdbjdhbfjbfjbjgb
""""
""""
