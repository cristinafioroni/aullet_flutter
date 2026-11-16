import 'package:aullet/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aullet/views/auth/components/custom_app_bar.dart';
import 'package:aullet/viewmodel/profile_viewmodel.dart';
import 'package:aullet/views/auth/components/bottom_nav_bar.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  bool _didScheduleLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didScheduleLoad) {
      _didScheduleLoad = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        final vm = context.read<ProfileViewModel>();

        await vm.loadProfile();

        if (!mounted) return;

        if (vm.profile != null) {
          _nameController.text = vm.profile!.displayName;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CustomAppBar(),
      bottomNavigationBar: const CustomBottomNavBar(),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Avatar e nome
                  Row(
                    children: [
                      GestureDetector(
                        onTap: vm.pickAndUploadAvatar,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            // Avatar con bordo sfumato
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.accent,
                                    AppColors.lime,
                                    AppColors.primary,
                                  ],
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: vm.profile?.avatarUrl != null
                                    ? NetworkImage(vm.profile!.avatarUrl!)
                                    : null,
                                child: vm.profile?.avatarUrl == null
                                    ? const Icon(Icons.person, size: 50)
                                    : null,
                              ),
                            ),

                            // Icona modifica avatar
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 20,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Nome visualizzato
                      Expanded(
                        child: Text(
                          vm.profile?.displayName ?? '',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Modifica nome
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      labelStyle: TextStyle(color: AppColors.textPrimary),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 161, 50, 137),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pulsante Salva
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textDark,
                    ),
                    onPressed: () {
                      vm.updateDisplayName(_nameController.text);
                    },
                    child: const Text('Salva'),
                  ),

                  // Messaggio di errore
                  if (vm.error != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      vm.error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
