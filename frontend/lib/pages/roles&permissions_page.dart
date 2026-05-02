import 'package:flutter/material.dart';
import 'package:pos_system/reusable%20widgets/UiWidgets.dart';
import 'package:provider/provider.dart';
import '../services/account_service.dart';
import '../providers/account_provider.dart';
import '../providers/theme_provider.dart';
import '../reusable widgets/AppColors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Load settings when the page first opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAllSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final provider = context.watch<AccountProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBgPrimary
            : AppColors.lightBgPrimary,
        appBar: AppBar(
          backgroundColor: isDark
              ? AppColors.darkBgElevated
              : AppColors.lightBgElevated,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Roles & Permissions',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: isDark
                ? AppColors.darkButtonsPrimary
                : AppColors.accentBlue,
            unselectedLabelColor: isDark
                ? AppColors.darkTextMuted
                : AppColors.lightTextMuted,
            tabs: const [
              Tab(text: 'Users'),
              Tab(text: 'Roles & Permissions'),
              //  Tab(text: 'Page Access'),
            ],
          ),
        ),
        body: provider.settingsLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: isDark
                      ? AppColors.darkButtonsPrimary
                      : AppColors.accentBlue,
                ),
              )
            : TabBarView(
                children: [
                  _buildUsersTab(isDark, provider),
                  _buildRolesTab(isDark, provider),
                ],
              ),
      ),
    );
  }

  Widget _buildUsersTab(bool isDark, AccountProvider provider) {
    final users = provider.settingsUsers;
    final roles = provider.settingsRoles;

    return users.isEmpty
        ? Center(
            child: Text(
              'No users found',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, i) {
              final u = users[i];
              final curRoleId = u['role_id'];
              final userName = u['name'] ?? u['email'] ?? 'User';
              final userId = u['id'];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBgElevated
                      : AppColors.lightBgSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderSubtle
                        : const Color.fromARGB(255, 234, 236, 244),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppColors.darkButtonsPrimary
                              : AppColors.accentBlue,
                        ),
                        child: Center(
                          child: Text(
                            userName.isEmpty
                                ? 'U'
                                : userName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              u['email'] ?? '',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          provider.deleteUser(userId, context);
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBgSurface
                              : const Color.fromARGB(255, 245, 246, 250),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderSubtle
                                : const Color.fromARGB(255, 234, 236, 244),
                          ),
                        ),
                        child: DropdownButton<int>(
                          value: curRoleId,
                          underline: const SizedBox(),
                          items: roles.map<DropdownMenuItem<int>>((r) {
                            return DropdownMenuItem<int>(
                              value: r['id'],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  r['role'],
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) async {
                            if (val != null) {
                              await provider.changeUserRole(u['id'], val, context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildRolesTab(bool isDark, AccountProvider provider) {
    final roles = provider.roles;
    final permissions = provider.settingsPermissions;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateRoleDialog(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.darkButtonsPrimary
                        : AppColors.accentBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: AppColors.darkTextPrimary),
                  label: const Text(
                    'New Role',
                    style: TextStyle(color: AppColors.darkTextPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: roles.isEmpty
              ? Center(
                  child: Text(
                    'No roles found',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: roles.length,
                  itemBuilder: (context, i) {
                    final r = roles[i];
                    final roleId = r['id'];
                    final List perms = r['permissions'] ?? [];
                    final Set<int> selected = perms
                        .map<int>((p) => p['id'] as int)
                        .toSet();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBgElevated
                            : AppColors.lightBgSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderSubtle
                              : const Color.fromARGB(255, 234, 236, 244),
                        ),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          title: Text(
                            r['role'],
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            '${perms.length} permission${perms.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                              fontSize: 12,
                            ),
                          ),
                          children: [
                            Container(
                              color: isDark
                                  ? AppColors.darkBgSurface
                                  : const Color.fromARGB(255, 245, 246, 250),
                              child: Column(
                                children: permissions.map<Widget>((p) {
                                  final pid = p['id'] as int;
                                  final checked = selected.contains(pid);
                                  return CheckboxListTile(
                                    title: Text(
                                      p['permission'],
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    value: checked,
                                    activeColor: isDark
                                        ? AppColors.darkButtonsPrimary
                                        : AppColors.accentBlue,
                                    onChanged: (v) async {
                                      final newSet = Set<int>.from(selected);
                                      if (v == true) {
                                        newSet.add(pid);
                                      } else {
                                        newSet.remove(pid);
                                      }
                                      await provider.updateRolePermissions(
                                        r['id'],
                                        newSet.toList(),
                                        context,
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                provider.deleteRole(roleId!, context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _showCreateRoleDialog(BuildContext context, AccountProvider provider) async {
    final roleNameCtrl = TextEditingController();
    final Set<int> selectedPerms = {};

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Role'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: roleNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Role Name',
                  hintText: 'e.g., manager, moderator',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Assign Permissions:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) => Column(
                  children: provider.settingsPermissions.map<Widget>((p) {
                    final pid = p['id'] as int;
                    return CheckboxListTile(
                      title: Text(p['permission']),
                      value: selectedPerms.contains(pid),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            selectedPerms.add(pid);
                          } else {
                            selectedPerms.remove(pid);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (roleNameCtrl.text.isEmpty) {
                SnackbarWidget('Role name is required', Colors.red, context);
                return;
              }
              await provider.createRole(
                roleNameCtrl.text,
                selectedPerms.toList(),
                context,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}