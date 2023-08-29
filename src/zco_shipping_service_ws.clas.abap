class ZCO_SHIPPING_SERVICE_WS definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods SHIPPING_WITH_RESERVATION_V2
    importing
      !SHIPPING_WITH_RESERVATION_V2 type ZSHIPPING_WITH_RESERVATION_V22
    exporting
      !SHIPPING_WITH_RESERVATION_V2RE type ZSHIPPING_WITH_RESERVATION_V21
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_WITH_RESERVATION_AND1
    importing
      !SHIPPING_WITH_RESERVATION_AND1 type ZSHIPPING_WITH_RESERVATION_AN7
    exporting
      !SHIPPING_WITH_RESERVATION_AND type ZSHIPPING_WITH_RESERVATION_AN4
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_WITH_RESERVATION_AND
    importing
      !SHIPPING_WITH_RESERVATION_AND1 type ZSHIPPING_WITH_RESERVATION_AN6
    exporting
      !SHIPPING_WITH_RESERVATION_AND type ZSHIPPING_WITH_RESERVATION_AN5
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_WITH_RESERVATION
    importing
      !SHIPPING_WITH_RESERVATION type ZSHIPPING_WITH_RESERVATION1
    exporting
      !SHIPPING_WITH_RESERVATION_RESP type ZSHIPPING_WITH_RESERVATION_RE1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_WITH_ESDONLY_V2
    importing
      !SHIPPING_WITH_ESDONLY_V2 type ZSHIPPING_WITH_ESDONLY_V21
    exporting
      !SHIPPING_WITH_ESDONLY_V2RESPON type ZSHIPPING_WITH_ESDONLY_V2RESP1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_WITH_ESDONLY
    importing
      !SHIPPING_WITH_ESDONLY type ZSHIPPING_WITH_ESDONLY1
    exporting
      !SHIPPING_WITH_ESDONLY_RESPONSE type ZSHIPPING_WITH_ESDONLY_RESPON1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_V7
    importing
      !SHIPPING_V7 type ZSHIPPING_V71
    exporting
      !SHIPPING_V7RESPONSE type ZSHIPPING_V7RESPONSE1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_V6
    importing
      !SHIPPING_V6 type ZSHIPPING_V61
    exporting
      !SHIPPING_V6RESPONSE type ZSHIPPING_V6RESPONSE1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_V5
    importing
      !SHIPPING_V5 type ZSHIPPING_V51
    exporting
      !SHIPPING_V5RESPONSE type ZSHIPPING_V5RESPONSE1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_V4
    importing
      !SHIPPING_V4 type ZSHIPPING_V41
    exporting
      !SHIPPING_V4RESPONSE type ZSHIPPING_V4RESPONSE1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_V3
    importing
      !SHIPPING_V3 type ZSHIPPING_V31
    exporting
      !SHIPPING_V3RESPONSE type ZSHIPPING_V3RESPONSE1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_V2
    importing
      !SHIPPING_V2 type ZSHIPPING_V21
    exporting
      !SHIPPING_V2RESPONSE type ZSHIPPING_V2RESPONSE1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_MULTI_PARCEL_WITH_RES
    importing
      !SHIPPING_MULTI_PARCEL_WITH_RE1 type ZSHIPPING_MULTI_PARCEL_WITH_R7
    exporting
      !SHIPPING_MULTI_PARCEL_WITH_RES type ZSHIPPING_MULTI_PARCEL_WITH_R6
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_MULTI_PARCEL_WITH_RE2
    importing
      !SHIPPING_MULTI_PARCEL_WITH_RE1 type ZSHIPPING_MULTI_PARCEL_WITH_11
    exporting
      !SHIPPING_MULTI_PARCEL_WITH_RES type ZSHIPPING_MULTI_PARCEL_WITH_10
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_MULTI_PARCEL_WITH_RE1
    importing
      !SHIPPING_MULTI_PARCEL_WITH_RE1 type ZSHIPPING_MULTI_PARCEL_WITH_R9
    exporting
      !SHIPPING_MULTI_PARCEL_WITH_RES type ZSHIPPING_MULTI_PARCEL_WITH_R8
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_MULTI_PARCEL_V6
    importing
      !SHIPPING_MULTI_PARCEL_V6 type ZSHIPPING_MULTI_PARCEL_V61
    exporting
      !SHIPPING_MULTI_PARCEL_V6RESPON type ZSHIPPING_MULTI_PARCEL_V6RESP1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_MULTI_PARCEL_V5
    importing
      !SHIPPING_MULTI_PARCEL_V5 type ZSHIPPING_MULTI_PARCEL_V51
    exporting
      !SHIPPING_MULTI_PARCEL_V5RESPON type ZSHIPPING_MULTI_PARCEL_V5RESP1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_MULTI_PARCEL_V4
    importing
      !SHIPPING_MULTI_PARCEL_V4 type ZSHIPPING_MULTI_PARCEL_V41
    exporting
      !SHIPPING_MULTI_PARCEL_V4RESPON type ZSHIPPING_MULTI_PARCEL_V4RESP1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_MULTI_PARCEL_V3
    importing
      !SHIPPING_MULTI_PARCEL_V3 type ZSHIPPING_MULTI_PARCEL_V31
    exporting
      !SHIPPING_MULTI_PARCEL_V3RESPON type ZSHIPPING_MULTI_PARCEL_V3RESP1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_MULTI_PARCEL_V2
    importing
      !SHIPPING_MULTI_PARCEL_V2 type ZSHIPPING_MULTI_PARCEL_V21
    exporting
      !SHIPPING_MULTI_PARCEL_V2RESPON type ZSHIPPING_MULTI_PARCEL_V2RESP1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING_MULTI_PARCEL
    importing
      !SHIPPING_MULTI_PARCEL type ZSHIPPING_MULTI_PARCEL1
    exporting
      !SHIPPING_MULTI_PARCEL_RESPONSE type ZSHIPPING_MULTI_PARCEL_RESPON1
    raising
      CX_AI_SYSTEM_FAULT .
  methods SHIPPING
    importing
      !SHIPPING type ZSHIPPING1
    exporting
      !SHIPPING_RESPONSE type ZSHIPPING_RESPONSE1
    raising
      CX_AI_SYSTEM_FAULT .
  methods RECHERCHER_CONTRAINTES_ENLEVEM
    importing
      !RECHERCHER_CONTRAINTES_ENLEVE1 type ZRECHERCHER_CONTRAINTES_ENLEV3
    exporting
      !RECHERCHER_CONTRAINTES_ENLEVEM type ZRECHERCHER_CONTRAINTES_ENLEV2
    raising
      CX_AI_SYSTEM_FAULT .
  methods GET_SHIPPING_INFORMATION
    importing
      !GET_SHIPPING_INFORMATION type ZGET_SHIPPING_INFORMATION1
    exporting
      !GET_SHIPPING_INFORMATION_RESPO type ZGET_SHIPPING_INFORMATION_RES1
    raising
      CX_AI_SYSTEM_FAULT .
  methods GET_ROUTING
    importing
      !GET_ROUTING type ZGET_ROUTING1
    exporting
      !GET_ROUTING_RESPONSE type ZGET_ROUTING_RESPONSE1
    raising
      CX_AI_SYSTEM_FAULT .
  methods GET_RESERVED_SKYBILL_WITH_TYPE
    importing
      !GET_RESERVED_SKYBILL_WITH_TYP1 type ZGET_RESERVED_SKYBILL_WITH_T10
    exporting
      !GET_RESERVED_SKYBILL_WITH_TYPE type ZGET_RESERVED_SKYBILL_WITH_TY9
    raising
      CX_AI_SYSTEM_FAULT .
  methods GET_RESERVED_SKYBILL_WITH_TYP3
    importing
      !GET_RESERVED_SKYBILL_WITH_TYP1 type ZGET_RESERVED_SKYBILL_WITH_T14
    exporting
      !GET_RESERVED_SKYBILL_WITH_TYPE type ZGET_RESERVED_SKYBILL_WITH_TY7
    raising
      CX_AI_SYSTEM_FAULT .
  methods GET_RESERVED_SKYBILL_WITH_TYP2
    importing
      !GET_RESERVED_SKYBILL_WITH_TYP1 type ZGET_RESERVED_SKYBILL_WITH_T13
    exporting
      !GET_RESERVED_SKYBILL_WITH_TYPE type ZGET_RESERVED_SKYBILL_WITH_TY8
    raising
      CX_AI_SYSTEM_FAULT .
  methods GET_RESERVED_SKYBILL_WITH_TYP1
    importing
      !GET_RESERVED_SKYBILL_WITH_TYP1 type ZGET_RESERVED_SKYBILL_WITH_T12
    exporting
      !GET_RESERVED_SKYBILL_WITH_TYPE type ZGET_RESERVED_SKYBILL_WITH_T11
    raising
      CX_AI_SYSTEM_FAULT .
  methods GET_RESERVED_SKYBILL
    importing
      !GET_RESERVED_SKYBILL type ZGET_RESERVED_SKYBILL1
    exporting
      !GET_RESERVED_SKYBILL_RESPONSE type ZGET_RESERVED_SKYBILL_RESPONS1
    raising
      CX_AI_SYSTEM_FAULT .
  methods FAISABILITE_ESD
    importing
      !FAISABILITE_ESD type ZFAISABILITE_ESD1
    exporting
      !FAISABILITE_ESDRESPONSE type ZFAISABILITE_ESDRESPONSE1
    raising
      CX_AI_SYSTEM_FAULT .
  methods CREER_ENLEVEMENT_NATIONAL
    importing
      !CREER_ENLEVEMENT_NATIONAL type ZCREER_ENLEVEMENT_NATIONAL1
    exporting
      !CREER_ENLEVEMENT_NATIONAL_RESP type ZCREER_ENLEVEMENT_NATIONAL_RE1
    raising
      CX_AI_SYSTEM_FAULT .
  methods CREER_ENLEVEMENT_EUROPE
    importing
      !CREER_ENLEVEMENT_EUROPE type ZCREER_ENLEVEMENT_EUROPE1
    exporting
      !CREER_ENLEVEMENT_EUROPE_RESPON type ZCREER_ENLEVEMENT_EUROPE_RESP1
    raising
      CX_AI_SYSTEM_FAULT .
  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods ANNULER_ENLEVEMENTS
    importing
      !ANNULER_ENLEVEMENTS type ZANNULER_ENLEVEMENTS1
    exporting
      !ANNULER_ENLEVEMENTS_RESPONSE type ZANNULER_ENLEVEMENTS_RESPONSE1
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZCO_SHIPPING_SERVICE_WS IMPLEMENTATION.


  method ANNULER_ENLEVEMENTS.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'ANNULER_ENLEVEMENTS'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of ANNULER_ENLEVEMENTS into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'ANNULER_ENLEVEMENTS_RESPONSE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of ANNULER_ENLEVEMENTS_RESPONSE into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'ANNULER_ENLEVEMENTS'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZCO_SHIPPING_SERVICE_WS'
    logical_port_name   = logical_port_name
  ).

  endmethod.


  method CREER_ENLEVEMENT_EUROPE.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'CREER_ENLEVEMENT_EUROPE'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of CREER_ENLEVEMENT_EUROPE into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'CREER_ENLEVEMENT_EUROPE_RESPON'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of CREER_ENLEVEMENT_EUROPE_RESPON into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'CREER_ENLEVEMENT_EUROPE'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method CREER_ENLEVEMENT_NATIONAL.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'CREER_ENLEVEMENT_NATIONAL'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of CREER_ENLEVEMENT_NATIONAL into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'CREER_ENLEVEMENT_NATIONAL_RESP'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of CREER_ENLEVEMENT_NATIONAL_RESP into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'CREER_ENLEVEMENT_NATIONAL'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method FAISABILITE_ESD.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'FAISABILITE_ESD'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of FAISABILITE_ESD into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'FAISABILITE_ESDRESPONSE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of FAISABILITE_ESDRESPONSE into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'FAISABILITE_ESD'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method GET_RESERVED_SKYBILL.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'GET_RESERVED_SKYBILL'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of GET_RESERVED_SKYBILL into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'GET_RESERVED_SKYBILL_RESPONSE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of GET_RESERVED_SKYBILL_RESPONSE into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'GET_RESERVED_SKYBILL'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method GET_RESERVED_SKYBILL_WITH_TYP1.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'GET_RESERVED_SKYBILL_WITH_TYP1'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of GET_RESERVED_SKYBILL_WITH_TYP1 into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'GET_RESERVED_SKYBILL_WITH_TYPE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of GET_RESERVED_SKYBILL_WITH_TYPE into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'GET_RESERVED_SKYBILL_WITH_TYP1'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method GET_RESERVED_SKYBILL_WITH_TYP2.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'GET_RESERVED_SKYBILL_WITH_TYP1'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of GET_RESERVED_SKYBILL_WITH_TYP1 into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'GET_RESERVED_SKYBILL_WITH_TYPE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of GET_RESERVED_SKYBILL_WITH_TYPE into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'GET_RESERVED_SKYBILL_WITH_TYP2'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method GET_RESERVED_SKYBILL_WITH_TYP3.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'GET_RESERVED_SKYBILL_WITH_TYP1'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of GET_RESERVED_SKYBILL_WITH_TYP1 into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'GET_RESERVED_SKYBILL_WITH_TYPE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of GET_RESERVED_SKYBILL_WITH_TYPE into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'GET_RESERVED_SKYBILL_WITH_TYP3'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method GET_RESERVED_SKYBILL_WITH_TYPE.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'GET_RESERVED_SKYBILL_WITH_TYP1'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of GET_RESERVED_SKYBILL_WITH_TYP1 into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'GET_RESERVED_SKYBILL_WITH_TYPE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of GET_RESERVED_SKYBILL_WITH_TYPE into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'GET_RESERVED_SKYBILL_WITH_TYPE'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method GET_ROUTING.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'GET_ROUTING'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of GET_ROUTING into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'GET_ROUTING_RESPONSE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of GET_ROUTING_RESPONSE into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'GET_ROUTING'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method GET_SHIPPING_INFORMATION.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'GET_SHIPPING_INFORMATION'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of GET_SHIPPING_INFORMATION into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'GET_SHIPPING_INFORMATION_RESPO'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of GET_SHIPPING_INFORMATION_RESPO into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'GET_SHIPPING_INFORMATION'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method RECHERCHER_CONTRAINTES_ENLEVEM.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'RECHERCHER_CONTRAINTES_ENLEVE1'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of RECHERCHER_CONTRAINTES_ENLEVE1 into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'RECHERCHER_CONTRAINTES_ENLEVEM'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of RECHERCHER_CONTRAINTES_ENLEVEM into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'RECHERCHER_CONTRAINTES_ENLEVEM'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_RESPONSE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_RESPONSE into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_MULTI_PARCEL.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_MULTI_PARCEL into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_RESPONSE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_MULTI_PARCEL_RESPONSE into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_MULTI_PARCEL'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_MULTI_PARCEL_V2.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_V2'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_MULTI_PARCEL_V2 into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_V2RESPON'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_MULTI_PARCEL_V2RESPON into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_MULTI_PARCEL_V2'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_MULTI_PARCEL_V3.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_V3'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_MULTI_PARCEL_V3 into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_V3RESPON'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_MULTI_PARCEL_V3RESPON into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_MULTI_PARCEL_V3'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_MULTI_PARCEL_V4.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_V4'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_MULTI_PARCEL_V4 into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_V4RESPON'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_MULTI_PARCEL_V4RESPON into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_MULTI_PARCEL_V4'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_MULTI_PARCEL_V5.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_V5'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_MULTI_PARCEL_V5 into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_V5RESPON'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_MULTI_PARCEL_V5RESPON into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_MULTI_PARCEL_V5'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_MULTI_PARCEL_V6.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_V6'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_MULTI_PARCEL_V6 into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_V6RESPON'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_MULTI_PARCEL_V6RESPON into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_MULTI_PARCEL_V6'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_MULTI_PARCEL_WITH_RE1.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_WITH_RE1'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_MULTI_PARCEL_WITH_RE1 into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_WITH_RES'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_MULTI_PARCEL_WITH_RES into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_MULTI_PARCEL_WITH_RE1'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_MULTI_PARCEL_WITH_RE2.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_WITH_RE1'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_MULTI_PARCEL_WITH_RE1 into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_WITH_RES'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_MULTI_PARCEL_WITH_RES into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_MULTI_PARCEL_WITH_RE2'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_MULTI_PARCEL_WITH_RES.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_WITH_RE1'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_MULTI_PARCEL_WITH_RE1 into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_MULTI_PARCEL_WITH_RES'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_MULTI_PARCEL_WITH_RES into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_MULTI_PARCEL_WITH_RES'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_V2.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_V2'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_V2 into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_V2RESPONSE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_V2RESPONSE into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_V2'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_V3.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_V3'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_V3 into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_V3RESPONSE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_V3RESPONSE into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_V3'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_V4.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_V4'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_V4 into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_V4RESPONSE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_V4RESPONSE into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_V4'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_V5.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_V5'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_V5 into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_V5RESPONSE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_V5RESPONSE into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_V5'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_V6.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_V6'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_V6 into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_V6RESPONSE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_V6RESPONSE into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_V6'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_V7.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_V7'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_V7 into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_V7RESPONSE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_V7RESPONSE into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_V7'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_WITH_ESDONLY.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_WITH_ESDONLY'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_WITH_ESDONLY into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_WITH_ESDONLY_RESPONSE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_WITH_ESDONLY_RESPONSE into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_WITH_ESDONLY'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_WITH_ESDONLY_V2.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_WITH_ESDONLY_V2'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_WITH_ESDONLY_V2 into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_WITH_ESDONLY_V2RESPON'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_WITH_ESDONLY_V2RESPON into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_WITH_ESDONLY_V2'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_WITH_RESERVATION.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_WITH_RESERVATION'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_WITH_RESERVATION into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_WITH_RESERVATION_RESP'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_WITH_RESERVATION_RESP into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_WITH_RESERVATION'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_WITH_RESERVATION_AND.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_WITH_RESERVATION_AND1'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_WITH_RESERVATION_AND1 into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_WITH_RESERVATION_AND'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_WITH_RESERVATION_AND into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_WITH_RESERVATION_AND'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_WITH_RESERVATION_AND1.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_WITH_RESERVATION_AND1'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_WITH_RESERVATION_AND1 into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_WITH_RESERVATION_AND'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_WITH_RESERVATION_AND into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_WITH_RESERVATION_AND1'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SHIPPING_WITH_RESERVATION_V2.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'SHIPPING_WITH_RESERVATION_V2'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of SHIPPING_WITH_RESERVATION_V2 into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'SHIPPING_WITH_RESERVATION_V2RE'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of SHIPPING_WITH_RESERVATION_V2RE into
 ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SHIPPING_WITH_RESERVATION_V2'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
