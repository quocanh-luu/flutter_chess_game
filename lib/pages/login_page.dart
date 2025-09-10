import 'package:chess_game/utils/language_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../blocs/login_bloc.dart';
import '../blocs/login_state.dart';
import '../blocs/login_event.dart';


class LoginTab extends StatefulWidget {
	const LoginTab({super.key});

	@override
	State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
	final _emailController = TextEditingController();
	final _passwdController = TextEditingController();

	void _login() {
	 final email = _emailController.text.trim();
	 final passwd = _passwdController.text.trim();

	 context.read<LoginBloc>().add(LoginRequest(email, passwd));
	}

	@override
	Widget build(BuildContext context) {
	 return BlocBuilder<LoginBloc, LoginState>(
		builder: (context, state) {
			return Column(
			 children: [
				if (state is Error)
					Padding(
						padding: const EdgeInsets.only(bottom: 16),
						child: Text(state.message, style: TextStyle(color: Colors.red)),
					),
			TextField(
				controller: _emailController,
				decoration: InputDecoration(
					labelText: context.read<LanguageManager>().isGerman ? "E-Mail" : "Email",
					hintText: AppLocalizations.translate('enter_email', context.read<LanguageManager>().locale),
				),
			),
			SizedBox(height: 20,),
			TextField(
				controller: _passwdController,
				obscureText: true,
				decoration: InputDecoration(
					labelText: AppLocalizations.translate('password', context.read<LanguageManager>().locale),
					hintText: AppLocalizations.translate('enter_password', context.read<LanguageManager>().locale),
				),
			),
			SizedBox(height: 32,),
			SizedBox(
				width: double.infinity,
				child: ElevatedButton(
					onPressed: _login,
					style: ElevatedButton.styleFrom(
						padding: EdgeInsets.symmetric(vertical: 16),
					),
					child: (state is Loading) ? const CircularProgressIndicator(color: Colors.white) : Consumer<LanguageManager>(
						builder: (context, languageManager, child) {
							return Text(
								AppLocalizations.translate('login', languageManager.locale),
								style: const TextStyle(fontSize: 16),
							);
						},
					),
				),
			)
			 ],
			);
		},
	 );
	}
}

class RegisterTab extends StatefulWidget {
	const RegisterTab({super.key});

	@override
	State<RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<RegisterTab> {
	final _unameController = TextEditingController();
	final _emailController = TextEditingController();
	final _passwdController = TextEditingController();

	void _register(){
		final username = _unameController.text.trim();
		final email = _emailController.text.trim();
		final passwd = _passwdController.text.trim();

		context.read<LoginBloc>().add(RegisterRequest(email, passwd, username));
	}

	@override
	Widget build(BuildContext context) {
	 return BlocBuilder<LoginBloc, LoginState>(
		builder: (context, state){
			return Column(
				children: [
					if(state is Error)
						Padding(
							padding: const EdgeInsets.only(bottom: 16),
							child: Text(state.message, style: TextStyle(color: Colors.red)),
						),
					TextField(
						controller: _unameController,
						decoration: InputDecoration(
							labelText: AppLocalizations.translate('username', context.read<LanguageManager>().locale),
							hintText: AppLocalizations.translate('enter_username', context.read<LanguageManager>().locale),
						),
					),
					SizedBox(height: 20,),
					TextField(
						controller: _emailController,
						decoration: InputDecoration(
							labelText: context.read<LanguageManager>().isGerman ? "E-Mail" : "Email",
							hintText: AppLocalizations.translate('enter_email', context.read<LanguageManager>().locale),
						),
					),
					SizedBox(height: 20,),
					TextField(
						controller: _passwdController,
						obscureText: true,
						decoration: InputDecoration(
							labelText: AppLocalizations.translate('password', context.read<LanguageManager>().locale),
							hintText: AppLocalizations.translate('enter_password', context.read<LanguageManager>().locale),
						),
					),
					SizedBox(height: 32,),
					SizedBox(
						width: double.infinity,
						child: ElevatedButton(
							onPressed: _register,
							style: ElevatedButton.styleFrom(
								padding: EdgeInsets.symmetric(vertical: 16),
							),
							child: (state is Loading) ? const CircularProgressIndicator(color: Colors.white) : Consumer<LanguageManager>(
								builder: (context, languageManager, child) {
									return Text(
										AppLocalizations.translate('register', languageManager.locale),
										style: const TextStyle(fontSize: 16),
									);
								},
							),
						),
					)
				],
			);
		}
	);
	}
}

class LoginPage extends StatelessWidget {
 	const LoginPage({super.key});

		@override
		Widget build(BuildContext context) {
	 	return DefaultTabController(
			length: 2,
			child: Scaffold(
				appBar: AppBar(
				backgroundColor: Colors.blue,
				title: Consumer<LanguageManager>(
					builder: (context, languageManager, child) {
						return Text(
							AppLocalizations.translate('login', languageManager.locale),
							style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
						);
					},
				),
				bottom: TabBar(tabs: [
					Consumer<LanguageManager>(
						builder: (context, languageManager, child) {
							return Tab(text: AppLocalizations.translate('login', languageManager.locale));
						},
					), 
					Consumer<LanguageManager>(
						builder: (context, languageManager, child) {
							return Tab(text: AppLocalizations.translate('register', languageManager.locale));
						},
					)
				]),
					),
					body: Center(
						child: ConstrainedBox(
							constraints: BoxConstraints(maxWidth: 400),
							child: Padding(
								padding: const EdgeInsets.all(32.0),
								child: TabBarView(
									children: [
										LoginTab(), 
										RegisterTab()
									]),
							),
						),
					),	
			),
	 	);
		}	
}