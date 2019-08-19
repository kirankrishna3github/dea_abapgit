*&---------------------------------------------------------------------*
*& Report Z_002_SELECT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_002_select.

TABLES: spfli.
DATA gt_spfli TYPE TABLE OF spfli.
DATA go_alv   TYPE REF TO cl_salv_table.
*DATA table TYPE TABLE OF s_table.

""
""БУду редачить тут
""

START-OF-SELECTION.

*  PARAMETERS pa_c_id TYPE spfli-carrid.

  SELECT-OPTIONS pa_c_id FOR spfli-carrid NO INTERVALS.
*  SELECT-OPTIONS pa_cy_f FOR spfli-carrid NO INTERVALS.
*  SELECT-OPTIONS pa_cy_t FOR spfli-carrid NO INTERVALS.


  SELECT  carrid
          connid
          cityfrom
          airpfrom
          cityto
          airpto
          fltime
          deptime
          arrtime
          distance
    INTO CORRESPONDING FIELDS OF TABLE gt_spfli
    FROM spfli
*  FOR ALL ENTRIES IN pa_c_id
    WHERE carrid IN pa_c_id.
*    AND cityfrom IN pa_cy_f
*    AND cityto IN pa_cy_t.


  TRY.
      cl_salv_table=>factory(
         IMPORTING
           r_salv_table = go_alv
         CHANGING
           t_table = gt_spfli ).
    CATCH cx_salv_msg .
      MESSAGE 'Ошибка при создании ALV' TYPE 'E'.
  ENDTRY.
  " Отобразить ALV представление
  go_alv->display( ).


*END-of-SELECTION.
*
*LOOP AT s_table ASSIGNING FIELD-SYMBOL(<ls_tab>).
*  WRITE <ls_tab>-CARRID.
*ENDLOOP.

*select *
*  INTO TABLE s_table
*  FROM spfli.
*BREAK-POINT.
