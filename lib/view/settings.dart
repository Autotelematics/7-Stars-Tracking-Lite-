import 'package:autotelematic_new_app/cubit/change_password_cubit.dart';
import 'package:autotelematic_new_app/cubit/change_password_state.dart';
import 'package:autotelematic_new_app/cubit/setting_cubit.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:autotelematic_new_app/utils/commonutils.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:autotelematic_new_app/utils/user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// Define constants for consistent icon sizes
class AppSizes {
  static final double iconContainerSize = 4.h;
  static final double iconSize = 2.5.h;
}

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late final String email;
  late final String url;

  @override
  void initState() {
    super.initState();
    context.read<SettingCubit>().getSharedPreferenceSettings();
    email = CompanyInfo.companyGmail;
    url = 'mailto:$email';
  }

  Future<void> showChangePasswordDialog(BuildContext context) async {
    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) => ChangePasswordDialog(),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Icon(Icons.logout, size: 40, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to log out?',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      UserSessions.removeSession();
                      Navigator.pushNamedAndRemoveUntil(
                        dialogContext,
                        RoutesName.login,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<SettingCubit, SettingState>(
              builder: (context, state) {
                if (state is SettingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SettingError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context
                              .read<SettingCubit>()
                              .getSharedPreferenceSettings(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is SettingComplete) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        const SizedBox(height: 10),
                                        Transform.scale(
                                          scale: 2,
                                          child: const Image(
                                            image: AssetImage(
                                                'assets/images/image.png'),
                                            fit: BoxFit.cover,
                                            height: 100,
                                            width: 100,
                                          ),
                                        ),
                                        const SizedBox(height: 60),
                                        const Text('Hello! Partner'),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            state.userID,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Account Settings',
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                            ),
                          ],
                        ),
                        Card(
                          color: Colors.white,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => showChangePasswordDialog(context),
                              child: ListTile(
                                leading: Icon(Icons.lock,
                                    size: AppSizes.iconContainerSize,
                                    color: Colors.redAccent),
                                title: Text('Password Change',
                                    style:
                                        Theme.of(context).textTheme.titleSmall),
                                trailing: const Icon(Icons.arrow_forward_ios),
                              ),
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.white,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pushNamed(
                                  context, RoutesName.alertsTypeList),
                              child: ListTile(
                                leading: Image.asset(
                                  'assets/images/alertset.png',
                                  height: AppSizes.iconSize,
                                  width: AppSizes.iconSize,
                                  fit: BoxFit.contain,
                                ),
                                title: Text('Notification Settings',
                                    style:
                                        Theme.of(context).textTheme.titleSmall),
                                trailing: const Icon(Icons.arrow_forward_ios),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Company Info',
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                            ),
                          ],
                        ),
                        if (CompanyInfo.whatsApp.isNotEmpty)
                          _buildInfoCard(
                            context,
                            title: 'WhatsApp',
                            iconPath: 'assets/images/whatsapp.png',
                            url: 'https://wa.me/${CompanyInfo.whatsApp}',
                          ),
                        if (CompanyInfo.instagram.isNotEmpty)
                          _buildInfoCard(
                            context,
                            title: 'Instagram',
                            iconPath: 'assets/images/instagram.jpeg',
                            url: CompanyInfo.instagram,
                          ),
                        if (CompanyInfo.facebook.isNotEmpty)
                          _buildInfoCard(
                            context,
                            title: 'Facebook',
                            iconPath: 'assets/images/facebook.png',
                            url: CompanyInfo.facebook,
                          ),
                        if (CompanyInfo.website.isNotEmpty)
                          _buildInfoCard(
                            context,
                            title: 'Website',
                            iconPath: 'assets/images/8380020.png',
                            url: CompanyInfo.website,
                          ),
                        if (CompanyInfo.websiteNews.isNotEmpty)
                          _buildInfoCard(
                            context,
                            title: 'Website News',
                            iconPath: 'assets/images/news.png',
                            url: CompanyInfo.websiteNews,
                          ),
                        if (CompanyInfo.companyGmail.isNotEmpty)
                          _buildInfoCard(
                            context,
                            title: 'Email',
                            iconPath: 'assets/images/gmail.png',
                            url:
                                'mailto:${CompanyInfo.companyGmail}', // no encoding
                          ),
                        if (CompanyInfo.companyHelpLine.isNotEmpty)
                          _buildInfoCard(
                            context,
                            title: 'Helpline',
                            iconPath: '',
                            url: 'tel:${CompanyInfo.companyHelpLine}',
                          ),
                        if (CompanyInfo.companyPhone.isNotEmpty)
                          _buildInfoCard(
                            context,
                            title: 'Phone',
                            iconPath: 'assets/images/call.png',
                            url: 'tel:${CompanyInfo.companyPhone}',
                          ),
                        if (CompanyInfo.privacyPolicy.isNotEmpty)
                          _buildInfoCard(
                            context,
                            title: 'Privacy Policy',
                            iconPath: '',
                            url: CompanyInfo.privacyPolicy,
                          ),
                        if (CompanyInfo.termAndCondition.isNotEmpty)
                          _buildInfoCard(
                            context,
                            title: 'Terms and Conditions',
                            iconPath: 'assets/images/7228764.png',
                            url: CompanyInfo.termAndCondition,
                          ),
                        SizedBox(height:20),
                        Text(
                          CompanyInfo.companyAddress,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 17.sp,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Logout',
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                            ),
                          ],
                        ),
                        Card(
                          color: Colors.white,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showLogoutDialog(context),
                              child: ListTile(
                                leading: Icon(Icons.logout,
                                    size: AppSizes.iconContainerSize,
                                    color: Colors.redAccent),
                                title: Text('Log out',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontSize: 16)),
                                trailing: const Icon(Icons.arrow_forward_ios),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Powered by Auto Telematics Pvt. Ltd.',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    'Initializing settings...',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title, required String iconPath, required String url}) {
    return Card(
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (title == "Privacy Policy" || title == "Terms and Conditions") {
              // Get the URL based on title
              String policyUrl = title == "Privacy Policy"
                  ? CompanyInfo.privacyPolicy
                  : CompanyInfo.termAndCondition;

              // Open in Chrome browser
              CommonUtils.launchURLBrowser(policyUrl);
            } else if (title == "Email") {
              final emailUrl = 'mailto:${CompanyInfo.companyGmail}';
              CommonUtils.launchURLBrowser(emailUrl);
            } else {
              CommonUtils.launchURLBrowser(url);
            }
          },
          child: ListTile(
            leading: Container(
              height: AppSizes.iconContainerSize,
              width: AppSizes.iconContainerSize,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: title == "Privacy Policy"
                    ? Icon(
                        Icons.privacy_tip_outlined,
                        size: AppSizes.iconSize,
                        color: Colors.black54,
                      )
                    : title == "Helpline"
                        ? Icon(
                            Icons.help_center,
                            size: AppSizes.iconSize,
                            color: Colors.black54,
                          )
                        : title == "Company Address"
                            ? Icon(
                                Icons.location_on,
                                size: AppSizes.iconSize,
                                color: Colors.black54,
                              )
                            : Image.asset(
                                iconPath,
                                height: AppSizes.iconSize,
                                width: AppSizes.iconSize,
                                fit: BoxFit.contain,
                              ),
              ),
            ),
            title: Text(title, style: Theme.of(context).textTheme.titleSmall),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ),
      ),
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordFocusNode = FocusNode();
  bool _isMounted = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocusNode.dispose();
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Change Password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Icon(Icons.lock, size: 40, color: Colors.redAccent),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              focusNode: passwordFocusNode,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
              listener: (context, state) {
                if (state is ChangePasswordComplete && _isMounted) {
                  UserSessions.removeSession();
                  Future.delayed(const Duration(seconds: 2), () {
                    if (_isMounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        RoutesName.login,
                        (route) => false,
                      );
                    }
                  });
                }
              },
              builder: (context, state) {
                if (state is ChangePasswordLoading) {
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.redAccent),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                if (state is ChangePasswordError) {
                  return Text(
                    state.message,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  );
                }
                if (state is ChangePasswordComplete) {
                  return const Text(
                    'Password changed. Sign in again.',
                    style: TextStyle(color: Colors.green),
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty) {
                          CommonUtils.showSnackbar(
                              context, 'Please enter password');
                          return;
                        }
                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          passwordController.clear();
                          confirmPasswordController.clear();
                          passwordFocusNode.requestFocus();
                          CommonUtils.showSnackbar(
                              context, 'Confirmation Password does not match');
                          return;
                        }
                        context
                            .read<ChangePasswordCubit>()
                            .changePasswrod(passwordController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Change',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
