import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/role_selection_modal.dart';
import '../../../dashboard/presentation/pages/main_nav_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(RegisterEvent(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ));
    }
  }

  void _onGoogleRegister() {
    context.read<AuthBloc>().add(GoogleLoginEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => MainNavPage(user: state.user)),
              (route) => false,
            );
          } else if (state is AuthRolePending) {
            showRoleSelectionModal(context, state.user);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFE0F2FE), Color(0xFFFFF1F2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 86,
                      height: 86,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryRose.withValues(alpha: 0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Buat Akun Ibu CareLink',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mulai pemantauan kesehatan ibu & anak secara cerdas',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nama Lengkap Ibu',
                              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryRose),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Nama tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Alamat Email',
                              prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryRose),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                            ),
                            validator: (val) => val == null || !val.contains('@') ? 'Email tidak valid' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Kata Sandi',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryRose),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                            ),
                            validator: (val) => val == null || val.length < 6 ? 'Minimal 6 karakter' : null,
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;
                              if (isLoading) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: CircularProgressIndicator(color: AppTheme.primaryRose),
                                );
                              }
                              return Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                                      onPressed: _onRegister,
                                      child: const Text('Daftar Akun Baru'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(child: Divider(color: Colors.grey.shade300)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text('ATAU', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                      ),
                                      Expanded(child: Divider(color: Colors.grey.shade300)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      onPressed: _onGoogleRegister,
                                      icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Color(0xFFEA4335)),
                                      label: const Text(
                                        'Daftar dengan Google',
                                        style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
