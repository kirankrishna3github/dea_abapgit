*&---------------------------------------------------------------------*
*& Report ZF4_GUI_HELP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zf4_gui_help.

DATA:
  gt_spfli   TYPE spfli_tab,   " Вн. таблица из которой происходит выбор данных
  gt_res_tab TYPE spfli_tab, " Данные с выбранными значениями
  go_f4      TYPE REF TO cl_reca_gui_f4_popup.

PARAMETERS: p_test TYPE spfli-connid.

INITIALIZATION.
  SELECT * FROM spfli INTO CORRESPONDING FIELDS OF TABLE gt_spfli.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_test.
  PERFORM get_help.

FORM get_help.
  FIELD-SYMBOLS: <fs_rec> TYPE spfli.
  CLEAR gt_res_tab.
  IF go_f4 IS NOT BOUND.
    go_f4 = cl_reca_gui_f4_popup=>factory_grid(
      id_title   = 'Заголовок'  " Заголовок окна
      if_multi   = abap_false   " Единичный выбор
      it_f4value = gt_spfli     " Вн. таблица с данными
    ).
  ENDIF.
  go_f4->display( IMPORTING et_result = gt_res_tab ).
  READ TABLE gt_res_tab INDEX 1 ASSIGNING <fs_rec>.
  CHECK sy-subrc EQ 0 AND <fs_rec> IS ASSIGNED.
  p_test = <fs_rec>-connid.
ENDFORM.
