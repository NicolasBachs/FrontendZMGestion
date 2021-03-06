import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zmgestion/src/helpers/Request.dart';
import 'package:zmgestion/src/models/Ubicaciones.dart';
import 'package:zmgestion/src/services/UbicacionesService.dart';
import 'package:zmgestion/src/views/ubicaciones/CrearUbicacionesAlertDialog.dart';
import 'package:zmgestion/src/widgets/AppLoader.dart';
import 'package:zmgestion/src/widgets/DeleteAlertDialog.dart';
import 'package:zmgestion/src/widgets/ModelView.dart';
import 'package:zmgestion/src/widgets/MultipleRequestView.dart';
import 'package:zmgestion/src/widgets/SizeConfig.dart';
import 'package:zmgestion/src/widgets/TableTitle.dart';
import 'package:zmgestion/src/widgets/ZMBreadCrumb/ZMBreadCrumbItem.dart';
import 'package:zmgestion/src/widgets/ZMButtons/ZMStdButton.dart';
import 'package:zmgestion/src/widgets/ZMTable/IconButtonTableAction.dart';
import 'package:zmgestion/src/widgets/ZMTable/ZMTable.dart';
import 'package:zmgestion/src/widgets/ZMTooltip.dart';

class UbicacionesIndex extends StatefulWidget {
  @override
  _UbicacionesIndexState createState() => _UbicacionesIndexState();
}

class _UbicacionesIndexState extends State<UbicacionesIndex> {
  int refreshValue = 0;
  Map<String, String> breadcrumb = new Map<String, String>();

