import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mywork/core/env/env.dart';
import 'package:mywork/core/widgets/app_field.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/auth/data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Email'),
            Tab(text: 'Téléphone'),
            Tab(text: 'Code email'),
          ],
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: _SocialAuthButtons(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('ou', style: Theme.of(context).textTheme.bodySmall),
                ),
                Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const [
                _PasswordLoginForm(),
                _PhoneOtpLoginForm(),
                _EmailOtpLoginForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialAuthButtons extends ConsumerStatefulWidget {
  const _SocialAuthButtons();

  @override
  ConsumerState<_SocialAuthButtons> createState() => _SocialAuthButtonsState();
}

class _SocialAuthButtonsState extends ConsumerState<_SocialAuthButtons> {
  String? _pending;
  String? _error;

  Future<void> _signInWithGoogle() async {
    if (!Env.isGoogleSignInConfigured) {
      setState(() => _error = "La connexion Google n'est pas encore configurée.");
      return;
    }
    setState(() {
      _pending = 'google';
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      debugPrint('[GOOGLE SIGN-IN ERROR] $e');
      setState(() => _error = 'Connexion Google impossible pour le moment.');
    } finally {
      if (mounted) setState(() => _pending = null);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _pending = 'apple';
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithApple();
    } catch (e) {
      setState(() => _error = 'Connexion Apple impossible pour le moment.');
    } finally {
      if (mounted) setState(() => _pending = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _pending != null ? null : _signInWithGoogle,
          icon: _pending == 'google'
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const _GoogleLogo(),
          label: const Text('Continuer avec Google'),
        ),
        if (AuthRepository.isAppleSignInAvailable) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pending != null ? null : _signInWithApple,
            icon: _pending == 'apple'
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.apple, size: 20),
            label: const Text('Continuer avec Apple'),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ],
    );
  }
}

/// Simple 4-color "G" mark — avoids depending on network/asset logo files.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: Text(
        'G',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          height: 1.15,
          color: Color(0xFF4285F4),
        ),
      ),
    );
  }
}

class _PasswordLoginForm extends ConsumerStatefulWidget {
  const _PasswordLoginForm();

  @override
  ConsumerState<_PasswordLoginForm> createState() => _PasswordLoginFormState();
}

class _PasswordLoginFormState extends ConsumerState<_PasswordLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithPassword(
            email: _email.text.trim(),
            password: _password.text,
          );
    } catch (e) {
      setState(() => _error = 'Connexion impossible. Vérifiez vos identifiants.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppField(
              controller: _email,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
            ),
            const SizedBox(height: 16),
            AppField(
              controller: _password,
              label: 'Mot de passe',
              obscureText: true,
              validator: (v) => (v == null || v.isEmpty) ? 'Mot de passe requis' : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Se connecter'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.push('/reset-password'),
              child: const Text('Mot de passe oublié ?'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneOtpLoginForm extends ConsumerStatefulWidget {
  const _PhoneOtpLoginForm();

  @override
  ConsumerState<_PhoneOtpLoginForm> createState() => _PhoneOtpLoginFormState();
}

class _PhoneOtpLoginFormState extends ConsumerState<_PhoneOtpLoginForm> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  bool _sent = false;
  bool _loading = false;
  String? _error;

  Future<void> _sendCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithPhoneOtp(_phone.text.trim());
      setState(() => _sent = true);
    } catch (e) {
      setState(() => _error = "Envoi du code impossible.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifyPhoneOtp(
            phone: _phone.text.trim(),
            token: _code.text.trim(),
          );
    } catch (e) {
      setState(() => _error = 'Code invalide.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppField(
            controller: _phone,
            label: 'Numéro de téléphone',
            hint: '+237...',
            keyboardType: TextInputType.phone,
            enabled: !_sent,
          ),
          if (_sent) ...[
            const SizedBox(height: 16),
            AppField(controller: _code, label: 'Code reçu par SMS', keyboardType: TextInputType.number),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : (_sent ? _verify : _sendCode),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(_sent ? 'Valider le code' : 'Recevoir un code'),
          ),
        ],
      ),
    );
  }
}

class _EmailOtpLoginForm extends ConsumerStatefulWidget {
  const _EmailOtpLoginForm();

  @override
  ConsumerState<_EmailOtpLoginForm> createState() => _EmailOtpLoginFormState();
}

class _EmailOtpLoginFormState extends ConsumerState<_EmailOtpLoginForm> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _sent = false;
  bool _loading = false;
  String? _error;

  Future<void> _sendCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithEmailOtp(_email.text.trim());
      setState(() => _sent = true);
    } catch (e) {
      setState(() => _error = "Envoi du code impossible.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifyEmailOtp(
            email: _email.text.trim(),
            token: _code.text.trim(),
          );
    } catch (e) {
      setState(() => _error = 'Code invalide.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppField(
            controller: _email,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            enabled: !_sent,
          ),
          if (_sent) ...[
            const SizedBox(height: 16),
            AppField(controller: _code, label: 'Code reçu par email', keyboardType: TextInputType.number),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : (_sent ? _verify : _sendCode),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(_sent ? 'Valider le code' : 'Recevoir un code'),
          ),
        ],
      ),
    );
  }
}
