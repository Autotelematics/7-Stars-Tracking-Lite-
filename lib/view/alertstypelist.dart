import 'package:autotelematic_new_app/cubit/alerttypelist_cubit.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/commonutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class AlertsTypeListScreen extends StatefulWidget {
  const AlertsTypeListScreen({super.key});
  @override
  State<AlertsTypeListScreen> createState() => _AlertsTypeListScreenState();
}
class _AlertsTypeListScreenState extends State<AlertsTypeListScreen> {
  AlertsTypeListCubit alertsTypeListCubit = AlertsTypeListCubit();
  bool currentCheckBoxValue = false;
  @override
  void initState() {
    alertsTypeListCubit.fetchAlertsTypeListFromAPI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts Settings'), centerTitle: true),
      body: Column(
        children: [
          BlocProvider<AlertsTypeListCubit>(
            create: (context) => alertsTypeListCubit,
            child: BlocBuilder<AlertsTypeListCubit, AlertsTypeListState>(
              builder: (context, state) {
                if (state is AlerttypelistLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppTheme.loadingImage,
                        const SizedBox(
                          height: 5,
                        ),
                        const Text('Loading...')
                      ],
                    ),
                  );
                }
                if (state is AlerttypelistError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppTheme.loadingImage,
                        const SizedBox(
                          height: 5,
                        ),
                        const Text('Error while loading Alerts...')
                      ],
                    ),
                  );
                }
                if (state is AlerttypelistComplete) {
                  return Expanded(
                      child: ListView.builder(
                    itemCount: state.alertsTypeList.items.alerts.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Divider(),
                          ListTile(
                            title: Text(state
                                .alertsTypeList.items.alerts[index].name
                                .toString()),
                            trailing: Checkbox(
                              value:
                                  state.alertsTypeList.items.alerts[index].active ==
                                          1
                                      ? true
                                      : false,
                              onChanged: (value) {
                                alertsTypeListCubit.changeAlertsTypeStatus(
                                  state.alertsTypeList.items.alerts[index].id
                                      .toString(),
                                  value.toString(),
                                );
                                CommonUtils.toastMessage('Updating...');
                              },
                            ),
                          ),

                        ],
                      );
                    },
                  ));
                }
                return const Text('Alerts type');
              },
            ),
          ),
        ],
      ),
    );
  }
}