  void initState() {
    breadcrumb.addAll({
      "Inicio":"/inicio",
      "Ubicaciones": null,
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Flexible(
              child: Column(
                children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ZMBreadCrumb(
                        config: breadcrumb,
                      ),
                    ),
                  ],
                ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: AppLoader(builder: (scheduler) {
                      return ZMTable(
                        key: Key(refreshValue.toString()),
                        model: Ubicaciones(),
                        service: UbicacionesService(),
                        listMethodConfiguration: UbicacionesService().listar(),
                        paginate: false,
                        cellBuilder: {
                          "Ubicaciones": {
                            "Ubicacion": (value) {
                              return Text(
                                value != null ? value.toString() : "-",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              );
                            }
                          },
                          "Domicilios": {
                            "Domicilio": (value) {
                              return Text(
                                value != null ? value.toString() : "-",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                            "CodigoPostal": (value) {
                              return Text(
                                value != null ? value.toString() : "-",
                                textAlign: TextAlign.center,
                              );
                            },
                          },
                          "Ciudades": {
                            "Ciudad": (value) {
                              return Text(
                                value != null ? value.toString() : "-",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              );
                            }
                          },
                          "Provincias": {
                            "Provincia": (value) {
                              return Text(
                                value != null ? value.toString() : "-",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              );
                            }
                          },
                          "Paises": {
                            "Pais": (value) {
                              return Text(value != null ? value.toString() : "-",
                                  textAlign: TextAlign.center);
                            }
                          },
                        },
                        tableLabels: {
                          "Ubicaciones": {
                            "Ubicacion": "Ubicación",
                          },
                          "Domicilios": {
                            "CodigoPostal": "Código Postal",
                          }
                        },
                        fixedActions: [
                          ZMStdButton(
                            color: Colors.green,
                            text: Text(
                              "Crear ubicación",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierColor: Theme.of(context)
                                    .backgroundColor
                                    .withOpacity(0.5),
                                builder: (BuildContext context) {
                                  return CrearUbicacionesAlertDialog(
                                    title: "Crear Ubicación",
                                    onSuccess: () {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        refreshValue++;
                                      });
                                    },
                                  );
                                },
                              );
                            },
                          )
                        ],
                        onSelectActions: (ubicaciones) {
                          bool estadosIguales = true;
                          String estado;
                          if (ubicaciones.length >= 1) {
                            Map<String, dynamic> anterior;
                            for (Ubicaciones ubicacion in ubicaciones) {
                              Map<String, dynamic> mapUbicacion = ubicacion.toMap();
                              if (anterior != null) {
                                if (anterior["Ubicaciones"]["Estado"] !=
                                    mapUbicacion["Ubicaciones"]["Estado"]) {
                                  estadosIguales = false;
                                }
                              }
                              if (!estadosIguales) break;
                              anterior = mapUbicacion;
                            }
                            if (estadosIguales) {
                              estado =
                                  ubicaciones[0].toMap()["Ubicaciones"]["Estado"];
                            }
                          }
                          return <Widget>[
                            Visibility(
                              visible: estadosIguales && estado != null,
                              child: Row(
                                children: [
                                  ZMStdButton(
                                    color: Colors.white,
                                    text: Text(
                                      (estado == "A"
                                              ? "Dar de baja"
                                              : "Dar de alta") +
                                          " (" +
                                          ubicaciones.length.toString() +
                                          ")",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    icon: Icon(
                                      estado == "A"
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color:
                                          estado == "A" ? Colors.red : Colors.green,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        barrierColor: Theme.of(context)
                                            .backgroundColor
                                            .withOpacity(0.5),
                                        builder: (BuildContext context) {
                                          return MultipleRequestView(
                                            models: ubicaciones,
                                            title: (estado == "A" ? "Dar de baja" : "Dar de alta") + " " +
                                                ubicaciones.length.toString() + " ubicaciones",
                                            service: UbicacionesService(),
                                            doMethodConfiguration: estado == "A"
                                                ? UbicacionesService()
                                                    .bajaConfiguration()
                                                : UbicacionesService()
                                                    .altaConfiguration(),
                                            payload: (mapModel) {
                                              return {
                                                "Ubicaciones": {
                                                  "IdUbicacion":
                                                      mapModel["Ubicaciones"]["IdUbicacion"]
                                                }
                                              };
                                            },
                                            itemBuilder: (mapModel) {
                                              return Text(mapModel["Ubicaciones"]["Ubicacion"]);
                                            },
                                            onFinished: () {
                                              setState(() {
                                                refreshValue =
                                                    Random().nextInt(99999);
                                              });
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    width: 15,
                                  )
                                ],
                              ),
                            ),
                            ZMStdButton(
                              color: Colors.red,
                              text: Text(
                                "Borrar (" + ubicaciones.length.toString() + ")",
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierColor: Theme.of(context).backgroundColor.withOpacity(0.5),
                                  builder: (BuildContext context) {
                                    return MultipleRequestView(
                                      models: ubicaciones,
                                      title: "Borrar " +
                                          ubicaciones.length.toString() +
                                          " ubicaciones",
                                      service: UbicacionesService(),
                                      doMethodConfiguration:
                                          UbicacionesService().borraConfiguration(),
                                      payload: (mapModel) {
                                        return {
                                          "Ubicaciones": {
                                            "IdUbicacion": mapModel["Ubicaciones"]
                                                ["IdUbicacion"]
                                          }
                                        };
                                      },
                                      itemBuilder: (mapModel) {
                                        return Text(
                                            mapModel["Ubicaciones"]["Ubicacion"]);
                                      },
                                      onFinished: () {
                                        setState(() {
                                          refreshValue = Random().nextInt(99999);
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                            )
                          ];
                        },
                        rowActions: (mapModel, index, itemsController) {
                          Ubicaciones ubicacion;
                          String estado = "A";
                          int idUbicacion = 0;
                          if (mapModel != null) {
                            if (mapModel["Ubicaciones"] != null) {
                              ubicacion = Ubicaciones().fromMap(mapModel);

                              if (mapModel["Ubicaciones"]["Estado"] != null) {
                                estado = mapModel["Ubicaciones"]["Estado"];
                              }
                              if (mapModel["Ubicaciones"]["IdUbicacion"] != null) {
                                idUbicacion = mapModel["Ubicaciones"]["IdUbicacion"];
                              }
                            }
                          }
                          return <Widget>[
                            ZMTooltip(
                              key: Key("EstadoUbicacion"+estado.toString()),
                              message: estado == "A" ? "Dar de baja" : "Dar de alta",
                              theme: estado == "A" ? ZMTooltipTheme.RED : ZMTooltipTheme.GREEN,
                              visible: idUbicacion != 0,
                              child: IconButtonTableAction(
                                iconData: (estado == "A" ? Icons.arrow_downward : Icons.arrow_upward),
                                color: estado == "A" ? Colors.redAccent : Colors.green,
                                onPressed: idUbicacion == 0 ? null : () {
                                  if (idUbicacion != 0) {
                                    if (estado == "A") {
                                      UbicacionesService(scheduler: scheduler).baja({
                                        "Ubicaciones": {"IdUbicacion": idUbicacion}
                                      }).then((response) {
                                        if (response.status == RequestStatus.SUCCESS) {
                                          itemsController.add(
                                            ItemAction(
                                              event: ItemEvents.Update,
                                              index: index,
                                              updateMethodConfiguration: UbicacionesService().dameConfiguration(ubicacion.idUbicacion)
                                            )
                                          );
                                        }
                                      });
                                    } else {
                                      UbicacionesService(scheduler: scheduler).alta({
                                        "Ubicaciones": {"IdUbicacion": idUbicacion}
                                      }).then((response) {
                                        if (response.status == RequestStatus.SUCCESS) {
                                          itemsController.add(
                                            ItemAction(
                                              event: ItemEvents.Update,
                                              index: index,
                                              updateMethodConfiguration: UbicacionesService().dameConfiguration(ubicacion.idUbicacion)
                                            )
                                          );
                                        }
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                            ZMTooltip(
                              message: "Borrar",
                              theme: ZMTooltipTheme.RED,
                              visible: idUbicacion != 0,
                              child: IconButtonTableAction(
                                iconData: Icons.delete_outline,
                                onPressed: idUbicacion == 0 ? null : () {
                                  if (idUbicacion != 0) {
                                    showDialog(
                                      context: context,
                                      barrierColor: Theme.of(context).backgroundColor.withOpacity(0.5),
                                      builder: (BuildContext context) {
                                        return DeleteAlertDialog(
                                          title: "Borrar Ubicación",
                                          message: "¿Está seguro que desea eliminar la ubicación?",
                                          onAccept: () async {
                                            await UbicacionesService().borra({
                                              "Ubicaciones": {
                                                "IdUbicacion": idUbicacion
                                              }
                                            }).then((response) {
                                              if (response.status == RequestStatus.SUCCESS) {
                                                itemsController.add(
                                                  ItemAction(
                                                    event: ItemEvents.Hide,
                                                    index: index
                                                  )
                                                );
                                              }
                                            });
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            )
                          ];
                        },
                        searchArea: TableTitle(title: "Ubicaciones"),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
