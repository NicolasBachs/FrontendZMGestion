import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zmgestion/src/helpers/Request.dart';
import 'package:zmgestion/src/models/Permisos.dart';
import 'package:zmgestion/src/models/Roles.dart';
import 'package:zmgestion/src/services/RolesService.dart';
import 'package:zmgestion/src/views/roles/CrearRolesAlertDialog.dart';
import 'package:zmgestion/src/views/roles/ModificarRolesAlertDialog.dart';
import 'package:zmgestion/src/widgets/AppLoader.dart';
import 'package:zmgestion/src/widgets/DeleteAlertDialog.dart';
import 'package:zmgestion/src/widgets/ModelView.dart';
import 'package:zmgestion/src/widgets/SizeConfig.dart';
import 'package:zmgestion/src/widgets/TableTitle.dart';
import 'package:zmgestion/src/widgets/ZMAnimatedLoader/ZMAnimatedLoader.dart';
import 'package:zmgestion/src/widgets/ZMButtons/ZMStdButton.dart';
import 'package:zmgestion/src/widgets/ZMTable/ZMTable.dart';

class RolesIndex extends StatefulWidget {
  @override
  _RolesIndexState createState() => _RolesIndexState();
}

class _RolesIndexState extends State<RolesIndex> {
  int _cardsPerRow;
  List<Roles> roles = new List<Roles>();
  bool _isLoading = true;
  bool _hasError;
  int key = 0;
  Map<int, dynamic> permisosRol = new Map<int, dynamic>();
  FlareController animationController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (MediaQuery.of(context).size.width < 900) {
        _cardsPerRow = 2;
      } else {
        _cardsPerRow = 3;
      }

      //Consulto los roles
      await RolesService().listMethod(RolesService().listar()).then((response) async {
        if (response.status == RequestStatus.SUCCESS) {
          response.message.forEach((rol) {
            roles.add(rol);
          });
        }
        setState(() {
          if (response.status == RequestStatus.ERROR) {
            _hasError = true;
          } else {
            _hasError = false;
          }
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8,8,24,8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TableTitle(
                  title: "Roles y Permisos",
                ),
                ZMStdButton(
                      color: Colors.green,
                      text: Text(
                        "Nuevo Rol",
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
                            return CrearRolesAlertDialog(
                              title: "Crear Rol",
                              onSuccess: () async{
                                Navigator.of(context).pop();
                                await refreshRoles();
                                // setState(() {
                                //   key ++;
                                // });
                              },
                            );
                          },
                        );
                      },
                    )
              ],
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : !_hasError ? _roleWidget() : _errorWidget(),
        ],
      ),
    );
  }

  _roleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:8.0),
      child: AppLoader(
        builder: (scheduler) {
          return Container(
            height: SizeConfig.blockSizeVertical * 70,
            child: GridView.count(
              key: Key(key.toString()),
              padding: EdgeInsets.all(12),
              crossAxisCount: _cardsPerRow,
              crossAxisSpacing: SizeConfig.blockSizeHorizontal*5,
              childAspectRatio: 8.0 / 9.0,
              children: List.generate(roles.length, (index) {
                Roles _rol = roles.elementAt(index);
                return Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Encabezado de la card
                      Container(
                        padding: EdgeInsets.symmetric(vertical:6, horizontal: 10),
                        width: SizeConfig.blockSizeHorizontal*23.5,
                        decoration: BoxDecoration(
                         color: Theme.of(context).primaryColorLight,
                         gradient: LinearGradient(
                           colors: [
                             Theme.of(context).primaryColorLight,
                            Theme.of(context).primaryColorLight.withOpacity(0.6)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter
                        ),
                         borderRadius: BorderRadius.only(
                           topLeft: Radius.circular(15),
                           topRight: Radius.circular(15)
                         )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _rol.rol,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  onPressed: (){
                                    showDialog(
                                      context: context,
                                      barrierColor: Theme.of(context).backgroundColor.withOpacity(0.5),
                                      builder: (BuildContext context) {
                                        return ModificarRolesAlertDialog(
                                          title: "Modificar Rol",
                                          rol: _rol,
                                          onSuccess: () async{
                                            Navigator.of(context).pop(); 
                                            setState(() {
                                              key ++;
                                            });
                                          },
                                        );
                                      },
                                    );
                                  }
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  onPressed: (){
                                    showDialog(
                                      context: context,
                                      barrierColor: Theme.of(context).backgroundColor.withOpacity(0.5),
                                      builder: (BuildContext context) {
                                        return DeleteAlertDialog(
                                          title: "Borrar Rol",
                                          message:"¿Está seguro que desea eliminar el rol?",
                                          onAccept: () async {
                                            await RolesService().borra({
                                              "Roles": {"IdRol": _rol.idRol}
                                            }).then((response) {
                                              if (response.status ==RequestStatus.SUCCESS) {
                                                setState(() {
                                                  roles.remove(_rol);
                                                });
                                              }
                                            });
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    );
                                  }
                                ),
                              ],
                            )
                          ],
                        )
                      ),
                      //Cuerpo de la card
                      Container(
                        width: SizeConfig.blockSizeHorizontal*23.5,
                        height: SizeConfig.blockSizeVertical*30,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)
                          )
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: ModelView(
                            key: Key(key.toString()),
                            isList: true,
                            service: RolesService(),
                            listMethodConfiguration: RolesService().listarPermisosConfiguration({
                              "Roles":{
                                "IdRol":_rol.idRol
                                }
                              }
                            ),
                            itemBuilder: (mapModel, index, itemsController) {
                              Permisos permiso = new Permisos().fromMap(mapModel);
                              return Text(permiso.permiso);
                            },
                            onEmpty: (){
                              return Center(child: Text("Rol sin permisos"));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  _errorWidget() {
    return Text("Hay un error");
  }

  refreshRoles() async{
    roles = [];
    await RolesService().listMethod(RolesService().listar()).then((response) async {
      if (response.status == RequestStatus.SUCCESS) {
        response.message.forEach((rol) {
          roles.add(rol);
        });
      }
      setState(() {
        if (response.status == RequestStatus.ERROR) {
          _hasError = true;
        } else {
          _hasError = false;
        }
        _isLoading = false;
      });
    });
  }
}