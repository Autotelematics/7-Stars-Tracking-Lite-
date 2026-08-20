import 'package:autotelematic_new_app/cubit/singin_cubit.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/app_constants.dart';
import 'package:autotelematic_new_app/utils/commonutils.dart';
import 'package:autotelematic_new_app/view/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final singinCubit = SinginCubit();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Widget _buildLoadingDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
      child: Container(
        width: 80.w,
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppTheme.logoPath, width: 20.w),
            SizedBox(height: 2.h),
            CircularProgressIndicator(color: AppColors.primaryColor),
            SizedBox(height: 2.h),
            Text(
              'Logging In...',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xff667a7b),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 5.w),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
        duration: const Duration(seconds: 3),
        elevation: 8,
        showCloseIcon: true,
        closeIconColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            physics: MediaQuery.of(context).viewInsets.bottom > 0
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SizedBox(height: 11.h),
                    Image.asset(AppTheme.logoPath, width: 60.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      margin:
                          EdgeInsets.only(left: 4.w, right: 4.w, bottom: 8.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.w)),
                        color: AppColors.primaryColor,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "LOGIN",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.buttonColor,
                              fontSize: 24.sp,
                            ),
                          ),
                          Text(
                            "Welcome Back!, Please Login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.buttonColor,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          _buildTextField(
                            controller: emailController,
                            focusNode: emailFocusNode,
                            label: 'Username',
                            icon: Icons.person,
                            keyboardType: TextInputType.emailAddress,
                            onSubmitted: () => CommonUtils.fieldFocusChange(
                                context, emailFocusNode, passwordFocusNode),
                          ),
                          SizedBox(height: 1.h),
                          _buildTextField(
                            controller: passwordController,
                            focusNode: passwordFocusNode,
                            label: 'Password',
                            icon: Icons.key,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                                size: 5.w,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 2.h),
                          BlocProvider<SinginCubit>(
                            create: (context) => singinCubit,
                            child: BlocConsumer<SinginCubit, SinginState>(
                              listener: (context, state) {
                                if (state is SigninLoadingState) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => _buildLoadingDialog(),
                                  );
                                } else if (state is SigninErrorState) {
                                  // Close loading if open
                                  Navigator.pop(context);
                                  // Show error normally; do NOT special-case notifications here
                                  _showCustomSnackBar(context, state.message);
                                } else if (state is SignInSuccessState) {
                                  Navigator.pop(context);
                                  // Navigate to HomeScreen with index 2
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HomeScreen(initialIndex: 2),
                                    ),
                                    (route) => false,
                                  );
                                }
                              },
                              builder: (context, state) {
                                return Column(
                                  children: [
                                    SizedBox(
                                      width: 50.w,
                                      child: FilledButton.tonal(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  AppColors.buttonColor),
                                          shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        2.5.w)),
                                          ),
                                        ),
                                        onPressed: () {
                                          if (emailController.text.isEmpty) {
                                            _showCustomSnackBar(context,
                                                'Please enter username');
                                          } else if (passwordController
                                              .text.isEmpty) {
                                            _showCustomSnackBar(context,
                                                'Please enter password');
                                          } else {
                                            singinCubit.signIn({
                                              'email': emailController.text,
                                              'password':
                                                  passwordController.text,
                                            });
                                          }
                                        },
                                        child: Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: AppColors.buttonTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (state is SigninErrorState) ...[
                                      SizedBox(height: 2.h),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4.w, vertical: 1.5.h),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 4.w),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(2.w),
                                          border: Border.all(
                                              color: Colors.red.shade700,
                                              width: 1),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.error_outline,
                                                color: Colors.red.shade700,
                                                size: 5.w),
                                            SizedBox(width: 2.w),
                                            Expanded(
                                              child: Text(
                                                state.message,
                                                style: TextStyle(
                                                  color: Colors.red.shade700,
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "Note :",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.buttonColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            "Please Contact GPS Tracking Service Provider For Installation and Credentials",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.buttonColor,
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    VoidCallback? onSubmitted,
  }) {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: SizedBox(
        width: 90.w,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onFieldSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
          decoration: AppTheme.textFieldInputDecoration(
              label, Icon(icon, size: 5.w),
              suffixIcon: suffixIcon),
          style: TextStyle(fontSize: 16.sp),
        ),
      ),
    );
  }
}
